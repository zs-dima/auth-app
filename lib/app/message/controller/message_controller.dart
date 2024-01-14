import 'dart:ui';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';

part 'message_controller.freezed.dart';

enum AppProgress {
  started(-1),
  done(1);

  final int value;
  const AppProgress(this.value);
}

@freezed
class MessageState with _$MessageState {
  // TODO const MessageState._();

  const factory MessageState.initial() = _InitialState;
  const factory MessageState.appMessage(String message, {Color? backgroundColor}) = AppMessageState;
  const factory MessageState.appError(String error) = AppErrorState;
  const factory MessageState.netError(String error) = NetErrorState;
  const factory MessageState.progress(AppProgress progress, {String? type, String? message}) = AppProgressState;

  // @override
  // TODO bool operator ==(Object other) => false;
}

final class AppMessageController extends StateController<MessageState> with DroppableControllerHandler {
  int _progress = 0;

  AppMessageController({
    super.initialState = const _InitialState(),
  });

  void showAppMessage(String message, Color? backgroundColor) =>
      setState(AppMessageState(message, backgroundColor: backgroundColor));

  void showProgress(AppProgress progress, [String? type, String? message]) {
    if (progress == AppProgress.started) {
      if (_progress == 0) {
        setState(AppProgressState(progress, type: type, message: message));
      }
      _progress++;
    } else if (progress == AppProgress.done) {
      _progress--;
      if (_progress == 0) {
        setState(AppProgressState(progress, type: type, message: message));
      }
    } else {
      setState(AppProgressState(progress, type: type, message: message));
    }
  }

  void showAppError(String error) => setState(AppErrorState(error));

  void showNetError(GrpcError e, String message) => setState(NetErrorState(e.detail(message)));
}
