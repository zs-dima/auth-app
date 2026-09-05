import 'dart:math' as math;

import 'package:flutter/material.dart';

/// The chassis every auth screen sits in: a centred, width-capped column that scrolls when the
/// window is short.
///
/// The insets are INSIDE the scrollable and the safe area is a sliver, per the doctrine in
/// `AGENTS.md`: a scrollable behind a `Padding` or a `SafeArea` gets a viewport smaller than the
/// space it was given, so the scrollbar, the overscroll glow and the drag region all stop short of
/// the screen edge. `SliverFillRemaining(hasScrollBody: false)` is what keeps a short form centred
/// while letting a tall one — a long error, a large text scale — scroll instead of overflowing.
class AuthLayout extends StatelessWidget {
  const AuthLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
            sliver: SliverPadding(
              padding: .symmetric(horizontal: math.max(16, (constraints.maxWidth - 620) / 2)),
              sliver: SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: child),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
