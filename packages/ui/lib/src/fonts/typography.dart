import 'package:flutter/material.dart';

const kFontFamily = 'OpenSans';
const kPackage = 'ui';

enum AppTextStyle {
  displayLarge(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 57.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.12,
      letterSpacing: -0.25,
      package: kPackage,
    ),
  ),
  displayMedium(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 45.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.15,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),
  displaySmall(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 36.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.22,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),
  headlineLarge(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 32.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.25,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),
  headlineMedium(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 28.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.28,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),
  headlineSmall(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 24.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),
  titleLarge(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 22.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.27,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),

  titleBold(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 18.0,
      fontWeight: .w700,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: kPackage,
    ),
  ),
  titleMedium(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 16.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: kPackage,
    ),
  ),
  titleSmall(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.42,
      letterSpacing: 0.1,
      package: kPackage,
    ),
  ),
  bodyLarge(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 16.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: kPackage,
    ),
  ),
  bodyMedium(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.0,
      fontWeight: .w500,
      fontStyle: .normal,
      letterSpacing: 0.25,
      height: 1.43,
      package: kPackage,
    ),
  ),
  bodySmall(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 12.0,
      fontWeight: .w500,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.4,
      package: kPackage,
    ),
  ),
  labelLarge(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.0,
      fontWeight: .w400,
      fontStyle: .normal,
      height: 1.43,
      letterSpacing: 0.1,
      package: kPackage,
    ),
  ),

  labelMedium(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 12.0,
      fontWeight: .w400,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.5,
      package: kPackage,
    ),
  ),
  labelSmall(
    TextStyle(
      fontFamily: kFontFamily,
      fontSize: 11.0,
      fontWeight: .w400,
      fontStyle: .normal,
      height: 1.45,
      letterSpacing: 0.5,
      package: kPackage,
    ),
  )
  ;

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
      fontFamily: kFontFamily,
      fontSize: 57.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.12,
      letterSpacing: -0.25,
      package: kPackage,
    ),
    displayMedium: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 45.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.15,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    displaySmall: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 36.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.22,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    // Headline
    headlineLarge: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 32.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.25,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    headlineMedium: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 28.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.28,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    headlineSmall: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 24.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    // Title
    titleLarge: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 22.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.27,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    titleBold: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 18.0,
      fontWeight: .w700,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.0,
      package: kPackage,
    ),
    titleMedium: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 16.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.5,
      letterSpacing: 0.15,
      package: kPackage,
    ),

    titleSmall: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.0,
      fontWeight: .normal,
      fontStyle: .normal,
      height: 1.42,
      letterSpacing: 0.1,
      package: kPackage,
    ),
    // Body
    bodyLarge: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 16.0,
      fontWeight: .normal,
      fontStyle: .normal,
      letterSpacing: 0.5,
      height: 1.5,
      package: kPackage,
    ),
    bodyMedium: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.0,
      fontWeight: .w500,
      fontStyle: .normal,
      letterSpacing: 0.25,
      height: 1.43,
      package: kPackage,
    ),
    bodySmall: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 12.0,
      fontWeight: .w500,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.4,
      package: kPackage,
    ),

    // Label
    labelLarge: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 14.0,
      fontWeight: .w400,
      fontStyle: .normal,
      height: 1.43,
      letterSpacing: 0.1,
      package: kPackage,
    ),
    labelMedium: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 12.0,
      fontWeight: .w400,
      fontStyle: .normal,
      height: 1.33,
      letterSpacing: 0.5,
      package: kPackage,
    ),
    labelSmall: TextStyle(
      fontFamily: kFontFamily,
      fontSize: 11.0,
      fontWeight: .w400,
      fontStyle: .normal,
      height: 1.45,
      letterSpacing: 0.5,
      package: kPackage,
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
  static TextTheme textTheme({Color? displayColor, Color? bodyColor}) => .new(
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
