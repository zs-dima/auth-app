import 'dart:async';
import 'dart:io' as io;

import 'package:auth_app/_core/core.dart';
import 'package:auth_app/_core/widget/window_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProgressOverlay extends StatefulWidget {
  const ProgressOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ProgressOverlay> createState() => _ProgressOverlayState();
}

class _ProgressOverlayState extends State<ProgressOverlay> {
  OverlayEntry? _overlayEntry;

  AppMessageController? _messageController;

  StreamSubscription? _messageSubscription;

  void _subscribeMessages() {
    _unsubscribeMessages();
    _messageSubscription =
        //
        _messageController!
            .toStream()
            .where((i) => i is AppProgressState && [AppProgress.started, AppProgress.done].contains(i.progress))
            .map((i) => i as AppProgressState)
            .listen(
              (i) {
                if (!mounted) return;
                if (i.progress == AppProgress.started) {
                  _createProgressOverlay();
                } else {
                  _removeProgressOverlay();
                }
              },
            );
  }

  void _unsubscribeMessages() {
    _messageSubscription?.cancel();
  }

  void _createProgressOverlay() {
    _removeProgressOverlay();

    assert(_overlayEntry == null, 'OverlayEntry should be null when creating a new one.');
    final renderedWidget = context.findRenderObject() as RenderBox?;
    final renderedOffset = renderedWidget?.localToGlobal(Offset.zero);
    final renderedSize = renderedWidget?.size;

    final padding = MediaQuery.paddingOf(context);

    final windowTitleHeigh = (kIsWeb || io.Platform.isAndroid || io.Platform.isIOS)
        ? 0
        : context.findAncestorWidgetOfExactType<WindowScope>()?.height ?? 0;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: renderedOffset?.dx,
        top: (renderedOffset?.dy ?? 0) + padding.top - windowTitleHeigh,
        height: renderedSize == null ? null : renderedSize.height / 150,
        width: renderedSize?.width,
        child: const LinearProgressIndicator(),
      ),
    );

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);
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
    if (_messageController == messageController) return;
    _messageController = messageController;

    _subscribeMessages();
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
