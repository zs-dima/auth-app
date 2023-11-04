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
