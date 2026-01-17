import 'package:ui/ui.dart';

extension ThemeDataX on ThemeData {
  ThemePaddings get paddings => extension<ThemePaddings>()!;
}

extension EdgeInsetsX on EdgeInsets {
  EdgeInsets get h => copyWith(top: 0.0, bottom: 0.0);
  EdgeInsets get v => copyWith(left: 0.0, right: 0.0);
}

class ThemePaddings extends ThemeExtension<ThemePaddings> {
  static final defaultSmall = ThemePaddings.all(tiny: 2.0, small: 4.0, medium: 8.0, large: 16.0);
  static final defaultMedium = ThemePaddings.all(tiny: 4.0, small: 8.0, medium: 16.0, large: 32.0);
  static final defaultLarge = ThemePaddings.all(tiny: 6.0, small: 12.0, medium: 24.0, large: 48.0);

  const ThemePaddings({required this.tiny, required this.small, required this.medium, required this.large});

  ThemePaddings.all({required double tiny, required double small, required double medium, required double large})
    : tiny = EdgeInsets.all(tiny),
      small = EdgeInsets.all(small),
      medium = EdgeInsets.all(medium),
      large = EdgeInsets.all(large);
  final EdgeInsets tiny;
  final EdgeInsets small;
  final EdgeInsets medium;
  final EdgeInsets large;

  static ThemePaddings adaptive(ScreenSize size) => size.when(
    phone: () => defaultSmall,
    tablet: () => defaultMedium,
    desktop: () => defaultLarge,
    wideScreen: () => defaultLarge,
  );

  @override
  ThemePaddings copyWith({EdgeInsets? tiny, EdgeInsets? small, EdgeInsets? medium, EdgeInsets? large}) => .new(
    tiny: tiny ?? this.tiny,
    small: small ?? this.small,
    medium: medium ?? this.medium,
    large: large ?? this.large,
  );

  @override
  ThemeExtension<ThemePaddings> lerp(covariant ThemeExtension<ThemePaddings>? other, double t) =>
      other
          is ThemePaddings //
      ? ThemePaddings(
          tiny: EdgeInsets.lerp(tiny, other.tiny, t)!,
          small: EdgeInsets.lerp(small, other.small, t)!,
          medium: EdgeInsets.lerp(medium, other.medium, t)!,
          large: EdgeInsets.lerp(large, other.large, t)!,
        )
      : this;
}
