import 'package:flutter/material.dart';

class ShadowWidget extends StatelessWidget {
  const ShadowWidget({
    super.key,
    this.child,
    this.shadowColor,
    this.radius,
    this.elevation,
  });

  final Widget? child;
  final Color? shadowColor;
  final double? radius;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      type: .card,
      shadowColor: shadowColor ?? colorScheme.shadow,
      elevation: elevation ?? 0.0,
      shape: radius == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: .all(.circular(radius!)),
            ),
      clipBehavior: .antiAlias,
      child: child,
    );
  }
}
