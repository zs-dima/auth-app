import 'dart:math' as math;

import 'package:auth_app/_core/widget/layout/progress_overlay.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ProgressOverlay(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: .symmetric(
                horizontal: math.max(16, (constraints.maxWidth - 620) / 2),
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}
