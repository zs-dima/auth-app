// ignore_for_file: depend_on_referenced_packages

import 'package:ui/ui.dart';

class UiKitCard extends StatelessWidget {
  const UiKitCard({super.key, required this.title, this.child});

  final String title;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Card.outlined(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20.0,
        children: [AppText.titleLarge(title), ?child],
      ),
    ),
  );
}
