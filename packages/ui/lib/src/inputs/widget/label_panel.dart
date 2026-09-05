import 'package:flutter/material.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';
import 'package:ui/src/inputs/widget/label_widget.dart';

class LabelPanel extends StatelessWidget {
  const LabelPanel(
    this.largeScreen, {
    super.key,
    this.label,
    required this.child,
    this.decoration,
  });

  const LabelPanel.large({
    super.key,
    this.label,
    this.decoration,
    required this.child,
  }) : largeScreen = true;

  final String? label;
  final InputDecoration? decoration;

  final Widget child;

  final bool largeScreen;

  @override
  Widget build(BuildContext context) => LabelWidget(
    // Constant shape: the label is a slot, not a wrapper that appears at a breakpoint.
    label: largeScreen ? (label ?? decoration?.labelText ?? '') : '',
    child: InputDecorator(
      decoration: largeScreen
          ? (decoration ?? const InputDecoration()).applyDefaults(InputDecorations.flatTheme).copyWith(labelText: '')
          : (decoration ?? const InputDecoration()),
      child: child,
    ),
  );
}
