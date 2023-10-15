import 'dart:async';
import 'dart:convert';

import 'package:auth_app/app/settings/dao/app_preferences_dao.dart';
import 'package:auth_app/app/settings/dao/app_secure_preferences_dao.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:uuid/uuid.dart';

abstract class ISettingsRepository {
  int? get themeColor;
  FutureOr<void> setThemeColor(int? value);

  String? get themeMode;
  FutureOr<void> setThemeMode(String? value);

  String? get locale;
  FutureOr<void> setLocale(String value);

  String get installationId;

  bool get firstStart;
  FutureOr<void> setSecondStart();

  IUserInfo? get user;
  FutureOr<void> setUser(IUserInfo? value);

  Future<AccessCredentials?> getCredentials();
  FutureOr<void> setCredentials(AccessCredentials? value);
}

class SettingsRepository implements ISettingsRepository {
  SettingsRepository({
    required AppPreferencesDao preferences,
    required AppSecurePreferencesDao securePreferences,
  })  : _preferences = preferences,
        _securePreferences = securePreferences {
    _installationId = preferences.installationId.value ??
        () {
          final installationId = const Uuid().v1();
          preferences.installationId.set(installationId);
          return installationId;
        }();
  }

  final AppPreferencesDao _preferences;
  final AppSecurePreferencesDao _securePreferences;

  @override
  IUserInfo? get user {
    final js = _preferences.user.value;
    if (js.isNullOrSpace) return null;

    return UserInfo.fromJson(json.decode(js!) as Map<String, dynamic>);
  }

  @override
  FutureOr<void> setUser(IUserInfo? value) async {
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
  FutureOr<void> setCredentials(AccessCredentials? value) async {
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
  String? get themeMode => _preferences.themeMode.value;
  @override
  FutureOr<void> setThemeMode(String? value) => _preferences.themeMode.setIfNullRemove(value);

  @override
  int? get themeColor => _preferences.themeColor.value;
  @override
  FutureOr<void> setThemeColor(int? value) => _preferences.themeColor.setIfNullRemove(value);

  @override
  String? get locale => _preferences.locale.value;
  @override
  FutureOr<void> setLocale(String value) => _preferences.locale.set(value);

  late final String _installationId;
  @override
  String get installationId => _installationId;

  @override
  bool get firstStart => _preferences.firstStart.value ?? true;
  @override
  FutureOr<void> setSecondStart() => _preferences.firstStart.set(false);
}
