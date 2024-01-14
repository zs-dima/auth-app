import 'dart:async';
import 'dart:convert';

import 'package:auth_app/app/settings/dao/app_preferences_dao.dart';
import 'package:auth_app/app/settings/dao/app_secure_preferences_dao.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class ISettingsRepository {
  Color? get themeColor;
  ThemeMode? get themeMode;
  Locale? get locale;
  String get installationId;

  bool get firstStart;
  IUserInfo? get user;
  Future<void> setThemeColor(Color? value);

  Future<void> setThemeMode(ThemeMode? value);

  Future<void> setLocale(Locale value);

  Future<void> setSecondStart();

  Future<void> setUser(IUserInfo? value);

  Future<AccessCredentials?> getCredentials();
  Future<void> setCredentials(AccessCredentials? value);
}

class SettingsRepository implements ISettingsRepository {
  @override
  late final String installationId;

  /// Codec for [ThemeMode]
  final Codec<ThemeMode, String> codec;

  final AppPreferencesDao _preferences;
  final AppSecurePreferencesDao _securePreferences;

  @override
  IUserInfo? get user {
    final js = _preferences.user.value;
    if (js.isNullOrSpace) return null;

    return UserInfo.fromJson(json.decode(js!) as Map<String, dynamic>);
  }

  @override
  ThemeMode? get themeMode => _preferences.themeMode.value == null //
      ? null
      : codec.decode(_preferences.themeMode.value!);

  @override
  Color? get themeColor => _preferences.themeColor.value == null //
      ? null
      : Color(_preferences.themeColor.value!);

  @override
  Locale? get locale {
    final languageCode = _preferences.locale.value;
    if (languageCode == null) return null;
    return Locale.fromSubtags(languageCode: languageCode);
  }

  @override
  bool get firstStart => _preferences.firstStart.value ?? true;

  SettingsRepository({
    required AppPreferencesDao preferences,
    required AppSecurePreferencesDao securePreferences,
    required this.codec,
  })  : _preferences = preferences,
        _securePreferences = securePreferences {
    installationId = preferences.installationId.value ??
        () {
          final id = const Uuid().v1();
          preferences.installationId.set(id);
          return id;
        }();
  }

  @override
  Future<void> setUser(IUserInfo? value) async {
    if (value == user) return;
    if (value == null) {
      await _preferences.user.remove();
    } else {
      final js = json.encode(value.toJson());
      await _preferences.user.set(js);
    }
  }

  @override
  Future<AccessCredentials?> getCredentials() async {
    final js = await _securePreferences.credentials.get();
    if (js.isNullOrSpace) return null;

    return AccessCredentials.fromJson(json.decode(js!) as Map<String, dynamic>);
  }

  @override
  Future<void> setCredentials(AccessCredentials? value) async {
    if (value == await getCredentials()) return;
    if (value == null) {
      await _securePreferences.credentials.remove();
    } else {
      final js = json.encode(value.toJson());
      await _preferences.user.set(js);
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode? theme) => //
      _preferences.themeMode.setIfNullRemove(
        theme == null ? null : codec.encode(theme),
      );

  @override
  Future<void> setThemeColor(Color? seed) => _preferences.themeColor.setIfNullRemove(seed?.value);

  @override
  Future<void> setLocale(Locale locale) => _preferences.locale.set(locale.languageCode);

  @override
  Future<void> setSecondStart() => _preferences.firstStart.set(false);
}
