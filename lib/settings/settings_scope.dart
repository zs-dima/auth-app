import 'package:auth_app/_core/localization/localization.dart';
import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
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

  /// Reset the theme settings to default values.
  void resetSettings();
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

/// {@template text_scale_scope_controller}
/// A controller that holds and operates the app text scale.
/// {@endtemplate}
abstract interface class TextScaleScopeController {
  /// Get the current [textScale]
  double get textScale;

  /// Set text scale to [textScale].
  void setTextScale(double textScale);
}

/// {@template settings_scope_controller}
/// A controller that holds and operates the app settings.
/// {@endtemplate}
abstract interface class SettingsScopeController
    implements ThemeScopeController, LocaleScopeController, TextScaleScopeController {}

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
  const SettingsScope({super.key, required this.child});

  /// Get the [SettingsScopeController] of the closest [SettingsScope] ancestor.
  static SettingsScopeController of(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_InheritedSettingsScope>(listen: listen).scope;

  /// Get the [ThemeScopeController] of the closest [SettingsScope] ancestor.
  static ThemeScopeController themeOf(BuildContext context) =>
      context.inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(aspect: _SettingsScopeAspect.theme).scope;

  /// Get the [LocaleScopeController] of the closest [SettingsScope] ancestor.
  static LocaleScopeController localeOf(BuildContext context) =>
      context.inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(aspect: _SettingsScopeAspect.locale).scope;

  /// Get the [TextScaleScopeController] of the closest [SettingsScope] ancestor.
  static TextScaleScopeController textScaleOf(BuildContext context) =>
      context.inheritFrom<_SettingsScopeAspect, _InheritedSettingsScope>(aspect: _SettingsScopeAspect.textScale).scope;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<SettingsScope> createState() => _SettingsScopeState();
}

/// State for widget SettingsScope.
class _SettingsScopeState extends State<SettingsScope> implements SettingsScopeController {
  late SettingsController _settingsController;

  @override
  void initState() {
    super.initState();

    final settings = context.dependencies.settings;
    _settingsController = SettingsController(
      repository: settings,
      initialState: SettingsState.idle(
        appTheme: AppTheme(
          mode: settings.themeMode ?? ThemeMode.system,
          seed: settings.themeColor,
          size: ScreenUtil.screenSize,
        ),
        locale: settings.locale,
      ),
    );
  }

  @override
  void dispose() {
    _settingsController.dispose();
    super.dispose();
  }

  @override
  void resetSettings() {
    _settingsController
      ..updateTheme(AppTheme(mode: ThemeMode.light, seed: null, size: ScreenUtil.screenSize))
      ..updateLocale(Localization.computeDefaultLocale)
      ..updateTextScale(1.0);
  }

  @override
  void setLocale(Locale locale) {
    _settingsController.updateLocale(locale);
  }

  @override
  void setTheme(AppTheme theme) => _settingsController.updateTheme(theme);

  @override
  void setThemeMode(ThemeMode themeMode) =>
      _settingsController.updateTheme(AppTheme(mode: themeMode, seed: theme.seed, size: theme.size));

  @override
  void setThemeSeedColor(Color? color) =>
      _settingsController.updateTheme(AppTheme(mode: theme.mode, seed: color, size: theme.size));

  @override
  void setTextScale(double textScale) {
    _settingsController.updateTextScale(textScale);
  }

  @override
  Locale get locale => _settingsController.state.locale ?? Localization.computeDefaultLocale;

  @override
  AppTheme get theme => _settingsController.state.appTheme ?? AppTheme.system(ScreenUtil.screenSize);

  @override
  double get textScale => _settingsController.state.textScale ?? 1;

  @override
  Widget build(BuildContext context) => StateConsumer<SettingsController, SettingsState>(
    controller: _settingsController,
    builder: (context, state, _) => _InheritedSettingsScope(scope: this, state: state, child: widget.child),
  );
}

enum _SettingsScopeAspect {
  /// The theme aspect.
  theme,

  /// The locale aspect.
  locale,

  /// The textScale aspect.
  textScale,
}

/// Inherited widget for quick access in the element tree.
class _InheritedSettingsScope extends InheritedModel<_SettingsScopeAspect> {
  const _InheritedSettingsScope({required this.scope, required this.state, required super.child});

  final _SettingsScopeState scope;
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

    if (dependencies.contains(_SettingsScopeAspect.textScale)) {
      shouldNotify = shouldNotify || state.textScale != oldWidget.state.textScale;
    }

    return shouldNotify;
  }
}
