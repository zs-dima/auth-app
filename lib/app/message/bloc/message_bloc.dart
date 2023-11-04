// ignore_for_file: hash_and_equals, avoid_equals_and_hash_code_on_mutable_classes, unused_element

import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bloc_concurrency;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';

part 'message_bloc.freezed.dart';

class AppProgress {
  static const started = -1;
  static const done = 1;

  static const startedEvent = _ShowProgress(started);
  static const doneEvent = _ShowProgress(done);
}

@freezed
class MessageEvent with _$MessageEvent {
  const factory MessageEvent.showAppMessage(String message, {Color? backgroundColor}) = _ShowAppMessage;
  const factory MessageEvent.showAppError(String error) = _ShowAppError;
  const factory MessageEvent.showNetError(GrpcError e, String message) = _ShowNetError;
  const factory MessageEvent.showProgress(
    int progress, {
    String? type,
    String? message,
  }) = _ShowProgress;
}

@freezed
class MessageState with _$MessageState {
  const MessageState._();

  factory MessageState.initial() = _InitialState;
  factory MessageState.appMessage(String message, {Color? backgroundColor}) = AppMessageState;
  factory MessageState.appError(String error) = AppErrorState;
  factory MessageState.netError(String error) = NetErrorState;
  factory MessageState.progress(int progress, {String? type, String? message}) = AppProgressState;

  @override
  bool operator ==(Object other) => false;
}

class AppMessageBloc extends Bloc<MessageEvent, MessageState> {
  int _progress = 0;

  AppMessageBloc() : super(_InitialState()) {
    on<MessageEvent>(
      onEvents,
      transformer: bloc_concurrency.concurrent(),
    );
  }

  void onEvents(MessageEvent event, Emitter emit) => event.when(
        showAppMessage: (String message, Color? backgroundColor) {
          emit(AppMessageState(message, backgroundColor: backgroundColor));
        },
        showProgress: (int progress, String? type, String? message) {
          if (progress == AppProgress.started) {
            if (_progress == 0) {
              emit(AppProgressState(progress, type: type, message: message));
            }
            _progress++;
          } else if (progress == AppProgress.done) {
            _progress--;
            if (_progress == 0) {
              emit(AppProgressState(progress, type: type, message: message));
            }
          } else {
            emit(AppProgressState(progress, type: type, message: message));
          }
        },
        showAppError: (String error) {
          emit(AppErrorState(error));
        },
        showNetError: (GrpcError e, String message) {
          emit(NetErrorState(e.detail(message)));
        },
      );
}
