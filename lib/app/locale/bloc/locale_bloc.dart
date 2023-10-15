import 'dart:ui';

import 'package:auth_app/app/locale/data/i_locale_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_bloc.freezed.dart';

@freezed
class LocaleEvent with _$LocaleEvent {
  const factory LocaleEvent.setLocale(Locale locale) = _setLocale;
}

@freezed
class LocaleState with _$LocaleState {
  const factory LocaleState.idle(Locale locale) = _idle;
}

/// Business Logic Component (BLoC) for managing the app's locale.
///
/// Emits a [LocaleState] to represent the current locale state of the app.
/// Responds to [LocaleEvent]s to update the locale state.
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final ILocaleRepository _localeRepository;

  // ignore: comment_references
  /// Creates a new [LocaleBloc] with the given [LocaleRepository].
  ///
  /// The initial state is set to [LocaleState.idle] with the locale loaded from
  /// the cache, or the default locale of 'en' if no locale is found in the cache.
  ///
  /// Responds to [LocaleEvent.setLocale] events.
  LocaleBloc({
    required ILocaleRepository localeRepository,
  })  : _localeRepository = localeRepository,
        super(
          LocaleState.idle(
            localeRepository.loadLocaleFromCache() ?? const Locale('en_US'),
          ),
        ) {
    on(onEvents);
  }

  void onEvents(LocaleEvent event, Emitter emit) => event.when(
        setLocale: (Locale locale) {
          emit(LocaleState.idle(locale));
          _localeRepository.setLocale(locale);
        },
      );
}
