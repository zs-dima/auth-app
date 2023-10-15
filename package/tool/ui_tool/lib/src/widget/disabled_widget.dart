import 'package:flutter/material.dart';

class DisabledWidget extends StatelessWidget {
  final Widget child;
  final bool disabled;

  const DisabledWidget({
    super.key,
    required this.child,
    this.disabled = true,
  });

  @override
  Widget build(BuildContext context) => disabled
      ? IgnorePointer(
          ignoring: true,
          child: Opacity(opacity: 0.3, child: child),
        )
      : child;
}
