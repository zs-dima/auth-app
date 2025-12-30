import 'package:flutter/material.dart';
import 'package:ui/src/fonts/text.dart';

class DropdownSuggestion extends StatelessWidget {
  const DropdownSuggestion({
    super.key,
    required this.title,
    this.autofocus = false,

    this.onTap,
    this.icon,
  });

  final String title;
  final bool autofocus;
  final GestureTapCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => InkWell(
    autofocus: autofocus,
    onTap: onTap,
    child: Row(
      children: [
        const SizedBox(width: 16),
        if (icon != null) ...[
          Icon(icon),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: AppText.bodyLarge(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 14),
      ],
    ),
  );
  /* ListTile(
            leading: icon == null ? null : Icon(icon),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            //         key: ObjectKey(value),
            //         leading: CircleAvatar(
            //           child: Text(
            //             '$value'[0].toUpperCase(),
            //           ),
            //         ),
            autofocus: autofocus,
            // shape: const RoundedRectangleBorder(
            //   borderRadius: BorderRadius.all(Radius.circular(12)),
            // ),
            onTap: onTap,
          );*/
}
