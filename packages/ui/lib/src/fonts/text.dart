import 'package:flutter/widgets.dart';
import 'package:ui/src/fonts/typography.dart';

/// {@template text}
/// AppText widget.
/// {@endtemplate}
class AppText extends StatelessWidget {
  /// {@macro text}
  const AppText(
    this.text,
    this.style, {
    this.overflow,
    this.maxLines,
    this.textAlign,
    this.softWrap,
    this.color,
    super.key,
  });

  /// {@macro text}
  const AppText.displayLarge(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.displayLarge;

  /// {@macro text}
  const AppText.displayMedium(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.displayMedium;

  /// {@macro text}
  const AppText.displaySmall(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.displaySmall;

  /// {@macro text}
  const AppText.headlineLarge(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.headlineLarge;

  /// {@macro text}
  const AppText.headlineMedium(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.headlineMedium;

  /// {@macro text}
  const AppText.headlineSmall(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.headlineSmall;

  /// {@macro text}
  const AppText.titleLarge(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.titleLarge;

  /// {@macro text}
  const AppText.titleMedium(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.titleMedium;

  /// {@macro text}
  const AppText.titleSmall(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.titleSmall;

  /// {@macro text}
  const AppText.bodyLarge(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.bodyLarge;

  /// {@macro text}
  const AppText.bodyMedium(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.bodyMedium;

  /// {@macro text}
  const AppText.bodySmall(
    this.text, {
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.color,
    super.key,
  }) : style = AppTextStyle.bodySmall;

  /// The text to display.
  final String text;

  /// The style to use for the text.
  final AppTextStyle style;

  /// The maximum number of lines for the text.
  final int? maxLines;

  /// The overflow behavior for the text.
  final TextOverflow? overflow;

  /// The text alignment.
  final TextAlign? textAlign;

  /// Whether to allow soft wrapping of the text.
  final bool? softWrap;

  /// The color of the text.
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: style
        .style, // final palette = Theme.of(context).colorPalette; style.copyWith(color: color ?? palette.foreground),
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
    softWrap: softWrap ?? true,
  );
}
