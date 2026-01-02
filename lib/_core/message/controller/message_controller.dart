import 'dart:ui';

import 'package:auth_app/_core/api/http/api_client.dart';
import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';

part 'message_controller.freezed.dart';

enum AppProgress {
  started(-1),
  done(1)
  ;

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

  void showAppError(String error, [Object? e, StackTrace? s]) => setState(MessageState.appError(error));
  void showGrpcError(GrpcError e, String message) => setState(MessageState.netError(e.detail(message), e));
  void showApiError(ApiClientException e, String message) => setState(MessageState.netError(message, e));

  void progressStarted({String? type, String? message}) => showProgress(.started, type, message);
  void progressDone({String? type, String? message}) => showProgress(.done, type, message);
}
