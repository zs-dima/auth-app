import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/core/widget/window_scope.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

class ProgressOverlay extends StatefulWidget {
  final Widget child;

  const ProgressOverlay({
    super.key,
    required this.child,
  });

  @override
  State<ProgressOverlay> createState() => _ProgressOverlayState();
}

class _ProgressOverlayState extends State<ProgressOverlay> {
  OverlayEntry? overlayEntry;

  AppMessageBloc? _messageBloc;

  StreamSubscription? _messageSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final messageBloc = context.message.bloc;
    if (_messageBloc == messageBloc) return;
    _messageBloc = messageBloc;

    _subscribeMessages();
  }

  @override
  void dispose() {
    _unsubscribeMessages();
    removeProgressOverlay();
    super.dispose();
  }

  void _subscribeMessages() {
    _unsubscribeMessages();
    _messageSubscription = //
        _messageBloc!
            .whereState<AppProgressState>()
            .where((i) => [AppProgress.started, AppProgress.done].contains(i.progress))
            .listen(
      (AppProgressState i) {
        if (!mounted) return;
        if (i.progress == AppProgress.started) {
          createProgressOverlay();
        } else {
          removeProgressOverlay();
        }
      },
    );
  }

  void _unsubscribeMessages() {
    _messageSubscription?.cancel();
  }

  void createProgressOverlay() {
    removeProgressOverlay();

    assert(overlayEntry == null, 'OverlayEntry should be null when creating a new one.');
    final renderedWidget = context.findRenderObject() as RenderBox?;
    final renderedOffset = renderedWidget?.localToGlobal(Offset.zero);
    final renderedSize = renderedWidget?.size;

    final padding = MediaQuery.of(context).padding;
    final windowTitleHeigh = context.findAncestorWidgetOfExactType<WindowScope>()?.height ?? 0;

    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        left: renderedOffset?.dx,
        top: (renderedOffset?.dy ?? 0) + padding.top - windowTitleHeigh,
        height: renderedSize == null ? null : renderedSize.height / 150,
        width: renderedSize?.width,
        child: const LinearProgressIndicator(),
      ),
    );

    // Add the OverlayEntry to the Overlay.
    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  // Remove the OverlayEntry.
  void removeProgressOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
