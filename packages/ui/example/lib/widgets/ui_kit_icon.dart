// ignore_for_file: depend_on_referenced_packages

import 'package:ui/ui.dart';

class UiKitIcon extends StatelessWidget {
  const UiKitIcon(this.title, this.icon, {super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: title,
    child: SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12.0,
        children: [
          Icon(icon),
          AppText.titleMedium(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}
