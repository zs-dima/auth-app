import 'dart:async';

import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
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

    /// Application text scale
    double? textScale,
  }) = _IdleSettingsState;

  /// Processing state for the [SettingsController].
  const factory SettingsState.processing({
    /// The current locale.
    Locale? locale,

    /// The current theme mode.
    AppTheme? appTheme,

    /// Application text scale
    double? textScale,
  }) = _ProcessingSettingsState;

  /// Error state for the [SettingsController].
  const factory SettingsState.error({
    /// The error message.
    required Object cause,

    /// The current locale.
    Locale? locale,

    /// The current theme mode.
    AppTheme? appTheme,

    /// Application text scale
    double? textScale,
  }) = _ErrorSettingsState;
}

final class SettingsController extends StateController<SettingsState> with SequentialControllerHandler {
  SettingsController({required ISettingsRepository repository, required super.initialState}) : _repository = repository;

  final ISettingsRepository _repository;
  StreamSubscription<SettingsState>? _userSubscription;

  void updateTheme(AppTheme appTheme) => handle(
    () async {
      setState(
        SettingsState.processing(
          appTheme: state.appTheme,
          locale: state.locale,
          textScale: state.textScale,
        ),
      );
      await _repository.setThemeColor(appTheme.seed);
      await _repository.setThemeMode(appTheme.mode);
    },
    error: (error, _) async => setState(
      SettingsState.error(
        appTheme: state.appTheme,
        locale: state.locale,
        textScale: state.textScale,
        cause: error,
      ),
    ),
    done: () async => setState(
      SettingsState.idle(appTheme: appTheme, locale: state.locale, textScale: state.textScale),
    ),
    name: 'updateTheme',
  );

  void updateLocale(Locale locale) => handle(
    () async {
      setState(
        SettingsState.processing(
          appTheme: state.appTheme,
          locale: state.locale,
          textScale: state.textScale,
        ),
      );
      await _repository.setLocale(locale);
    },
    error: (error, _) async => setState(
      SettingsState.error(
        appTheme: state.appTheme,
        locale: state.locale,
        textScale: state.textScale,
        cause: error,
      ),
    ),
    done: () async => setState(
      SettingsState.idle(appTheme: state.appTheme, locale: locale, textScale: state.textScale),
    ),
    name: 'updateLocale',
  );

  void updateTextScale(double textScale) => handle(
    () async {
      setState(
        SettingsState.processing(
          appTheme: state.appTheme,
          locale: state.locale,
          textScale: state.textScale,
        ),
      );
      await _repository.setTextScale(textScale);
    },
    error: (error, _) async => setState(
      SettingsState.error(
        appTheme: state.appTheme,
        locale: state.locale,
        textScale: state.textScale,
        cause: error,
      ),
    ),
    done: () async => setState(
      SettingsState.idle(appTheme: state.appTheme, locale: state.locale, textScale: textScale),
    ),
    name: 'updateTextScale',
  );

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
