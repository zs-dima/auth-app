import 'package:flutter/material.dart';

/// {@template card_widget}
/// Card widget.
/// {@endtemplate}
class CardWidget extends StatelessWidget {
  /// {@macro card_widget}
  const CardWidget({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding = EdgeInsets.zero,
    this.margin,
  });

  final double? width;
  final double? height;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) => Card(
        margin: margin,
        child: Padding(
          padding: padding,
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      );
}

class ShadowWidget extends StatelessWidget {
  final Widget? child;
  final Color? shadowColor;
  final double? radius;
  final double? elevation;

  const ShadowWidget({
    super.key,
    this.child,
    this.shadowColor,
    this.radius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      type: MaterialType.card,
      shadowColor: shadowColor ?? colorScheme.shadow,
      elevation: elevation ?? 0.0,
      shape: radius == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(radius!)),
            ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
