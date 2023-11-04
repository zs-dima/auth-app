import 'dart:async';
import 'dart:convert';

import 'package:auth_app/app/settings/repository/settings_repository.dart';
import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

/// {@template theme_datasource}
/// [IThemeDataSource] is an entry point to the theme data layer.
///
/// This is used to set and get theme.
/// {@endtemplate}
abstract interface class IThemeDataSource {
  /// Set theme
  Future<void> setTheme(AppTheme theme);

  /// Get current theme from cache
  AppTheme? loadThemeFromCache(ScreenSize size);
}

/// {@macro theme_datasource}
final class ThemeDataSource implements IThemeDataSource {
  final ISettingsRepository _settings;

  /// {@macro theme_datasource}
  ThemeDataSource({required ISettingsRepository settings}) : _settings = settings;

  @override
  Future<void> setTheme(AppTheme theme) async {
    await _settings.setThemeColor(theme.seed?.value);
    await _settings.setThemeMode(_themeModeCodec.encode(theme.mode));
  }

  @override
  AppTheme? loadThemeFromCache(ScreenSize screenSize) {
    final seedColor = _settings.themeColor;
    final type = _settings.themeMode;

    if (type == null) return null;

    return AppTheme(
      seed: seedColor == null ? null : Color(seedColor),
      mode: _themeModeCodec.decode(type),
      size: screenSize,
    );
  }
}

const _themeModeCodec = _ThemeModeCodec();

final class _ThemeModeCodec extends Codec<ThemeMode, String> {
  @override
  Converter<String, ThemeMode> get decoder => const _ThemeModeDecoder();

  @override
  Converter<ThemeMode, String> get encoder => const _ThemeModeEncoder();
  const _ThemeModeCodec();
}

final class _ThemeModeDecoder extends Converter<String, ThemeMode> {
  const _ThemeModeDecoder();

  @override
  ThemeMode convert(String input) {
    switch (input) {
      case 'ThemeMode.dark':
        return ThemeMode.dark;

      case 'ThemeMode.light':
        return ThemeMode.light;

      case 'ThemeMode.system':
        return ThemeMode.system;

      default:
        // ignore: avoid-missing-interpolation
        throw ArgumentError.value(input, 'input', 'Cannot convert $input to ThemeMode');
    }
  }
}

final class _ThemeModeEncoder extends Converter<ThemeMode, String> {
  const _ThemeModeEncoder();

  @override
  String convert(ThemeMode input) {
    switch (input) {
      case ThemeMode.dark:
        return 'ThemeMode.dark';

      case ThemeMode.light:
        return 'ThemeMode.light';

      case ThemeMode.system:
        return 'ThemeMode.system';
    }
  }
}
