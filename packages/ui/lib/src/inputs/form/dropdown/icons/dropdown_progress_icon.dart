import 'package:flutter/material.dart';

class DropdownProgressIcon extends StatelessWidget {
  const DropdownProgressIcon({super.key});

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: 20, child: CircularProgressIndicator.adaptive(strokeWidth: 2));
}
