import 'dart:async';

import 'package:auth_app/app/settings/preferences/preferences_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template preferences_dao}
/// Class that provides seamless access to the shared preferences.
///
/// Inspired by https://pub.dev/packages/typed_preferences
/// {@endtemplate}
abstract base class PreferencesDao {
  final SharedPreferences _sharedPreferences;

  /// {@macro preferences_dao}
  PreferencesDao(this._sharedPreferences);

  /// Obtain [bool] entry from the preferences.
  PreferencesEntry<bool> boolEntry(String key) => _PreferencesEntry<bool>(
        key: key,
        sharedPreferences: _sharedPreferences,
      );

  /// Obtain [double] entry from the preferences.
  PreferencesEntry<double> doubleEntry(String key) => _PreferencesEntry<double>(
        key: key,
        sharedPreferences: _sharedPreferences,
      );

  /// Obtain [int] entry from the preferences.
  PreferencesEntry<int> intEntry(String key) => _PreferencesEntry<int>(
        key: key,
        sharedPreferences: _sharedPreferences,
      );

  /// Obtain [String] entry from the preferences.
  PreferencesEntry<String> stringEntry(String key) => _PreferencesEntry<String>(
        key: key,
        sharedPreferences: _sharedPreferences,
      );

  /// Obtain [Iterable<String>] entry from the preferences.
  PreferencesEntry<Iterable<String>> iterableStringEntry(String key) => _PreferencesEntry<Iterable<String>>(
        key: key,
        sharedPreferences: _sharedPreferences,
      );
}

final class _PreferencesEntry<T extends Object> extends PreferencesEntry<T> {
  @override
  final String key;

  final SharedPreferences _sharedPreferences;

  @override
  T? get value {
    final v = _sharedPreferences.get(key);
    if (v == null) return null;
    if (v is T) return v;

    throw Exception(
      'The value of $key is not of type ${T.runtimeType}',
    );
  }

  _PreferencesEntry({
    required SharedPreferences sharedPreferences,
    required this.key,
  }) : _sharedPreferences = sharedPreferences;

  @override
  Future<void> set(T value) async {
    await switch (value) {
      final int v => _sharedPreferences.setInt(key, v),
      final double v => _sharedPreferences.setDouble(key, v),
      final String v => _sharedPreferences.setString(key, v),
      final bool v => _sharedPreferences.setBool(key, v),
      final Iterable<String> v => _sharedPreferences.setStringList(
          key,
          v.toList(),
        ),
      _ => throw Exception(
          '$T is not a valid type for a preferences entry value.',
        ),
    };
  }

  @override
  Future<void> remove() async => _sharedPreferences.remove(key);
}
