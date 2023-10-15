import 'dart:async';

import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:ui_tool/ui_tool.dart';

/// {@template theme_repository}
/// Repository which manages the current theme.
/// {@endtemplate}
abstract interface class IThemeRepository {
  /// Set theme
  Future<void> setTheme(AppTheme light);

  /// Observe current theme changes
  AppTheme? loadAppThemeFromCache(ScreenSize size);
}
