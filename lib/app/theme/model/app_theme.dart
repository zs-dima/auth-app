import 'package:auth_app/app/theme/extension/theme_sizes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

/// {@template app_theme}
/// An immutable class that holds properties needed
/// to build a [ThemeData] for the app.
/// {@endtemplate}
@immutable
final class AppTheme with Diagnosticable {
  /// The type of theme to use.
  final ThemeMode mode;

  /// The seed color to generate the [ColorScheme] from.
  final Color? seed;

  final ScreenSize size;

  /// {@macro app_theme}
  AppTheme({
    required this.mode,
    this.seed,
    required this.size,
  })  : darkTheme = ThemeData(
          colorSchemeSeed: seed,
          brightness: Brightness.dark,
          useMaterial3: true,
          extensions: [ThemePaddings.adaptive(size)],
        ),
        lightTheme = ThemeData(
          colorSchemeSeed: seed,
          brightness: Brightness.light,
          useMaterial3: true,
          extensions: [ThemePaddings.adaptive(size)],
        );

  /// Light mode [AppTheme].
  static AppTheme light(ScreenSize screenSize) => AppTheme(
        mode: ThemeMode.light,
        size: screenSize,
      );

  /// Dark mode [AppTheme].
  static AppTheme dark(ScreenSize screenSize) => AppTheme(
        mode: ThemeMode.dark,
        size: screenSize,
      );

  /// System mode [AppTheme].
  static AppTheme system(ScreenSize screenSize) => AppTheme(
        mode: ThemeMode.system,
        size: screenSize,
      );

  /// All the system [AppTheme]s.
  static List<AppTheme> values(ScreenSize screenSize) => List.generate(
        Colors.primaries.length,
        (index) => AppTheme(
          seed: Colors.primaries[index],
          mode: ThemeMode.system,
          size: screenSize,
        ),
      );

  /// The dark [ThemeData] for this [AppTheme].
  final ThemeData darkTheme;

  /// The light [ThemeData] for this [AppTheme].
  final ThemeData lightTheme;

  /// The [ThemeData] for this [AppTheme].
  /// This is computed based on the [mode].
  ///
  /// Could be useful for theme showcase.
  ThemeData computeTheme(BuildContext context) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
        return View.of(context).platformDispatcher.platformBrightness == Brightness.dark //
            ? darkTheme
            : lightTheme;
    }
  }

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

  @override
  int get hashCode => mode.hashCode ^ seed.hashCode ^ size.hashCode;
}
