import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dialog_bloc.freezed.dart';

@freezed
class DialogEvent with _$DialogEvent {
  const factory DialogEvent.acceptNotifications() = AcceptNotificationsEvent;
  const factory DialogEvent.acceptedNotifications() = AcceptedNotificationsEvent;
}

@freezed
class DialogState with _$DialogState {
  const factory DialogState.initial() = _InitialState;
  const factory DialogState.acceptNotifications() = AcceptNotificationsState;
  const factory DialogState.acceptedNotifications() = AcceptedNotificationsState;
}

class AppDialogBloc extends Bloc<DialogEvent, DialogState> {
  AppDialogBloc() : super(const DialogState.initial()) {
    on(onEvents);
  }

  void onEvents(DialogEvent event, Emitter emit) => event.when(
        acceptNotifications: () => emit(const AcceptNotificationsState()),
        acceptedNotifications: () => emit(const AcceptedNotificationsState()),
      );
}
