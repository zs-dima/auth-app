import 'dart:async';

import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:auth_app/feature/settings/data/settings_repository.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_controller.freezed.dart';

/// States for the [SettingsController].
@freezed
sealed class SettingsState with _$SettingsState {
  const SettingsState._();

  /// Idle state for the [SettingsController].
  const factory SettingsState.idle({
    /// The current locale.
    Locale? locale,

    /// The current theme mode.
    AppTheme? appTheme,
  }) = _IdleSettingsState;

  /// Processing state for the [SettingsController].
  const factory SettingsState.processing({
    /// The current locale.
    Locale? locale,

    /// The current theme mode.
    AppTheme? appTheme,
  }) = _ProcessingSettingsState;

  /// Error state for the [SettingsController].
  const factory SettingsState.error({
    /// The error message.
    required Object cause,

    /// The current locale.
    Locale? locale,

    /// The current theme mode.
    AppTheme? appTheme,
  }) = _ErrorSettingsState;
}

final class SettingsController extends StateController<SettingsState> with DroppableControllerHandler {
  final ISettingsRepository _repository;
  StreamSubscription<SettingsState>? _userSubscription;

  SettingsController({required ISettingsRepository repository, required super.initialState}) : _repository = repository;

  void updateTheme(AppTheme appTheme) => handle(
    () async {
      setState(SettingsState.processing(appTheme: state.appTheme, locale: state.locale));
      await _repository.setThemeColor(appTheme.seed);
      await _repository.setThemeMode(appTheme.mode);
    },
    error: (error, _) async =>
        setState(SettingsState.error(appTheme: state.appTheme, locale: state.locale, cause: error)),
    done: () async => setState(SettingsState.idle(appTheme: appTheme, locale: state.locale)),
  );

  void updateLocale(Locale locale) => handle(
    () async {
      setState(SettingsState.processing(appTheme: state.appTheme, locale: state.locale));
      await _repository.setLocale(locale);
    },
    error: (error, _) async =>
        setState(SettingsState.error(appTheme: state.appTheme, locale: state.locale, cause: error)),
    done: () async => setState(SettingsState.idle(appTheme: state.appTheme, locale: locale)),
  );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
