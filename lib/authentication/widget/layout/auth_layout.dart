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
///
/// The centring is a `Column`, NOT a `Center`, and that is the whole subtlety. Every screen hands
/// over a `Column` at its default `mainAxisSize.max`, which fills whatever box it is given: inside
/// a `Center` it took the full height and the form sat at the top of the window. A `Column` lays a
/// non-flex child out with an UNBOUNDED main axis, so the form shrink-wraps to its content first
/// and `mainAxisAlignment.center` then has something to centre — which is exactly what the
/// `SingleChildScrollView` this replaced did, by the same mechanism. `crossAxisAlignment.stretch`
/// keeps the width tight, as that scroll view also did.
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
                // One child on purpose: the Column IS the mechanism, not a container around it.
                // The dedicated widget this rule asks for is `Center`, and `Center` is what put
                // the form at the top of the window (see the class doc).
                // ignore: avoid-single-child-column-or-row
                child: Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .stretch,
                  children: <Widget>[child],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
