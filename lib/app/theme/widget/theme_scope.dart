import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/theme/bloc/theme_bloc.dart';
import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

extension ThemeScopeX on BuildContext {
  /// {@macro theme_controller}
  ThemeController theme({bool listen = false}) => ThemeScope.of(this);
}

/// {@template theme_controller}
/// A controller that holds and operates the app theme.
/// {@endtemplate}
abstract interface class ThemeController {
  /// Get the current theme.
  ///
  /// This is handy to be obtained in the [MaterialApp].
  AppTheme get theme;

  /// Set the theme to [theme].
  void setTheme(AppTheme theme);
}

/// {@template theme_scope}
/// Theme scope is responsible for handling theme-related stuff.
///
/// See [ThemeController] for more info.
/// {@endtemplate}
class ThemeScope extends StatefulWidget {
  /// {@macro theme_scope}
  const ThemeScope({
    required this.child,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Get the [ThemeController] of the closest [ThemeScope] ancestor.
  static ThemeController of(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_ThemeScopeInherited>(listen: listen).controller;

  @override
  State<ThemeScope> createState() => _ThemeScopeState();
}

class _ThemeScopeState extends State<ThemeScope> implements ThemeController {
  @override
  void setTheme(AppTheme theme) => _bloc.add(
        ThemeEvent.setTheme(theme),
      );

  @override
  AppTheme get theme => _state.theme;

  late ThemeState _state;

  late final ThemeBloc _bloc;

  late ScreenSize _screenSize;

  StreamSubscription<void>? _subscription;

  void _listener(ThemeState state) {
    if (!mounted || _state == state) return;

    setState(() => _state = state);
  }

  @override
  void initState() {
    super.initState();

    _bloc = ThemeBloc(
      context.dependencies.themeRepository,
      _screenSize = ScreenUtil.screenSize(),
    );

    _state = _bloc.state;

    _subscription = _bloc.stream.listen(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final screenSize = context.screenSize;
    if (_screenSize != screenSize) {
      _screenSize = screenSize;
      _bloc.add(
        ThemeEvent.setTheme(
          AppTheme(
            mode: _state.theme.mode,
            seed: _state.theme.seed,
            size: screenSize,
          ),
        ),
      );
    }
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
    properties.add(DiagnosticsProperty<AppTheme>('theme', theme));
  }

  @override
  Widget build(BuildContext context) => _ThemeScopeInherited(
        controller: this,
        state: _state,
        child: AnimatedTheme(
          data: _state.theme.computeTheme(context),
          child: widget.child,
        ),
      );
}

class _ThemeScopeInherited extends InheritedWidget {
  const _ThemeScopeInherited({
    required this.controller,
    required this.state,
    required super.child,
  });

  /// {@macro theme_scope}
  final ThemeController controller;

  /// The current theme state.
  final ThemeState state;

  @override
  bool updateShouldNotify(covariant _ThemeScopeInherited oldWidget) => oldWidget.state != state;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ThemeState>('themeState', state),
    );
  }
}
