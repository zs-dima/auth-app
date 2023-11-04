import 'dart:async';
import 'dart:ui';

import 'package:auth_app/app/settings/repository/settings_repository.dart';

/// {@template locale_datasource}
/// [ILocaleDataSource] is an entry point to the locale data layer.
///
/// This is used to set and get locale.
/// {@endtemplate}
abstract interface class ILocaleDataSource {
  /// Set locale
  Future<void> setLocale(Locale locale);

  /// Get current locale from cache
  Locale? loadLocaleFromCache();
}

/// {@macro locale_datasource}
final class LocaleDataSource implements ILocaleDataSource {
  final ISettingsRepository _settings;

  /// {@macro locale_datasource}
  const LocaleDataSource({
    required ISettingsRepository settings,
  }) : _settings = settings;

  @override
  Future<void> setLocale(Locale locale) => _settings.setLocale(locale.toString());

  @override
  Locale? loadLocaleFromCache() {
    final locale = _settings.locale;

    if (locale != null) {
      final localeParts = locale.split('_');
      return Locale.fromSubtags(
        languageCode: localeParts.first,
        countryCode: localeParts.length > 1 ? localeParts[1] : null,
      );
    }

    return null;
  }
}
