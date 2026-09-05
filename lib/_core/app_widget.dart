import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/core.dart';
import 'package:auth_app/_core/router/router_state_mixin.dart';
import 'package:auth_app/_core/widget/window_scope.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart' show WindowSizeScope;

/// {@template app}
/// App widget.
/// {@endtemplate}
class AppWidget extends StatefulWidget {
  /// {@macro app}
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> with RouterStateMixin {
  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled.
  // static final _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = SettingsScope.themeOf(context).theme;
    final locale = SettingsScope.localeOf(context).locale;
    final textScale = SettingsScope.textScaleOf(context).textScale;
    final environment = context.dependencies.environment.type;

    return MaterialApp.router(
      // key: _globalKey, // TODO
      title: Config.appName,
      debugShowCheckedModeBanner: !environment.isProduction,
      restorationScopeId: 'app_widget',

      // Router
      routerConfig: router.config,

      // Localizations
      supportedLocales: Localization.supportedLocales,
      localizationsDelegates: Localization.localizationDelegates,
      locale: locale,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          .mouse,
          .touch,
          .stylus,
          .unknown,
        },
      ),

      // Theme
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,

      // Scopes
      builder: (context, child) {
        final scopes = WindowSizeScope(
          child: WindowScope(
            title: Localization.of(context).appTitle,
            height: 24.0, // TODO
            child: OctopusTools(
              enable: !environment.isProduction,
              octopus: router,
              child: AppMessageScope(
                child: AuthenticationScope(
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );

        return _TextScale(scale: textScale, child: scopes);
      },
    );
  }
}

/// Applies the user's text-size preference, and nothing else.
///
/// Its own widget so that the element depending on the full [MediaQuery] is a LEAF over the app:
/// when the keyboard animates or the window rotates, this rebuilds and its `child` — an unchanged
/// instance — is skipped by `Widget.canUpdate`. Building a whole `MediaQueryData` needs the whole
/// of it, which is exactly why the dependency has to stop here.
class _TextScale extends StatelessWidget {
  const _TextScale({required this.scale, required this.child});

  /// The stored multiplier from Settings.
  final double scale;

  /// The whole app.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // layout-check: ignore media-query-of
    final data = MediaQuery.of(context);
    return MediaQuery(
      // A range rather than a fixed scale: the OS preference still applies, the app's own
      // multiplier rides on top of it, and the product of the two is clamped.
      data: data.copyWith(textScaler: TextScaler.linear(data.textScaler.scale(scale).clamp(0.5, 2.0))),
      child: child,
    );
  }
}
