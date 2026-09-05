import 'package:auth_app/_core/message/app_message_scope.dart';
import 'package:flutter/material.dart';

/// {@template progress_overlay}
/// A thin bar across the top of [child] while anything is in flight.
/// {@endtemplate}
///
/// Reads `UiMessenger.progress`, which is a COUNT: two overlapping operations
/// show one bar, and the first to finish does not take it from the second.
///
/// A `Stack`, not an `OverlayEntry`. The entry version needed a post-frame
/// callback, an intent flag to let a same-frame `done` veto a pending insert,
/// `findRenderObject`/`localToGlobal` to place itself, a manual insert/remove
/// lifecycle and a `try/catch` around the insert — and it could only be mounted
/// under a `Navigator`, because `Overlay.of` throws without one. That ruled out
/// the one place that owns the messenger: `AppMessageScope` sits in
/// `MaterialApp.builder`, which Flutter builds ABOVE the Router. Rendering in
/// place needs none of it and works at any depth.
class ProgressOverlay extends StatelessWidget {
  /// {@macro progress_overlay}
  const ProgressOverlay({required this.child, super.key});

  /// The subtree the bar is drawn over.
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: <Widget>[
      child,
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          bottom: false,
          child: ValueListenableBuilder<int>(
            valueListenable: context.messenger.progress,
            builder: (context, count, _) =>
                count > 0 ? const LinearProgressIndicator(minHeight: 2) : const SizedBox.shrink(),
          ),
        ),
      ),
    ],
  );
}
