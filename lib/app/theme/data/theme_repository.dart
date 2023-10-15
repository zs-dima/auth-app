import 'dart:async';

import 'package:auth_app/app/theme/data/i_theme_repository.dart';
import 'package:auth_app/app/theme/data/theme_datasource.dart';
import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:ui_tool/ui_tool.dart';

/// {@macro theme_repository}
final class ThemeRepository implements IThemeRepository {
  final IThemeDataSource _dataSource;

  /// {@macro theme_repository}
  const ThemeRepository(this._dataSource);

  @override
  Future<void> setTheme(AppTheme light) => _dataSource.setTheme(light);

  @override
  AppTheme? loadAppThemeFromCache(ScreenSize size) => _dataSource.loadThemeFromCache(size);
}
