import 'dart:ui';

import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_model/auth_model.dart' show RpcException;
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http_client/http_client.dart';

part 'message_controller.freezed.dart';

enum AppProgress {
  started(-1),
  done(1);

  final int value;

  const AppProgress(this.value);
}

@freezed
sealed class MessageState with _$MessageState {
  const factory MessageState.initial() = _InitialState;
  const factory MessageState.appMessage(String message, {Color? backgroundColor}) = AppMessageState;
  const factory MessageState.appError(String error, [Object? e]) = AppErrorState;
  const factory MessageState.netError(String error, Object e) = NetErrorState;
  const factory MessageState.progress(AppProgress progress, {String? type, String? message}) = AppProgressState;
}

final class AppMessageController extends StateController<MessageState> with SequentialControllerHandler {
  AppMessageController({super.initialState = const MessageState.initial()});

  int _progress = 0;

  void showAppMessage(String message, [Color? backgroundColor]) =>
      setState(MessageState.appMessage(message, backgroundColor: backgroundColor));

  void showProgress(AppProgress progress, [String? type, String? message]) {
    switch (progress) {
      case .started:
        if (_progress == 0) {
          setState(MessageState.progress(progress, type: type, message: message));
        }
        _progress++;
        break;

      case .done:
        if (_progress > 0) _progress--;
        if (_progress == 0) {
          setState(MessageState.progress(progress, type: type, message: message));
        }
        break;
    }
  }

  void showAppError(String error, [Object? e, StackTrace? s]) => setState(MessageState.appError(error, e));
  void showConnectError(ConnectException e, String message) =>
      setState(MessageState.netError(_connectErrorText(e, message), e));
  void showRpcException(RpcException e, String message) => setState(MessageState.netError(message, e));
  void showApiError(ApiClientException e, String message) => setState(MessageState.netError(message, e));

  void progressStarted({String? type, String? message}) => showProgress(.started, type, message);
  void progressDone({String? type, String? message}) => showProgress(.done, type, message);

  /// Unconditionally drains the progress reference counter.
  ///
  /// Emits a final [AppProgress.done] when the counter was non-zero so any subscribed overlays
  /// remove themselves. Intended as a safety net at boundaries where "no progress should be in
  /// flight" is an invariant (e.g. sign-out), not as a replacement for paired `progressStarted` /
  /// `progressDone` calls.
  void resetProgress() {
    if (_progress == 0) return;
    _progress = 0;
    setState(const MessageState.progress(.done));
  }

  /// Localized user-facing text for a Connect RPC failure.
  ///
  /// Mirrors [ConnectExceptionX.detail]'s composition rules, but takes the static code-specific
  /// parts from the `errors` sheet bucket ([ErrorsLocalization.rpcErrorMessages], ICU select) and
  /// falls back to the English [ConnectExceptionX.detail] until the localization delegate has
  /// loaded. The server-provided [ConnectException.message] (unauthenticated/internal) passes
  /// through untranslated by design.
  static String _connectErrorText(ConnectException e, String caption) {
    final localization = Localization.currentErrors;
    if (localization == null) return e.detail(caption);
    // NB: `Code.name` is the wire snake_case ('permission_denied'), while the sheet's select keys
    // are Dart-style camelCase — each case passes its literal instead of relying on `name`.
    return switch (e.code) {
      .unauthenticated => e.message.isNotEmpty ? '$caption. ${e.message}' : caption,
      .internal => '$caption: ${e.message}',
      .unavailable => localization.rpcErrorMessages('unavailable'),
      .deadlineExceeded => localization.rpcErrorMessages('deadlineExceeded'),
      .permissionDenied => '$caption: ${localization.rpcErrorMessages('permissionDenied')}',
      .aborted => '$caption: ${localization.rpcErrorMessages('aborted')}',
      .dataLoss => '$caption: ${localization.rpcErrorMessages('dataLoss')}',
      .canceled => '$caption: ${localization.rpcErrorMessages('canceled')}',
      .failedPrecondition => '$caption: ${localization.rpcErrorMessages('failedPrecondition')}',
      .unknown when e.message.contains('CORS') => '$caption: ${localization.rpcErrorMessages('cors')}',
      _ => '$caption: ${localization.rpcErrorMessages('other')}: $e',
    };
  }
}
