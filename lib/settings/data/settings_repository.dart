import 'dart:async';
import 'dart:convert';

import 'package:auth_app/settings/data/dao/app_preferences_dao.dart';
import 'package:auth_app/settings/data/dao/app_secure_preferences_dao.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class ISettingsRepository {
  Color? get themeColor;
  ThemeMode? get themeMode;
  Locale? get locale;
  double? get textScale;
  String get installationId;
  bool get firstStart;
  UserId get userId;

  /// Whether crash reports may be sent. Defaults to true when never set (opt-out).
  bool get sendCrashReports;

  Future<void> setSendCrashReports(bool value);
  Future<void> setThemeColor(Color? value);
  Future<void> setThemeMode(ThemeMode? value);
  Future<void> setLocale(Locale value);
  Future<void> setTextScale(double locale);
  Future<void> setSecondStart();
  Future<void> setUserId(UserId userId);

  Future<AccessCredentials?> getCredentials();
  Future<void> setCredentials(AccessCredentials? value);
}

class SettingsRepository implements ISettingsRepository {
  SettingsRepository({
    required this._preferences,
    required this._securePreferences,
    required this.codec,
  }) {
    installationId =
        _preferences.installationId.value ??
        () {
          final id = const Uuid().v1();
          _preferences.installationId.set(id);
          return id;
        }();
  }

  final AppPreferencesDao _preferences;
  final AppSecurePreferencesDao _securePreferences;

  @override
  late final String installationId;

  /// Codec for [ThemeMode]
  final Codec<ThemeMode, String> codec;

  @override
  ThemeMode? get themeMode => //
      _preferences.themeMode.value == null ? null : codec.decode(_preferences.themeMode.value!);

  @override
  Color? get themeColor => //
      _preferences.themeColor.value == null ? null : .new(_preferences.themeColor.value!);

  @override
  Locale? get locale {
    final languageCode = _preferences.locale.value;
    if (languageCode == null) return null;
    return Locale.fromSubtags(languageCode: languageCode);
  }

  @override
  double? get textScale => _preferences.textScale.value;

  @override
  bool get firstStart => _preferences.firstStart.value ?? true;

  @override
  UserId get userId => _preferences.userId.value ?? UserIdX.empty;

  @override
  bool get sendCrashReports => _preferences.sendCrashReports.value ?? true;

  @override
  Future<AccessCredentials?> getCredentials() async {
    final js = await _securePreferences.credentials.get();
    if (js.isNullOrSpace) return null;
    try {
      return AccessCredentials.fromJson(json.decode(js!) as Map<String, dynamic>);
    } on Object catch (e, st) {
      // Sanitize: FormatException.source carries the WHOLE decrypted blob, and warning-level logs
      // reach Sentry (§13).
      Error.throwWithStackTrace(FormatException('Malformed persisted credentials (${e.runtimeType})'), st);
    }
  }

  @override
  Future<void> setCredentials(AccessCredentials? value) async {
    // Clearing must NEVER depend on decoding the existing blob: a corrupt / schema-incompatible value
    // makes getCredentials() throw, and if removal were gated on that read the session would wedge
    // permanently — restore()'s recovery (which calls setCredentials(null)) and sign-in's persist
    // could never overwrite it. So the null path removes unconditionally.
    if (value == null) {
      await _securePreferences.credentials.remove();
      return;
    }
    // Dedup guard: skip the write when the stored value already matches. An undecodable existing blob
    // is treated as "different" so the new value overwrites it (self-healing) instead of throwing.
    AccessCredentials? current;
    try {
      current = await getCredentials();
    } on Object {
      current = null;
    }
    if (value == current) return;
    await _securePreferences.credentials.set(json.encode(value.toJson()));
  }

  @override
  Future<void> setSendCrashReports(bool value) => _preferences.sendCrashReports.set(value);

  @override
  Future<void> setThemeMode(ThemeMode? theme) => //
      _preferences.themeMode.setIfNullRemove(theme == null ? null : codec.encode(theme));

  @override
  Future<void> setThemeColor(Color? seed) => _preferences.themeColor.setIfNullRemove(seed?.toARGB32());

  @override
  Future<void> setLocale(Locale locale) => _preferences.locale.set(locale.languageCode);

  @override
  Future<void> setTextScale(double scale) => _preferences.textScale.set(scale);

  @override
  Future<void> setSecondStart() => _preferences.firstStart.set(false);

  @override
  Future<void> setUserId(UserId userId) => _preferences.userId.set(userId);
}
