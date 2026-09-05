import 'dart:async';
import 'dart:io';

import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_model/auth_model.dart' show RequestSessionEndedException, RpcException, RpcException$Cancelled;
import 'package:connect_kit/connect_kit.dart';
import 'package:connectrpc/connect.dart';
import 'package:http_kit/http_kit.dart';
import 'package:meta/meta.dart';

/// {@template user_facing_error}
/// What to tell the user about a failure, and how loudly to record it.
/// {@endtemplate}
@immutable
final class UserFacingError {
  /// {@macro user_facing_error}
  const UserFacingError(this.text, {this.level = LogLevel.error});

  /// The localized sentence the user reads.
  final String text;

  /// How the app records it.
  ///
  /// `warn` — the user (or the network) can act on it: wrong credentials, an
  /// expired link, a server that is down. It belongs in the journal and in the
  /// breadcrumb trail, but it is not a defect and must not become a crash-report
  /// issue — that distinction is what stopped a ten-minute outage from filing
  /// one issue per retry.
  ///
  /// `error` — something that should not happen. It is reported.
  final LogLevel level;
}

/// Records [error] and tells the user about it, in one step.
///
/// This is what replaced `AppMessageControllerMixin.setError`. The differences
/// are the point of the rework: [body] is a stable developer line
/// (`Area | operation | message`) that groups in the crash reporter and never
/// reaches the UI, the user reads the localized sentence, and the severity comes
/// from the classification rather than being `error` for everything — a wrong
/// password no longer files an issue.
///
/// Returns the sentence shown, so a caller can put it in its own state, or
/// `null` when the failure was expected teardown and nothing was said.
///
/// [failure] replaces the classification entirely, and [level] overrides only
/// its severity — for a caller that owns the error type and knows better than
/// [describeError] can. The common case is the second: the same sentence, but
/// this failure is the user's file or the user's typing, not our defect.
String? reportFailure(
  String body,
  Object? error, {
  required String caption,
  StackTrace? stackTrace,
  Map<String, Object?>? meta,
  UserFacingError? failure,
  LogLevel? level,
  bool toast = true,
}) {
  final classified = failure ?? describeError(error, caption: caption);
  // The override LOWERS severity — "I own this error type and it is a condition".
  // Raising it would defeat the classification it was added to respect, and the
  // one honest way to raise is to fix `describeError`.
  assert(
    level == null || classified == null || level.severityNumber <= classified.level.severityNumber,
    'reportFailure(level:) attenuates; to promote a failure, teach describeError about it',
  );
  final described = classified == null || level == null ? classified : UserFacingError(classified.text, level: level);
  if (described == null) {
    // The caller's own body, forwarded — it is already canonical, and this line is that
    // operation's trail. Why nothing was said is an attribute.
    log.v4(
      body,
      meta: <String, Object?>{
        'log.suppressed': 'expected teardown',
        'exception.type': error.runtimeType.toString(),
      },
    );
    return null;
  }
  final draft = log(body).cause(error, stackTrace).description(described.text).meta(meta)
    ..at(described.level)
    // To the reporter as well. Below the capture floor `ReportingSink` sends it
    // as a structured log rather than an issue, which is how an outage or a 5xx
    // the user was told about is visible without filing one issue per retry.
    ..escalate();
  // `toast: false` for a caller that renders the sentence itself — the auth
  // screens put it under the form, and a snack bar saying the same thing twice
  // is not a second piece of information.
  if (toast) draft.toast(tone: .alert);
  return described.text;
}

/// Describes [error] for the user, or `null` when nothing should be said.
///
/// `null` means EXPECTED TEARDOWN — the session ended or the call was aborted by
/// the user's own sign-out while it was in flight (refresh_token.md §13). Before
/// this carve-out every logout produced an "An error has occurred" toast from
/// each aborted call.
///
/// [caption] is what the app was doing ("Failed to upload avatar"); it stays the
/// sentence for anything the user cannot diagnose further. Transport failures
/// compose it with the reason, because "backend unavailable" is the part that
/// tells the user to wait rather than retype. With no caption, the type-mapped
/// localized sentence is used on its own.
UserFacingError? describeError(Object? error, {String? caption}) => switch (error) {
  // Expected teardown: the user's own sign-out aborting a call in flight.
  //
  // `RpcException$Cancelled` is the shape a cancelled RPC actually reaches the UI in: every call
  // goes through `guardRpcCall`/`guardRpcStream`, which map a `ConnectException` to the domain
  // family (A8). Matching only the bare `ConnectException` left the wrapped one falling through to
  // the transport arm below, where it became a `warn` toast reading "…: canceled" — the exact
  // sentence §13 exists to prevent. The bare types stay: they are what an unguarded call throws.
  RequestSessionEndedException _ ||
  RpcException$Cancelled _ ||
  ConnectException(code: Code.canceled) ||
  ApiClientException$Cancelled _ => null,

  // NB: a domain refusal the server described in words meant for the user — a wrong password, a
  // locked account — is `AuthenticationException`, which lives in the authentication feature and
  // must not be imported here. Its owner classifies it (see `authentication_controller.dart`).

  // The domain client maps ConnectException -> RpcException (A8) but keeps the transport failure
  // in [cause]. Reading it here reuses the code-specific wording; A8 still holds, because this is
  // the UI boundary and no domain code sees a ConnectException (F1).
  RpcException(cause: final ConnectException connect) => _connectError(connect, caption),
  final ConnectException connect => _connectError(connect, caption),

  ApiClientException(:final statusCode) => .new(
    caption ?? _typeText(error),
    level: _httpLevel(statusCode),
  ),
  RpcException _ => .new(caption ?? _typeText(error)),

  // No transport involved. The caption, when the call site gave one, says more than the type
  // ever could.
  _ when caption != null => .new(caption, level: error is TimeoutException ? .warn : .error),
  TimeoutException _ => .new(_typeText(error), level: .warn),
  _ => .new(_typeText(error)),
};

UserFacingError _connectError(ConnectException error, String? caption) =>
    .new(_connectErrorText(error, caption ?? ''), level: _connectLevel(error.code));

/// The localized sentence for [error]'s TYPE, used when the call site had no
/// caption of its own to offer.
String _typeText(Object? error) => switch (error) {
  TimeoutException _ => _fallback((l) => l.errTimeOutExceeded, 'Timeout exceeded'),
  FormatException _ => _fallback((l) => l.errInvalidFormat, 'Invalid format'),
  UnimplementedError _ => _fallback((l) => l.errNotImplementedYet, 'Not implemented yet'),
  UnsupportedError _ => _fallback((l) => l.errUnsupportedOperation, 'Unsupported operation'),
  FileSystemException _ => _fallback((l) => l.errFileSystemException, 'File system error'),
  AssertionError _ => _fallback((l) => l.errAssertionError, 'Assertion error'),
  Exception _ => _fallback((l) => l.errAnExceptionHasOccurred, 'An exception has occurred'),
  _ => _fallback((l) => l.errAnErrorHasOccurred, 'An error has occurred'),
};

/// A condition the user or the network can act on is not a defect; a protocol
/// violation is.
///
/// Only `error` reaches the crash reporter, so this switch decides what fills
/// the issue list. Two groups are deliberately NOT defects:
///
/// * conditions — wait, retry, sign in again;
/// * REFUSALS — the request was well-formed enough for the server to answer it,
///   and the answer is for the user: the address is already registered, the
///   record is gone, this account may not do that. Filing an issue for
///   "e-mail already registered" fills a bug tracker with other people's typing,
///   and buries the failures that are ours.
LogLevel _connectLevel(Code code) => switch (code) {
  .unavailable || .deadlineExceeded || .canceled || .resourceExhausted || .unauthenticated => .warn,
  .invalidArgument ||
  .alreadyExists ||
  .notFound ||
  .permissionDenied ||
  .failedPrecondition ||
  .outOfRange ||
  .aborted => .warn,
  // `unknown`, `unimplemented`, `internal`, `dataLoss`: the app sent something
  // the server cannot process, or the server broke.
  _ => .error,
};

/// Transient and server-side statuses are conditions; the rest mean the app sent
/// something wrong.
///
/// 401 and 403 join them: on a presigned S3 upload they mean the capability
/// expired mid-flight, which is a race with the clock, not a defect — the same
/// judgement as `unauthenticated` on the RPC side.
LogLevel _httpLevel(int statusCode) => switch (statusCode) {
  0 || 401 || 403 || 408 || 425 || 429 => .warn,
  >= 500 => .warn,
  _ => .error,
};

/// Reads a sentence from the current `errors` sheet, falling back to English
/// until the localization delegate has loaded.
@pragma('dart2js:tryInline')
@pragma('vm:prefer-inline')
String _fallback(String Function(ErrorsLocalization l) localize, String english) =>
    switch (Localization.currentErrors) {
      final ErrorsLocalization errors => localize(errors),
      null => english,
    };

/// Localized user-facing text for a Connect RPC failure.
///
/// Mirrors [ConnectExceptionX.detail]'s composition rules, but takes the static
/// code-specific parts from the `errors` sheet bucket
/// ([ErrorsLocalization.rpcErrorMessages], ICU select) and falls back to the
/// English [ConnectExceptionX.detail] until the localization delegate has
/// loaded. The server-provided [ConnectException.message]
/// (unauthenticated/internal) passes through untranslated by design.
String _connectErrorText(ConnectException e, String caption) {
  final localization = Localization.currentErrors;
  if (localization == null) return e.detail(caption);
  // NB: `Code.name` is the wire snake_case ('permission_denied'), while the sheet's select keys
  // are Dart-style camelCase — each case passes its literal instead of relying on `name`.
  return switch (e.code) {
    .unauthenticated => e.message.isNotEmpty ? '$caption. ${e.message}' : caption,
    // NOT the server's own text: `internal` means the backend broke, and its
    // message is developer English written for its own logs. `unauthenticated`
    // below is the opposite case — that one IS written for the user.
    .internal => '$caption: ${localization.rpcErrorMessages('other')}',
    .unavailable => localization.rpcErrorMessages('unavailable'),
    .deadlineExceeded => localization.rpcErrorMessages('deadlineExceeded'),
    .permissionDenied => '$caption: ${localization.rpcErrorMessages('permissionDenied')}',
    .aborted => '$caption: ${localization.rpcErrorMessages('aborted')}',
    .dataLoss => '$caption: ${localization.rpcErrorMessages('dataLoss')}',
    .canceled => '$caption: ${localization.rpcErrorMessages('canceled')}',
    .failedPrecondition => '$caption: ${localization.rpcErrorMessages('failedPrecondition')}',
    .unknown when e.message.contains('CORS') => '$caption: ${localization.rpcErrorMessages('cors')}',
    // No `$e`: the exception's own text is developer English, is not localized,
    // and on `unknown` carries whatever the transport put in it. The journal
    // and the crash report have the exception; the user gets a sentence.
    _ => '$caption: ${localization.rpcErrorMessages('other')}',
  };
}
