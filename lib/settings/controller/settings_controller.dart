import 'package:auth_app/_core/message/user_facing_error.dart';
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

  // No `error` state. There was one, and nothing rendered it — and `done:` replaced it with
  // `idle` on the next microtask anyway, so a failed write was invisible twice over. A settings
  // write that fails now does the two things that are actually useful: it tells the user
  // (`reportFailure`) and it puts the control back where it was.
}

final class SettingsController extends StateController<SettingsState> with SequentialControllerHandler {
  SettingsController({
    required this._repository,
    required super.initialState,
  });

  final ISettingsRepository _repository;

  void updateTheme(AppTheme appTheme) => handle(
    () async {
      final (:locale, :textScale, appTheme: previous) = _snapshot;
      setState(SettingsState.processing(appTheme: previous, locale: locale, textScale: textScale));
      try {
        await _repository.setThemeColor(appTheme.seed);
        await _repository.setThemeMode(appTheme.mode);
      } on Object {
        // The success state used to be set in `done:`, which runs whether the write succeeded or
        // not: a theme that never reached storage stayed on screen until the next launch undid it.
        setState(SettingsState.idle(appTheme: previous, locale: locale, textScale: textScale));
        rethrow;
      }
      setState(SettingsState.idle(appTheme: appTheme, locale: locale, textScale: textScale));
    },
    error: (error, stackTrace) async => _failed('theme', error, stackTrace),
    name: 'updateTheme',
  );

  void updateLocale(Locale locale) => handle(
    () async {
      final (locale: previous, :textScale, :appTheme) = _snapshot;
      setState(SettingsState.processing(appTheme: appTheme, locale: previous, textScale: textScale));
      try {
        await _repository.setLocale(locale);
      } on Object {
        setState(SettingsState.idle(appTheme: appTheme, locale: previous, textScale: textScale));
        rethrow;
      }
      setState(SettingsState.idle(appTheme: appTheme, locale: locale, textScale: textScale));
    },
    error: (error, stackTrace) async => _failed('locale', error, stackTrace),
    name: 'updateLocale',
  );

  void updateTextScale(double textScale) => handle(
    () async {
      final (:locale, textScale: previous, :appTheme) = _snapshot;
      setState(SettingsState.processing(appTheme: appTheme, locale: locale, textScale: previous));
      try {
        await _repository.setTextScale(textScale);
      } on Object {
        setState(SettingsState.idle(appTheme: appTheme, locale: locale, textScale: previous));
        rethrow;
      }
      setState(SettingsState.idle(appTheme: appTheme, locale: locale, textScale: textScale));
    },
    error: (error, stackTrace) async => _failed('textScale', error, stackTrace),
    name: 'updateTextScale',
  );

  /// The three values, so a handler can restore what it found on a failed write.
  ({Locale? locale, double? textScale, AppTheme? appTheme}) get _snapshot =>
      (locale: state.locale, textScale: state.textScale, appTheme: state.appTheme);

  /// One report for a settings write that did not land.
  ///
  /// Storage failing is a condition, not a defect (a full disk, a revoked
  /// keychain entry), so it is a `warn` and does not file an issue — but the
  /// user must be told, because the control has just snapped back.
  void _failed(String key, Object error, StackTrace stackTrace) => reportFailure(
    'Settings | save | failed',
    error,
    stackTrace: stackTrace,
    caption: 'Could not save your settings.',
    meta: <String, Object?>{'app.settings.key': key},
    level: .warn,
  );
}
