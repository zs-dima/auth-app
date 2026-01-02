import 'package:auth_app/_core/theme/extension/theme_sizes.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/ui.dart';

/// {@template app_theme}
/// An immutable class that holds properties needed
/// to build a [ThemeData] for the app.
/// {@endtemplate}
@immutable
final class AppTheme with Diagnosticable {
  /// {@macro app_theme}
  AppTheme({required this.mode, this.seed, required this.size})
    : darkTheme = _$buildTheme(
        ThemeData(
          fontFamilyFallback: const ['Roboto'],
          colorSchemeSeed: seed,
          colorScheme: seed == null ? kDarkColorScheme : null,
          brightness: .dark,
          useMaterial3: true,
          extensions: [ThemePaddings.adaptive(size)],
        ),
      ),
      lightTheme = _$buildTheme(
        ThemeData(
          fontFamilyFallback: const ['Roboto'],
          colorSchemeSeed: seed,
          colorScheme: seed == null ? kLightColorScheme : null,
          brightness: .light,
          useMaterial3: true,
          extensions: [ThemePaddings.adaptive(size)],
        ),
      );

  /// Light mode [AppTheme].
  AppTheme.light(ScreenSize screenSize) : this(mode: .light, size: screenSize);

  /// Dark mode [AppTheme].
  AppTheme.dark(ScreenSize screenSize) : this(mode: .dark, size: screenSize);

  /// System mode [AppTheme].
  AppTheme.system(ScreenSize screenSize) : this(mode: .system, size: screenSize);

  /// The type of theme to use.
  final ThemeMode mode;

  /// The seed color to generate the [ColorScheme] from.
  final Color? seed;

  final ScreenSize size;

  /// The dark [ThemeData] for this [AppTheme].
  final ThemeData darkTheme;

  /// The light [ThemeData] for this [AppTheme].
  final ThemeData lightTheme;

  @override
  int get hashCode => Object.hash(mode, seed, size);

  /// All the system [AppTheme]s.
  static List<AppTheme> values(ScreenSize screenSize) => .generate(
    Colors.primaries.length,
    (index) => AppTheme(seed: Colors.primaries[index], mode: .system, size: screenSize),
  );

  /// The [ThemeData] for this [AppTheme].
  /// This is computed based on the [mode].
  ///
  /// Could be useful for theme showcase.
  ThemeData computeTheme(BuildContext context) => switch (mode) {
    .light => lightTheme,

    .dark => darkTheme,

    .system =>
      View.of(context).platformDispatcher.platformBrightness ==
              .dark //
          ? darkTheme
          : lightTheme,
  };

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(ColorProperty('seed', seed))
      ..add(EnumProperty<ThemeMode>('type', mode))
      ..add(DiagnosticsProperty<ScreenSize>('screenSize', size))
      ..add(DiagnosticsProperty<ThemeData>('lightTheme', lightTheme))
      ..add(DiagnosticsProperty<ThemeData>('darkTheme', darkTheme));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppTheme &&
          runtimeType == other.runtimeType &&
          seed == other.seed &&
          mode == other.mode &&
          size == other.size;
}

ThemeData _$buildTheme(ThemeData theme) {
  const borderSide = BorderSide(
    width: 1.0,
    color: Color.fromRGBO(0, 0, 0, 0.6), // Color.fromRGBO(43, 45, 39, 0.24)
    strokeAlign: BorderSide.strokeAlignInside,
  );
  const radius = BorderRadius.all(.circular(8.0));
  return theme.copyWith(
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      isCollapsed: false,
      isDense: false,
      filled: false,
      // filled: true,
      floatingLabelAlignment: .start,
      floatingLabelBehavior: .always,
      contentPadding: const .fromLTRB(16.0, 8.0, 4.0, 8.0),
      border: const OutlineInputBorder(borderRadius: radius, borderSide: borderSide),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: borderSide.copyWith(color: theme.colorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: borderSide.copyWith(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: borderSide.copyWith(color: theme.colorScheme.error),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: borderSide.copyWith(color: const Color.fromRGBO(0, 0, 0, 0.24)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: borderSide.copyWith(color: const Color.fromRGBO(0, 0, 0, 0.24)),
      ),
      outlineBorder: borderSide,
    ),
  );
}

const ColorScheme kLightColorScheme = ColorScheme(
  brightness: .light,
  primary: Color(0xFF1565C0),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFF90CAF9),
  onPrimaryContainer: Color(0xFF000000),
  primaryFixed: Color(0xFFC5DCF7),
  primaryFixedDim: Color(0xFF95BDE9),
  onPrimaryFixed: Color(0xFF072649),
  onPrimaryFixedVariant: Color(0xFF092F59),
  secondary: Color(0xFF5b6a78), // Color(0xFF039BE5),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFCBE6FF),
  onSecondaryContainer: Color(0xFF000000),
  secondaryFixed: Color(0xFFC2EAFE),
  secondaryFixedDim: Color(0xFF8DD5F8),
  onSecondaryFixed: Color(0xFF013F5D),
  onSecondaryFixedVariant: Color(0xFF014B6F),
  tertiary: Color(0xFF0277BD),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFBEDCFF),
  onTertiaryContainer: Color(0xFF000000),
  tertiaryFixed: Color(0xFFBFE3F8),
  tertiaryFixedDim: Color(0xFF8CC8EC),
  onTertiaryFixed: Color(0xFF002941),
  onTertiaryFixedVariant: Color(0xFF003452),
  error: Color(0xFFB00020),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFCD8DF),
  onErrorContainer: Color(0xFF000000),
  surface: Color(0xFFFCFCFC),
  onSurface: Color(0xFF111111),
  surfaceDim: Color(0xFFE0E0E0),
  surfaceBright: Color(0xFFFDFDFD),
  surfaceContainerLowest: Color(0xFFFFFFFF),
  surfaceContainerLow: Color(0xFFF8F8F8),
  surfaceContainer: Color(0xFFF3F3F3),
  surfaceContainerHigh: Color(0xFFEDEDED),
  surfaceContainerHighest: Color(0xFFE7E7E7),
  onSurfaceVariant: Color(0xFF393939),
  outline: Color(0xFF919191),
  outlineVariant: Color(0xFFD1D1D1),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFF2A2A2A),
  onInverseSurface: Color(0xFFF1F1F1),
  inversePrimary: Color(0xFFAEDFFF),
  surfaceTint: Color(0xFF1565C0),
);

const ColorScheme kDarkColorScheme = ColorScheme(
  brightness: .dark,
  primary: Color(0xFF90CAF9),
  onPrimary: Color(0xFF000000),
  primaryContainer: Color(0xFF0D47A1),
  onPrimaryContainer: Color(0xFFFFFFFF),
  primaryFixed: Color(0xFFC5DCF7),
  primaryFixedDim: Color(0xFF95BDE9),
  onPrimaryFixed: Color(0xFF072649),
  onPrimaryFixedVariant: Color(0xFF092F59),
  secondary: Color(0xFF81D4FA),
  onSecondary: Color(0xFF000000),
  secondaryContainer: Color(0xFF004B73),
  onSecondaryContainer: Color(0xFFFFFFFF),
  secondaryFixed: Color(0xFFC2EAFE),
  secondaryFixedDim: Color(0xFF8DD5F8),
  onSecondaryFixed: Color(0xFF013F5D),
  onSecondaryFixedVariant: Color(0xFF014B6F),
  tertiary: Color(0xFFE1F5FE),
  onTertiary: Color(0xFF000000),
  tertiaryContainer: Color(0xFF1A567D),
  onTertiaryContainer: Color(0xFFFFFFFF),
  tertiaryFixed: Color(0xFFBFE3F8),
  tertiaryFixedDim: Color(0xFF8CC8EC),
  onTertiaryFixed: Color(0xFF002941),
  onTertiaryFixedVariant: Color(0xFF003452),
  error: Color(0xFFCF6679),
  onError: Color(0xFF000000),
  errorContainer: Color(0xFFB1384E),
  onErrorContainer: Color(0xFFFFFFFF),
  surface: Color(0xFF080808),
  onSurface: Color(0xFFF1F1F1),
  surfaceDim: Color(0xFF060606),
  surfaceBright: Color(0xFF2C2C2C),
  surfaceContainerLowest: Color(0xFF010101),
  surfaceContainerLow: Color(0xFF0E0E0E),
  surfaceContainer: Color(0xFF151515),
  surfaceContainerHigh: Color(0xFF1D1D1D),
  surfaceContainerHighest: Color(0xFF282828),
  onSurfaceVariant: Color(0xFFCACACA),
  outline: Color(0xFF777777),
  outlineVariant: Color(0xFF414141),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE8E8E8),
  onInverseSurface: Color(0xFF2A2A2A),
  inversePrimary: Color(0xFF435A6A),
  surfaceTint: Color(0xFF90CAF9),
);
