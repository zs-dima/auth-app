import 'package:auth_app/app/theme/data/i_theme_repository.dart';
import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ui_tool/ui_tool.dart';

part 'theme_bloc.freezed.dart';

@freezed
class ThemeEvent with _$ThemeEvent {
  const factory ThemeEvent.setTheme(AppTheme theme) = _setTheme;
}

@freezed
class ThemeState with _$ThemeState {
  const factory ThemeState.idle(AppTheme theme) = _idle;
}

/// {@template theme_bloc}
/// Business logic components that can switch themes.
///
/// It communicates with provided repository to persist the theme.
///
/// Should not be used directly, instead use [ThemeScope].
/// It operates ThemeBloc under the hood.
/// {@endtemplate}
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IThemeRepository _themeRepository;

  /// Creates a new [ThemeBloc] with the given [IThemeRepository].
  ///
  /// The initial state is set to [ThemeState.idle] with the locale loaded from
  /// the cache, or the default locale of 'en' if no locale is found in the cache.
  ///
  /// Responds to [ThemeEvent.setTheme] events.
  ThemeBloc(
    IThemeRepository themeRepository,
    ScreenSize screenSize,
  )   : _themeRepository = themeRepository,
        super(
          ThemeState.idle(
            themeRepository.loadAppThemeFromCache(screenSize) ?? AppTheme.system(screenSize),
          ),
        ) {
    on(onEvents);
  }

  void onEvents(ThemeEvent event, Emitter emit) => event.when(
        setTheme: (AppTheme theme) {
          emit(ThemeState.idle(theme));
          _themeRepository.setTheme(theme).ignore();
        },
      );
}
