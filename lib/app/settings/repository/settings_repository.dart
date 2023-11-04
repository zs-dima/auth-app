import 'dart:async';
import 'dart:convert';

import 'package:auth_app/app/settings/dao/app_preferences_dao.dart';
import 'package:auth_app/app/settings/dao/app_secure_preferences_dao.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:uuid/uuid.dart';

abstract class ISettingsRepository {
  int? get themeColor;
  String? get themeMode;
  String? get locale;
  String get installationId;

  bool get firstStart;
  IUserInfo? get user;
  Future<void> setThemeColor(int? value);

  Future<void> setThemeMode(String? value);

  Future<void> setLocale(String value);

  Future<void> setSecondStart();

  Future<void> setUser(IUserInfo? value);

  Future<AccessCredentials?> getCredentials();
  Future<void> setCredentials(AccessCredentials? value);
}

class SettingsRepository implements ISettingsRepository {
  @override
  late final String installationId;

  final AppPreferencesDao _preferences;
  final AppSecurePreferencesDao _securePreferences;

  @override
  IUserInfo? get user {
    final js = _preferences.user.value;
    if (js.isNullOrSpace) return null;

    return UserInfo.fromJson(json.decode(js!) as Map<String, dynamic>);
  }

  @override
  String? get themeMode => _preferences.themeMode.value;
  @override
  int? get themeColor => _preferences.themeColor.value;
  @override
  String? get locale => _preferences.locale.value;
  @override
  bool get firstStart => _preferences.firstStart.value ?? true;

  SettingsRepository({
    required AppPreferencesDao preferences,
    required AppSecurePreferencesDao securePreferences,
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
    if (value != user) {
      if (value == null) {
        await _preferences.user.remove();
      } else {
        final js = json.encode(value.toJson());
        await _preferences.user.set(js);
      }
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
    if (value != await getCredentials()) {
      if (value == null) {
        await _securePreferences.credentials.remove();
      } else {
        final js = json.encode(value.toJson());
        await _preferences.user.set(js);
      }
    }
  }

  @override
  Future<void> setThemeMode(String? value) => _preferences.themeMode.setIfNullRemove(value);

  @override
  Future<void> setThemeColor(int? value) => _preferences.themeColor.setIfNullRemove(value);

  @override
  Future<void> setLocale(String value) => _preferences.locale.set(value);

  @override
  Future<void> setSecondStart() => _preferences.firstStart.set(false);
}
