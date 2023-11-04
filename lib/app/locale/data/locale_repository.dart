import 'dart:async';
import 'dart:ui';

import 'package:auth_app/app/locale/data/i_locale_repository.dart';
import 'package:auth_app/app/locale/data/locale_datasource.dart';

/// {@macro locale_datasource}
final class LocaleRepository implements ILocaleRepository {
  final ILocaleDataSource _localeDataSource;

  /// {@macro locale_datasource}
  const LocaleRepository(this._localeDataSource);

  @override
  Future<void> setLocale(Locale locale) => _localeDataSource.setLocale(locale);

  @override
  Locale? loadLocaleFromCache() => _localeDataSource.loadLocaleFromCache();
}
