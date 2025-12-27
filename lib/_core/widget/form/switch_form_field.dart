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
    children: [
      CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
      const SizedBox(width: 5),
      Text(
        caption,
        style: context.theme.textTheme.bodyLarge,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    ],
  );
}
