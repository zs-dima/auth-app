import 'dart:async';

import 'package:auth_app/app/settings/preferences/preferences_entry_async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

typedef PreferencesKeyCallback = Future<String> Function();

/// {@template preferences_dao}
/// Class that provides seamless access to the shared preferences.
/// {@endtemplate}
abstract base class SecurePreferencesDao {
  final FlutterSecureStorage _preferences;
  final PreferencesKeyCallback _keyPrefix;

  /// {@macro preferences_dao}

  SecurePreferencesDao(
    this._preferences, {
    required PreferencesKeyCallback keyPrefix,
  }) : _keyPrefix = keyPrefix;

  /// Obtain [String] entry from the preferences.
  PreferencesEntryAsync<String> stringEntry(String key) =>
      //
      _SecurePreferencesEntry<String>(
        key: key,
        keyPrefix: _keyPrefix,
        preferences: _preferences,
      );
}

final class _SecurePreferencesEntry<T extends Object> extends PreferencesEntryAsync<T> {
  final FlutterSecureStorage _preferences;
  final PreferencesKeyCallback _keyPrefix;
  final String _key;

  _SecurePreferencesEntry({
    required FlutterSecureStorage preferences,
    required PreferencesKeyCallback keyPrefix,
    required String key,
  })  : _preferences = preferences,
        _keyPrefix = keyPrefix,
        _key = key;

  @override
  Future<T?> get() async {
    final key = await _getKey();
    final value = await _preferences.read(key: key);
    return value as T?;
  }

  @override
  Future<void> set(T value) async {
    final key = await _getKey();
    await switch (value) {
      final String v => _preferences.write(key: key, value: v),
      _ => throw Exception(
          '$T is not a valid type for a preferences entry value.',
        ),
    };
  }

  @override
  Future<void> remove() async {
    final key = await _getKey();
    return _preferences.delete(key: key);
  }

  Future<String> _getKey() async {
    final keyPrefix = await _keyPrefix();
    return '${keyPrefix}_$_key';
  }
}
