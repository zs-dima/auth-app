import 'dart:async';

import 'package:auth_app/app/initialization/model/dependencies.dart';
import 'package:auth_app/app/locale/bloc/locale_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

extension LocaleScopeX on BuildContext {
  /// {@macro locale_controller}
  LocaleController locale({bool listen = false}) => LocaleScope.of(this);
}

/// {@template locale_controller}
/// A controller that holds and operates the app locale.
/// {@endtemplate}
abstract interface class LocaleController {
  /// Get the current locale.
  ///
  /// This is handy to be obtained in the [MaterialApp].
  Locale get locale;

  /// Set the locale to [locale].
  void setLocale(Locale locale);
}

/// [LocaleScope] is responsible for handling locale-related stuff.
///
/// Provides a [LocaleController] to hold and operate the app locale.
///
/// The [LocaleController] can be obtained using the static method [of], which
/// returns the [LocaleController] of the closest [LocaleScope] ancestor.
///
/// The [LocaleScope] is implemented as a [StatefulWidget] with a [State] that
/// implements the [LocaleController] interface. The [State] subscribes to the
/// [LocaleBloc] to listen for changes in the locale state, and updates the
/// [LocaleController] with the new locale when it changes.
class LocaleScope extends StatefulWidget {
  /// Creates a new [LocaleScope] with the given child widget.
  const LocaleScope({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Returns the [LocaleController] of the closest [LocaleScope] ancestor.
  ///
  /// If [listen] is true (the default), the returned [LocaleController] will
  /// rebuild the widget when the locale changes. If [listen] is false, the
  /// returned [LocaleController] will not rebuild the widget when the locale
  /// changes.
  static LocaleController of(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_LocaleScopeInherited>(listen: listen).controller;

  @override
  State<LocaleScope> createState() => _LocaleScopeState();
}

/// The [State] of the [LocaleScope] widget.
///
/// Implements the [LocaleController] interface to hold and operate the app
/// locale.
class _LocaleScopeState extends State<LocaleScope> implements LocaleController {
  late LocaleState _state;

  late final LocaleBloc _bloc;

  StreamSubscription<void>? _subscription;

  /// Listener for changes in the locale state.
  ///
  /// Updates the [_state] with the new locale state, and rebuilds the widget.
  void _listener(LocaleState state) {
    if (!mounted || _state == state) return;
    setState(() => _state = state);
  }

  @override
  void initState() {
    _bloc = LocaleBloc(
      localeRepository: context.dependencies.localeRepository,
    );

    _state = _bloc.state;

    _subscription = _bloc.stream.listen(_listener);
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _bloc.close();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Locale>('locale', locale));
  }

  @override
  void setLocale(Locale locale) => _bloc.add(
        LocaleEvent.setLocale(locale),
      );

  @override
  Locale get locale => _state.locale;

  @override
  Widget build(BuildContext context) => _LocaleScopeInherited(
        controller: this,
        state: _state,
        child: widget.child,
      );
}

/// An [InheritedWidget] that holds the [LocaleController] and the current
/// locale state.
class _LocaleScopeInherited extends InheritedWidget {
  const _LocaleScopeInherited({
    required this.controller,
    required this.state,
    required super.child,
  });

  /// The [LocaleController] to hold and operate the app locale.
  final LocaleController controller;

  /// The current locale state.
  final LocaleState state;

  @override
  bool updateShouldNotify(covariant _LocaleScopeInherited oldWidget) => oldWidget.state != state;
}
