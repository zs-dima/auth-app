import 'package:flutter/widgets.dart';
import 'package:ui/src/fonts/text.dart';

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

  final double spacing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return child;

    final labelWidget = AppText.titleMedium(label);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: spacing,
      children: [
        labelWidget,
        // if (getLabelWidget == null) labelWidget else getLabelWidget!(labelWidget),
        child,
      ],
    );
  }
}
