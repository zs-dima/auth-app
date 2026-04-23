import 'dart:async';

import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/update/widget/app_update_available_widget.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:rxdart/rxdart.dart';

extension AppMessageScopeX on BuildContext {
  AppMessageController get message => dependencies.messageController;
}

/// {@template app_message_scope}
/// Subscribes to the app-global [AppMessageController] and
/// [UpdateCheckController] and routes their events into the UI
/// (toasts and the update banner). Holds no inherited state of its
/// own — the [AppMessageController] is reached through
/// `context.dependencies.messageController`.
/// {@endtemplate}
class AppMessageScope extends StatefulWidget {
  /// {@macro app_message_scope}
  const AppMessageScope({required this.child, this.octopus, super.key});

  /// The child widget.
  final Widget child;

  final Octopus? octopus;

  @override
  State<AppMessageScope> createState() => _AppMessageScopeState();
}

class _AppMessageScopeState extends State<AppMessageScope> {
  static void _appendWithLine(StringBuffer buffer, String text) {
    if (buffer.isNotEmpty) {
      buffer.write('\r\n');
    }
    buffer.write(text);
  }

  late final AppMessageController _messagingController;

  late final UpdateCheckController _updateCheckController;
  StreamSubscription<void>? _messageSubscription;

  StreamSubscription<void>? _updateCheckMessageSubscription;

  @override
  void initState() {
    super.initState();

    _updateCheckController = context.dependencies.updateCheckController;
    _subscribeAppUpdates();

    _messagingController = context.dependencies.messageController;
    _subscribeMessages();
  }

  void _subscribeAppUpdates() {
    _updateCheckMessageSubscription?.cancel();
    _updateCheckMessageSubscription = _updateCheckController
        .toStream()
        .whereType<UpdateAvailableState>()
        // .distinct()
        .listen(
          (_) {
            if (!mounted) return;
            // Replace any currently-visible banner with a fresh one.
            // Two back-to-back UpdateAvailableState emissions carry the
            // same currently-running version (the state's `.version` is
            // the RUNNING app version, not the pending one — it only
            // changes after a reload), so `.distinct()` would drop the
            // second show; `hideCurrentMaterialBanner()` covers that
            // correctly and also prevents ScaffoldMessenger from queueing
            // a duplicate on the apply-failure rollback path
            // (UpdateAvailable -> ApplyingUpdate -> UpdateAvailable).
            ScaffoldMessenger.of(context)
              ..hideCurrentMaterialBanner()
              ..showMaterialBanner(
                AppUpdateAvailableWidget(context, updateCheckController: _updateCheckController),
              );

            // Future.delayed(
            //   const Duration(seconds: 3),
            //   () => widget.octopus?.push(
            //     Routes.appUpdateAvailable,
            //     arguments: {RouteNode.version: state.version},
            //   ),
            // );
          },
          cancelOnError: false,
        );
    _updateCheckController.checkForUpdates();
  }

  void _subscribeMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = _messagingController
        .toStream()
        .bufferTime(const Duration(seconds: 3))
        .where((batch) => batch.isNotEmpty)
        .listen(
          (messages) {
            if (!mounted) return;

            final sbAppMessage = StringBuffer();
            final sbError = StringBuffer();
            final sbProgress = StringBuffer();
            Color? bgColor;

            for (final msg in messages) {
              switch (msg) {
                case AppErrorState(:final String error) || NetErrorState(:final String error):
                  _appendWithLine(sbError, error);

                case AppMessageState(
                      :final message,
                      :final backgroundColor,
                    )
                    when message.isNotEmpty:
                  _appendWithLine(sbAppMessage, message);
                  bgColor = backgroundColor;

                case AppProgressState(:final message) when message != null && message.isNotEmpty:
                  _appendWithLine(sbProgress, message);

                default:
              }
            }

            if (!context.mounted) return;
            if (sbError.isNotEmpty) context.showError(sbError.toString());
            if (sbAppMessage.isNotEmpty)
              context.showInfo(
                sbAppMessage.toString(),
                backgroundColor: bgColor,
              );
            if (sbProgress.isNotEmpty) context.showProgress(sbProgress.toString());

            // i.whenOrNull(
            //   appMessage:
            //       (message, backgroundColor) => context.showInfo(message, backgroundColor: colorScheme.surface),
            //   appError: (error, _) => context.showError(error),
            //   netError: (error, _) => context.showError(error),
            //   progress: (progress, type, message) => message.isNullOrSpace ? null : context.showProgress('$message'),
            // );
          },
          cancelOnError: false,
        );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _updateCheckMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
