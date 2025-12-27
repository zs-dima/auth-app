import 'dart:async';

import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notifications_controller.freezed.dart';

@freezed
sealed class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String title,
    String? description,
    required DateTime timestamp,
    Color? color,
    IconData? icon,
    @Default(false) bool hidden,
  }) = _Notification;
}

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState.idle({
    @Default([]) Iterable<Notification> notifications,
  }) = _idleState;
}

final class NotificationsController extends StateController<NotificationsState> with SequentialControllerHandler {
  NotificationsController({
    required AppMessageController messageController,
  }) : super(initialState: const NotificationsState.idle()) {
    _messageSubscription = messageController.toStream().listen(
      (msg) {
        switch (msg) {
          case AppErrorState(:final String error) || NetErrorState(:final String error):
            setState(
              NotificationsState.idle(
                notifications: [
                  Notification(
                    id: Object().hashCode.toRadixString(36),
                    title: 'Error',
                    description: error,
                    color: Colors.red,
                    icon: Icons.error_outline,
                    timestamp: DateTime.now(),
                  ),
                  ...state.notifications,
                ],
              ),
            );
          // _appendWithLine(sbError, error);

          case AppMessageState(
                :final message,
                :final backgroundColor,
              )
              when message.isNotEmpty:
            setState(
              NotificationsState.idle(
                notifications: [
                  Notification(
                    id: Object().hashCode.toRadixString(36),
                    title: 'Message',
                    description: message,
                    color: backgroundColor,
                    icon: Icons.check_circle_outline,
                    timestamp: DateTime.now(),
                  ),
                  ...state.notifications,
                ],
              ),
            );

          // _appendWithLine(sbAppMessage, message);
          // bgColor = backgroundColor;
          default:
        }
      },
      cancelOnError: false,
    );
  }

  late StreamSubscription<void> _messageSubscription;

  void remove(String id) {
    setState(
      NotificationsState.idle(
        notifications: state.notifications.where((n) => n.id != id),
      ),
    );
  }

  void clear() {
    setState(
      const NotificationsState.idle(
        notifications: [],
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }
}
