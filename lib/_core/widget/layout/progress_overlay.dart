import 'dart:async';
import 'dart:io' as io;

import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/_core/message/app_message_scope.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:auth_app/_core/widget/window_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ProgressOverlay extends StatefulWidget {
  const ProgressOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<ProgressOverlay> createState() => _ProgressOverlayState();
}

class _ProgressOverlayState extends State<ProgressOverlay> {
  OverlayEntry? _overlayEntry;

  AppMessageController? _messageController;

  StreamSubscription? _messageSubscription;

  bool get _overlayVisible => _overlayEntry != null;

  void _subscribeMessages() {
    _unsubscribeMessages();
    _messageSubscription =
        _messageController! //
            .toStream()
            .where((i) => i is AppProgressState && [AppProgress.started, AppProgress.done].contains(i.progress))
            .map((i) => i as AppProgressState)
            .listen(_updateProgressOverlay, cancelOnError: false);
  }

  void _unsubscribeMessages() {
    _messageSubscription?.cancel();
  }

  void _updateProgressOverlay(AppProgressState progressState) {
    if (!mounted) return;

    switch (progressState.progress) {
      case .started:
        if (_overlayVisible) return;
        _createProgressOverlay();
        break;

      case .done:
        if (!_overlayVisible) return;
        _removeProgressOverlay();
        break;
    }
  }

  void _createProgressOverlay() {
    _removeProgressOverlay();

    assert(_overlayEntry == null, 'OverlayEntry should be null when creating a new one.');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      RenderBox? renderedWidget;
      try {
        final renderObject = context.findRenderObject();
        if (renderObject is! RenderBox) return;
        renderedWidget = renderObject;
      } catch (_) {
        // Widget became inactive, just return
        return;
      }

      if (!renderedWidget.hasSize) return;

      final renderedOffset = renderedWidget.localToGlobal(.zero);
      final renderedSize = renderedWidget.size;

      final padding = MediaQuery.paddingOf(context);

      final windowTitleHeigh = (kIsWeb || io.Platform.isAndroid || io.Platform.isIOS)
          ? 0
          : (context.findAncestorWidgetOfExactType<WindowScope>()?.height ?? 0);

      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: renderedOffset.dx,
          top: renderedOffset.dy + padding.top - windowTitleHeigh,
          height: renderedSize.height / 150,
          width: renderedSize.width,
          child: const LinearProgressIndicator(),
        ),
      );

      try {
        // Add the OverlayEntry to the Overlay.
        Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);
      } on Object catch (e, s) {
        logger.e('Failed to insert Progress Overlay', error: e, stackTrace: s);
        _removeProgressOverlay();
      }
    });
  }

  // Remove the OverlayEntry.
  void _removeProgressOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final messageController = context.message;
    if (_messageController != messageController) {
      _messageController = messageController;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _subscribeMessages();

        // Restore current progress state.
        if (messageController.state case final AppProgressState state) {
          _updateProgressOverlay(state);
        }
      });
    }
  }

  @override
  void dispose() {
    _unsubscribeMessages();
    _removeProgressOverlay();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
