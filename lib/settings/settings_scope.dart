import 'package:auth_app/_core/app.dart';
import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/settings/controller/settings_controller.dart';
import 'package:control/control.dart';
import 'package:ui/ui.dart';

/// {@template theme_scope_controller}
/// A controller that holds and operates the app theme.
/// {@endtemplate}
abstract interface class ThemeScopeController {
  /// Get the current [AppTheme].
  AppTheme get theme;

  /// Set the theme.
  void setTheme(AppTheme theme);

  /// Set the theme mode to [themeMode].
  void setThemeMode(ThemeMode themeMode);

  /// Set the theme accent color to [color].
  void setThemeSeedColor(Color? color);
}

/// {@template locale_scope_controller}
/// A controller that holds and operates the app locale.
/// {@endtemplate}
abstract interface class LocaleScopeController {
  /// Get the current [Locale]
  Locale get locale;

  /// Set locale to [locale].
  void setLocale(Locale locale);
}

/// {@template settings_scope_controller}
/// A controller that holds and operates the app settings.
/// {@endtemplate}
abstract interface class SettingsScopeController implements ThemeScopeController, LocaleScopeController {}

enum _SettingsScopeAspect {
  /// The theme aspect.
  theme,

  /// The locale aspect.
  locale,
}

/// {@template settings_scope}
/// Settings scope is responsible for handling settings-related stuff.
///
/// For example, it holds facilities to change
/// - theme seed color
/// - theme mode
/// - locale
/// {@endtemplate}
class SettingsScope extends StatefulWidget {
  /// {@macro settings_scope}
  const SettingsScope({
    required this.child,
    required this.settingsController,
    super.key,
  });

  /// Get the [SettingsScopeController] of the closest [SettingsScope] ancestor.
  static SettingsScopeController of(
    BuildContext context, {
    bool listen = true,
  }) => context.scopeOf<_InheritedSettingsScope>(listen: listen).controller;

  /// Get the [ThemeScopeController] of the closest [SettingsScope] ancestor.
  static ThemeScopeController themeOf(BuildContext context) => context
      .inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(
        aspect: _SettingsScopeAspect.theme,
      )
      .controller;

  /// Get the [LocaleScopeController] of the closest [SettingsScope] ancestor.
  static LocaleScopeController localeOf(BuildContext context) => context
      .inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(
        aspect: _SettingsScopeAspect.locale,
      )
      .controller;

  /// The child widget.
  final Widget child;

  /// The [SettingsController] instance.
  final SettingsController settingsController;

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

/// State for widget SettingsScope
class _SettingsScopeState extends State<SettingsScope> implements SettingsScopeController {
  @override
  void setLocale(Locale locale) {
    widget.settingsController.updateLocale(locale);
  }

  @override
  void setTheme(AppTheme theme) => widget.settingsController.updateTheme(theme);

  @override
  void setThemeMode(ThemeMode themeMode) => widget.settingsController.updateTheme(
    AppTheme(mode: themeMode, seed: theme.seed, size: theme.size),
  );

  @override
  void setThemeSeedColor(Color? color) => widget.settingsController.updateTheme(
    AppTheme(mode: theme.mode, seed: color, size: theme.size),
  );

  @override
  Locale get locale => widget.settingsController.state.locale ?? Localization.computeDefaultLocale;

  @override
  AppTheme get theme => widget.settingsController.state.appTheme ?? AppTheme.system(ScreenUtil.screenSize);

  @override
  Widget build(BuildContext context) => StateConsumer<SettingsController, SettingsState>(
    controller: widget.settingsController,
    builder: (context, state, _) => _InheritedSettingsScope(
      controller: this,
      state: state,
      child: widget.child,
    ),
  );
}

class _InheritedSettingsScope extends InheritedModel<_SettingsScopeAspect> {
  const _InheritedSettingsScope({
    required this.controller,
    required this.state,
    required super.child,
  });

  final SettingsScopeController controller;
  final SettingsState state;

  @override
  bool updateShouldNotify(_InheritedSettingsScope oldWidget) => state != oldWidget.state;

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedSettingsScope oldWidget,
    Set<_SettingsScopeAspect> dependencies,
  ) {
    var shouldNotify = false;

    if (dependencies.contains(_SettingsScopeAspect.theme)) {
      shouldNotify = shouldNotify || state.appTheme != oldWidget.state.appTheme;
    }

    if (dependencies.contains(_SettingsScopeAspect.locale)) {
      final locale = state.locale?.languageCode;
      final oldLocale = oldWidget.state.locale?.languageCode;

      shouldNotify = shouldNotify || locale != oldLocale;
    }

    return shouldNotify;
  }
}
