import 'dart:async';

import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/update/controller/update_check_controller.dart';
import 'package:auth_app/update/widget/app_update_available_widget.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:rxdart/rxdart.dart';

// extension AppMessageScopeX on BuildContext {
//   AppMessageController get message => AppMessageScope.of(this, listen: false);
// }

extension AppMessageScopeX on BuildContext {
  AppMessageController get message => dependencies.messageController;
}

/// {@template app_message_scope}
/// Theme scope is responsible for handling theme-related stuff.
///
/// See [AppMessageScope] for more info.
/// {@endtemplate}
class AppMessageScope extends StatefulWidget {
  /// {@macro app_message_scope}
  const AppMessageScope({required this.child, this.octopus, super.key});

  /// Get the [AppMessageController] of the closest [AppMessageScope] ancestor.
  // static AppMessageController of(BuildContext context, {bool listen = true}) =>
  //     context.scopeOf<_AppMessageInherited>(listen: listen).controller;

  /// The child widget.
  final Widget child;

  final Octopus? octopus;

  @override
  State<AppMessageScope> createState() => _AppMessageScopeState();
}

class _AppMessageScopeState extends State<AppMessageScope> {
  late AppMessageController _messagingController;
  StreamSubscription<void>? _messageSubscription;

  late UpdateCheckController _updateCheckController;
  StreamSubscription<void>? _updateCheckMessageSubscription;

  static void _appendWithLine(StringBuffer buffer, String text) {
    if (buffer.isNotEmpty) {
      buffer.write('\r\n');
    }
    buffer.write(text);
  }

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
        .distinct()
        .listen(
          (state) {
            if (!mounted) return; //  || widget.octopus?.state.children.last.name == Routes.appUpdateAvailable.name

            ScaffoldMessenger.of(context).showMaterialBanner(
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
    // final skipSameFor30Secs = SkipSameMessagesTransformer<MessageState>(
    //   duration: const Duration(seconds: 20),
    //   same: (a, b) {
    //     if (a == b) return true;
    //     if (a is AppErrorState && b is AppErrorState) return a.error == b.error;
    //     if (a is NetErrorState && b is NetErrorState) return a.error == b.error || '${a.e}' == '${b.e}';
    //     return false;
    //   },
    // );

    _messageSubscription?.cancel();
    _messageSubscription = _messagingController
        .toStream()
        // .transform(skipSameFor30Secs)
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
  // _AppMessageInherited(
  //   controller: _messagingController,
  //   state: _messagingController.state,
  //   child: widget.child,
  // );
}

// class _AppMessageInherited extends InheritedWidget {
//   const _AppMessageInherited({
//     required this.controller,
//     required this.state,
//     required super.child,
//   });

//   final AppMessageController controller;
//   final MessageState state;

//   @override
//   bool updateShouldNotify(covariant _AppMessageInherited oldWidget) => !identical(oldWidget.state, state);
// }

/// A StreamTransformer that drops an event if it's the same
/// as the previous event within the given [duration].
// class SkipSameMessagesTransformer<T> extends StreamTransformerBase<T, T> {
//   SkipSameMessagesTransformer({required this.duration, required this.same});

//   T? _lastData;
//   DateTime? _lastTime;

//   final Duration duration;
//   final bool Function(T value1, T? value2) same;

//   @override
//   Stream<T> bind(Stream<T> sourceStream) {
//     StreamSubscription<T>? subscription;

//     // ignore: close_sinks
//     StreamController<T>? controller;

//     controller = StreamController<T>(
//       onListen: () {
//         // Listen to the original source stream
//         subscription = sourceStream.listen(
//           (data) {
//             final now = DateTime.now();

//             final isDuplicateWithinWindow =
//                 _lastTime != null && now.difference(_lastTime!) < duration && same(data, _lastData);
//             if (!isDuplicateWithinWindow) {
//               _lastData = data;
//               _lastTime = now;
//               controller?.add(data);
//             }
//           },
//           onError: (Object error, StackTrace stack) {
//             controller?.addError(error, stack);
//           },
//           onDone: controller?.close,
//           cancelOnError: false,
//         );
//       },

//       // This callback fires when the *transformed* stream is canceled.
//       // We use it to cancel the subscription to the source stream.
//       onCancel: () {
//         subscription?.cancel();
//       },
//     );

//     return controller.stream;
//   }
// }
