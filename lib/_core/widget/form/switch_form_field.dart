import 'package:flutter/cupertino.dart';
import 'package:ui/ui.dart';

class SwitchFormField extends StatelessWidget {
  const SwitchFormField(
    this.caption, {
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String caption;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => Row(
    spacing: 5.0,
    children: [
      CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
      AppText.bodyLarge(
        caption,
        overflow: .ellipsis,
        maxLines: 1,
      ),
    ],
  );
}
