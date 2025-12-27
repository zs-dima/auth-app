import 'package:flutter/material.dart';

class LabelWidget extends StatelessWidget {
  const LabelWidget({
    super.key,
    required this.label,
    this.spacing = 5.0,
    // this.getLabelWidget,
    required this.child,
  });

  final String label;
  // final Widget Function(Widget label)? getLabelWidget;

  final double? spacing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return child;

    final labelWidget = Text(label, style: Theme.of(context).textTheme.titleMedium);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing ?? 0.0,
      children: [
        labelWidget,
        // if (getLabelWidget == null) labelWidget else getLabelWidget!(labelWidget),
        child,
      ],
    );
  }
}
