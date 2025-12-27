import 'package:flutter/material.dart';

enum AppTextStyle {
  displayLarge(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 57,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.12,
      letterSpacing: -0.25,
      package: 'ui',
    ),
  ),
  displayMedium(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 45,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.15,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),
  displaySmall(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 36,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.22,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),
  headlineLarge(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 32,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.25,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),
  headlineMedium(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 28,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.28,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),
  headlineSmall(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),
  titleLarge(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 22,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.27,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),

  titleBold(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: 'ui',
    ),
  ),
  titleMedium(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),
  titleSmall(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.42,
      letterSpacing: 0.1,
      package: 'ui',
    ),
  ),
  bodyLarge(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),
  ),
  bodyMedium(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      letterSpacing: 0.25,
      height: 1.43,
      package: 'ui',
    ),
  ),
  bodySmall(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.4,
      package: 'ui',
    ),
  ),
  labelLarge(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.43,
      letterSpacing: 0.1,
      package: 'ui',
    ),
  ),

  labelMedium(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  ),
  labelSmall(
    TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.45,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  );

  const AppTextStyle(this.style);

  final TextStyle style;
}

/// {@template typography}
/// AppTypography class.
/// {@endtemplate}
class AppTypography extends ThemeExtension<AppTypography> {
  /// {@macro typography}
  static const AppTypography byDefault = AppTypography(
    // Display
    displayLarge: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 57,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.12,
      letterSpacing: -0.25,
      package: 'ui',
    ),
    displayMedium: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 45,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.15,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    displaySmall: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 36,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.22,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    // Headline
    headlineLarge: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 32,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.25,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    headlineMedium: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 28,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.28,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    headlineSmall: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 24,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    // Title
    titleLarge: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 22,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.27,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    titleBold: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 18,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: 'ui',
    ),
    titleMedium: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: 'ui',
    ),

    titleSmall: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      height: 1.42,
      letterSpacing: 0.1,
      package: 'ui',
    ),
    // Body
    bodyLarge: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      letterSpacing: 0.5,
      height: 1.5,
      package: 'ui',
    ),
    bodyMedium: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      letterSpacing: 0.25,
      height: 1.43,
      package: 'ui',
    ),
    bodySmall: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.4,
      package: 'ui',
    ),

    // Label
    labelLarge: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.43,
      letterSpacing: 0.1,
      package: 'ui',
    ),
    labelMedium: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.33,
      letterSpacing: 0.5,
      package: 'ui',
    ),
    labelSmall: TextStyle(
      fontFamily: 'OpenSans',
      fontSize: 11,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      height: 1.45,
      letterSpacing: 0.5,
      package: 'ui',
    ),
  );

  /// {@macro typography}
  const AppTypography({
    required this.displayLarge,
    required this.displayMedium,
    required this.displaySmall,
    required this.headlineLarge,
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleBold,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
  });

  // - Display - //

  /// Largest of the display styles.
  /// As the largest text on the screen, display styles are reserved for short,
  /// important text or numerals. They work best on large screens.
  final TextStyle displayLarge;

  /// Middle size of the display styles.
  /// As the largest text on the screen, display styles are reserved for short,
  /// important text or numerals. They work b t on large screens.
  final TextStyle displayMedium;

  /// Smallest of the display styles.
  /// As the largest text on the screen, display styles are reserved for short,
  /// important text or numerals. They work best on large screens.
  final TextStyle displaySmall;

  // - Headline - //

  /// Largest of the headline styles.
  /// Headline styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle headlineLarge;

  /// Middle size of the headline styles.
  /// Headline styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle headlineMedium;

  /// Smallest of the headline styles.
  /// Headline styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle headlineSmall;

  // - Title - //
  /// Largest of the title styles.
  /// Title styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle titleLarge;

  /// Bold title style.
  /// Title styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle titleBold;

  /// Middle size of the title styles.
  /// Title styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle titleMedium;

  /// Smallest of the title styles.
  /// Title styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle titleSmall;

  // - Body - //
  /// Largest of the body styles.
  /// Body styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle bodyLarge;

  /// Middle size of the body styles.
  /// Body styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle bodyMedium;

  /// Smallest of the body styles.
  /// Body styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle bodySmall;

  // - Label - //
  /// Largest of the label styles.
  /// Label styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle labelLarge;

  /// Middle size of the label styles.
  /// Label styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle labelMedium;

  /// Smallest of the label styles.
  /// Label styles are reserved for large text that is important to the
  /// content of the screen. They work best on large screens.
  final TextStyle labelSmall;

  @override
  Object get type => AppTypography;

  /// Text theme for the app.
  static TextTheme textTheme({Color? displayColor, Color? bodyColor}) => TextTheme(
    displayLarge: byDefault.displayLarge.copyWith(color: displayColor),
    displayMedium: byDefault.displayMedium.copyWith(color: displayColor),
    displaySmall: byDefault.displaySmall.copyWith(color: displayColor),
    headlineLarge: byDefault.headlineLarge.copyWith(color: displayColor),
    headlineMedium: byDefault.headlineMedium.copyWith(color: displayColor),
    headlineSmall: byDefault.headlineSmall.copyWith(color: displayColor),
    titleLarge: byDefault.titleLarge.copyWith(color: displayColor),
    titleMedium: byDefault.titleMedium.copyWith(color: bodyColor),
    titleSmall: byDefault.titleSmall.copyWith(color: bodyColor),
    bodyLarge: byDefault.bodyLarge.copyWith(color: bodyColor),
    bodyMedium: byDefault.bodyMedium.copyWith(color: bodyColor),
    bodySmall: byDefault.bodySmall.copyWith(color: bodyColor),
    labelLarge: byDefault.labelLarge.copyWith(color: bodyColor),
    labelMedium: byDefault.labelMedium.copyWith(color: bodyColor),
    labelSmall: byDefault.labelSmall.copyWith(color: bodyColor),
  );

  @override
  ThemeExtension<AppTypography> copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleBold,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
  }) => AppTypography(
    displayLarge: displayLarge ?? this.displayLarge,
    displayMedium: displayMedium ?? this.displayMedium,
    displaySmall: displaySmall ?? this.displaySmall,
    headlineLarge: headlineLarge ?? this.headlineLarge,
    headlineMedium: headlineMedium ?? this.headlineMedium,
    headlineSmall: headlineSmall ?? this.headlineSmall,
    titleLarge: titleLarge ?? this.titleLarge,
    titleBold: titleBold ?? this.titleBold,
    titleMedium: titleMedium ?? this.titleMedium,
    titleSmall: titleSmall ?? this.titleSmall,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySmall: bodySmall ?? this.bodySmall,
    labelLarge: labelLarge ?? this.labelLarge,
    labelMedium: labelMedium ?? this.labelMedium,
    labelSmall: labelSmall ?? this.labelSmall,
  );

  @override
  ThemeExtension<AppTypography> lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      displayLarge: TextStyle.lerp(displayLarge, other.displayLarge, t) ?? displayLarge,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t) ?? displayMedium,
      displaySmall: TextStyle.lerp(displaySmall, other.displaySmall, t) ?? displaySmall,
      headlineLarge: TextStyle.lerp(headlineLarge, other.headlineLarge, t) ?? headlineLarge,
      headlineMedium: TextStyle.lerp(headlineMedium, other.headlineMedium, t) ?? headlineMedium,
      headlineSmall: TextStyle.lerp(headlineSmall, other.headlineSmall, t) ?? headlineSmall,
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t) ?? titleLarge,
      titleBold: TextStyle.lerp(titleBold, other.titleBold, t) ?? titleBold,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t) ?? titleMedium,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t) ?? titleSmall,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t) ?? bodyLarge,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t) ?? bodyMedium,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t) ?? bodySmall,
      labelLarge: TextStyle.lerp(labelLarge, other.labelLarge, t) ?? labelLarge,
      labelMedium: TextStyle.lerp(labelMedium, other.labelMedium, t) ?? labelMedium,
      labelSmall: TextStyle.lerp(labelSmall, other.labelSmall, t) ?? labelSmall,
    );
  }
}
