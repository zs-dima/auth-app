import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

extension ThemeDataX on ThemeData {
  ThemePaddings get paddings => extension<ThemePaddings>()!;
}

class ThemePaddings extends ThemeExtension<ThemePaddings> {
  static ThemePaddings defaultSmall = ThemePaddings.all(
    tiny: 2,
    small: 4,
    medium: 8,
    large: 16,
  );
  static ThemePaddings defaultMedium = ThemePaddings.all(
    tiny: 4,
    small: 8,
    medium: 16,
    large: 32,
  );
  static ThemePaddings defaultLarge = ThemePaddings.all(
    tiny: 6,
    small: 12,
    medium: 24,
    large: 48,
  );
  static ThemePaddings adaptive(ScreenSize size) => size.when(
        phone: () => defaultSmall,
        tablet: () => defaultMedium,
        desktop: () => defaultLarge,
      );

  final EdgeInsets tiny;
  final EdgeInsets small;
  final EdgeInsets medium;
  final EdgeInsets large;

  const ThemePaddings({
    required this.tiny,
    required this.small,
    required this.medium,
    required this.large,
  });

  ThemePaddings.all({
    required double tiny,
    required double small,
    required double medium,
    required double large,
  })  : tiny = EdgeInsets.all(tiny),
        small = EdgeInsets.all(small),
        medium = EdgeInsets.all(medium),
        large = EdgeInsets.all(large);

  @override
  ThemePaddings copyWith({
    EdgeInsets? tiny,
    EdgeInsets? small,
    EdgeInsets? medium,
    EdgeInsets? large,
  }) =>
      ThemePaddings(
        tiny: tiny ?? this.tiny,
        small: small ?? this.small,
        medium: medium ?? this.medium,
        large: large ?? this.large,
      );

  @override
  ThemeExtension<ThemePaddings> lerp(covariant ThemeExtension<ThemePaddings>? other, double t) => //
      other is ThemePaddings //
          ? ThemePaddings(
              tiny: EdgeInsets.lerp(tiny, other.tiny, t)!,
              small: EdgeInsets.lerp(small, other.small, t)!,
              medium: EdgeInsets.lerp(medium, other.medium, t)!,
              large: EdgeInsets.lerp(large, other.large, t)!,
            )
          : this;
}
