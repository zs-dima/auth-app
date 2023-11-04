import 'dart:async';
import 'dart:ui';

/// {@template locale_datasource}
/// This is used to set and get locale.
/// {@endtemplate}
abstract interface class ILocaleRepository {
  /// Set locale
  Future<void> setLocale(Locale locale);

  /// Get current locale from cache
  Locale? loadLocaleFromCache();
}
