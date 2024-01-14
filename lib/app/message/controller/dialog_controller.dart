import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dialog_controller.freezed.dart';

@freezed
class DialogState with _$DialogState {
  const factory DialogState.initial() = _InitialState;
  const factory DialogState.acceptNotifications() = AcceptNotificationsState;
  const factory DialogState.acceptedNotifications() = AcceptedNotificationsState;
}

final class AppDialogController extends StateController<DialogState> with DroppableControllerHandler {
  AppDialogController({
    super.initialState = const DialogState.initial(),
  });

  void acceptNotifications() => setState(const AcceptNotificationsState());
  void acceptedNotifications() => setState(const AcceptedNotificationsState());
}
