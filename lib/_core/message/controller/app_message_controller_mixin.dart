import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_model/auth_model.dart' show RpcException;
import 'package:connectrpc/connect.dart';
import 'package:http_client/http_client.dart';

typedef AppMessageBlocErrorCallback = void Function(String message);
typedef AppMessageBlocLocalizeErrorCallback = String Function(ErrorsLocalization l);

mixin AppMessageControllerMixin {
  late final AppMessageController _messageController;
  late final Logger _log;

  set messageController(AppMessageController value) {
    _messageController = value;
    _log = logger;
  }

  void setMessage(String message, [Color? backgroundColor]) {
    _messageController.showAppMessage(message, backgroundColor);
  }

  // Transport-specific errors (`ConnectException` from Connect RPC, `ApiClientException` from the
  // HTTP ApiClient) intentionally surface to this UI boundary, which switches on each to render a
  // transport-appropriate message. This is a deliberate boundary, not a missing abstraction:
  // there is no unified error type, callers pass the raw transport error here.
  void setError(String message, [Object? e, StackTrace? s, AppMessageBlocErrorCallback? onError]) {
    final msg = formatMessage(message);

    switch (e) {
      // Domain RPC failure mapped at the API client (A8). Raw ConnectException is still handled
      // below for any error surfacing straight from the interceptor/stream layer.
      case RpcException _:
        _setRpcException(msg, e, s);
        break;

      case ConnectException _:
        _setConnectError(msg, e);
        break;

      case ApiClientException _:
        _setApiError(msg, e, s);
        break;

      default:
        _setAppError(msg, e, s);
    }

    onError?.call(msg);
  }

  void _setAppError(String message, [Object? e, StackTrace? s]) {
    _log.e('$message: $e\n$s', stackTrace: s);
    _messageController.showAppError(message, e);
  }

  void _setConnectError(
    String message,
    ConnectException error, [
    StackTrace? s,
  ]) {
    if (error.code == Code.internal) {
      _log.e('RPC Error: $message: ${error.message}', stackTrace: s);
    } else if (error.code == Code.unknown && error.message.contains('CORS')) {
      _log.e('RPC CORS Error: $message: ${error.message}', stackTrace: s);
    } else {
      _log.e('RPC Error: $message\n$error', stackTrace: s);
    }

    // Typed google.rpc details arrive as raw `Any` payloads (type + bytes) — log their presence
    // (the grpc-era code decoded `DebugInfo`; connect-dart exposes details untyped).
    for (final detail in error.details) {
      _log.w(detail.debug != null ? '${detail.type}: ${detail.debug}' : detail.type);
    }

    _messageController.showConnectError(error, message);
  }

  void _setRpcException(String message, RpcException error, [StackTrace? s]) {
    // The domain client maps ConnectException -> RpcException (A8) but keeps the original error in
    // [cause]. At this app-layer UI boundary we may inspect it to reuse the richer, code-specific
    // rendering (e.g. "Backend unavailable") instead of a generic caption — A8 still holds because
    // no domain/business code sees ConnectException, only this boundary does (F1).
    if (error.cause case final ConnectException connectError) {
      _setConnectError(message, connectError, s);
      return;
    }
    _log.e('RPC Error: $message\n$error', stackTrace: s);
    _messageController.showRpcException(error, message);
  }

  void _setApiError(String message, ApiClientException error, [StackTrace? s]) {
    _log.e('API Error: $message\n$error', stackTrace: s);
    _messageController.showApiError(error, message);
  }

  void setProgressStarted() => _messageController.progressStarted();
  void setProgressDone() => _messageController.progressDone();

  /// Safety net that unconditionally drains the progress counter — see
  /// [AppMessageController.resetProgress]. Use at boundaries where no progress should be in flight
  /// (e.g. sign-out), so a stale overlay left by an unbalanced `setProgressStarted` is cleared.
  void resetProgress() => _messageController.resetProgress();

  /// Rethrows the error with the stack trace.
  static Never throwWithStackTrace(Object error, StackTrace stackTrace) => Error.throwWithStackTrace(error, stackTrace);

  @pragma('dart2js:tryInline')
  @pragma('vm:prefer-inline')
  static String _localizedError(String fallback, AppMessageBlocLocalizeErrorCallback localize) =>
      switch (Localization.currentErrors) {
        final ErrorsLocalization errors => localize(errors),
        null => fallback,
      };

  // Also we can add current localization to this method
  static String formatMessage(Object error, [String fallback = 'An error has occurred']) => switch (error) {
    final String e => e,
    FormatException _ => _localizedError('Invalid format', (lcl) => lcl.errInvalidFormat),
    TimeoutException _ => _localizedError('Timeout exceeded', (lcl) => lcl.errTimeOutExceeded),
    UnimplementedError _ => _localizedError('Not implemented yet', (lcl) => lcl.errNotImplementedYet),
    UnsupportedError _ => _localizedError('Unsupported operation', (lcl) => lcl.errUnsupportedOperation),
    FileSystemException _ => _localizedError('File system error', (lcl) => lcl.errFileSystemException),
    AssertionError _ => _localizedError('Assertion error', (lcl) => lcl.errAssertionError),
    Error _ => _localizedError('An error has occurred', (lcl) => lcl.errAnErrorHasOccurred),
    Exception _ => _localizedError('An exception has occurred', (lcl) => lcl.errAnExceptionHasOccurred),
    _ => fallback,
  };
}

// NB: the user-facing code→message mapping (`ConnectExceptionX.detail`) lives in connect_model's
// rpc_tool.dart — the grpc-era duplicate table that used to sit here was consolidated there.
