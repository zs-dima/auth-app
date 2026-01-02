import 'package:flutter/material.dart';
import 'package:ui/src/fonts/text.dart';

class LabelField extends StatelessWidget {
  const LabelField({
    super.key,
    this.title,
    required this.label,
    this.enabled = true,
    this.suffixIcon, // = const Icon(Icons.arrow_drop_down, size: 14.0), // Icons.arrow_drop_down
    this.prefixIcon,
    this.helperText,
    this.helperMaxLines,
    this.errorText,
    this.decoration,
  });

  final String? title;
  final String label;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? helperText;
  final int? helperMaxLines;
  final String? errorText;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: (decoration ?? const InputDecoration()).copyWith(
      isCollapsed: false,
      isDense: false,
      labelText: title,
      enabled: enabled,
      helperText: helperText,
      contentPadding: const .only(left: 12.0, top: 14.0, right: 12.0, bottom: 12.0),
      errorText: errorText,
      helperMaxLines: helperMaxLines,
      // errorMaxLines: 0,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    ),
    child: AppText.bodyLarge(
      label,
      color: enabled ? null : Theme.of(context).disabledColor,
    ),
  );
}
