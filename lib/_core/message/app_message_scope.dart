import 'dart:async';

import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/_core/widget/layout/progress_overlay.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/update/widget/app_update_available_widget.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

extension AppMessageScopeX on BuildContext {
  /// The app's user-message surface.
  UiMessenger get messenger => dependencies.messenger;
}

/// {@template app_message_scope}
/// Subscribes to the app-global [UiMessenger] and [UpdateCheckController] and
/// routes their events into the UI (toasts and the update banner). Holds no
/// inherited state of its own — the messenger is reached through
/// `context.dependencies.messenger`.
/// {@endtemplate}
class AppMessageScope extends StatefulWidget {
  /// {@macro app_message_scope}
  const AppMessageScope({required this.child, super.key});

  /// The child widget.
  final Widget child;

  @override
  State<AppMessageScope> createState() => _AppMessageScopeState();
}

class _AppMessageScopeState extends State<AppMessageScope> {
  /// How long messages are collected before being shown.
  ///
  /// One failed screen can raise three toasts at once (the call, the controller
  /// and the retry); showing them in sequence means twelve seconds of snack
  /// bars. Short enough to feel immediate, long enough to catch a burst — the
  /// three seconds this used to wait were long enough for the user to have moved
  /// on before being told anything.
  static const Duration _coalesceWindow = Duration(milliseconds: 300);

  late final UiMessenger _messenger;
  late final UpdateCheckController _updateCheckController;

  StreamSubscription<void>? _messageSubscription;
  StreamSubscription<void>? _updateCheckMessageSubscription;

  @override
  void initState() {
    super.initState();

    _updateCheckController = context.dependencies.updateCheckController;
    _subscribeAppUpdates();

    _messenger = context.dependencies.messenger;
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
          },
          cancelOnError: false,
        );
    _updateCheckController.checkForUpdates();
  }

  void _subscribeMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = _messenger.messages
        .bufferTime(_coalesceWindow)
        .where((batch) => batch.isNotEmpty)
        .listen(_show, cancelOnError: false);
  }

  void _show(List<UiMessage> batch) {
    if (!mounted) return;
    // Outside production a failure carries its Details action. In production the user reads one
    // sentence and nothing else — a stack trace in a snack bar is both noise and a leak.
    final withDetails = !context.dependencies.environment.type.isProduction;

    // One snack bar per tone: an error and a confirmation must not be merged into one line, but
    // three failures of the same operation should not queue twelve seconds of snack bars either.
    for (final tone in ToastTone.values) {
      final messages = batch.where((message) => message.tone == tone).toList(growable: false);
      if (messages.isEmpty) continue;
      if (!context.mounted) return;
      context.showUiMessage(
        messages.length == 1
            ? messages.single
            // Merged: several causes, so no single event to attach a Details action to.
            : UiMessage(tone: tone, text: messages.map((message) => message.text).join('\r\n')),
        withDetails: withDetails && messages.length == 1,
      );
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _updateCheckMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  // The bar belongs here for the same reason the toasts do: this scope is what
  // owns the messenger, and progress is the other half of what it carries.
  Widget build(BuildContext context) => ProgressOverlay(child: widget.child);
}
