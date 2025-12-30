import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/core.dart';
import 'package:auth_app/_core/router/router_state_mixin.dart';
import 'package:auth_app/_core/widget/window_scope.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

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
  // Disable recreate widget tree
  final _builderKey = GlobalKey();

  // This global key is needed for [MaterialApp]
  // to work properly when Widgets Inspector is enabled.
  // static final _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = SettingsScope.themeOf(context).theme;
    final locale = SettingsScope.localeOf(context).locale;
    final textScale = SettingsScope.textScaleOf(context).textScale;
    final environment = context.dependencies.environment.type;

    final mediaQueryData = MediaQuery.of(context);

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
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),

      // Theme
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: theme.mode,

      // Scopes
      builder: (context, child) => MediaQuery(
        key: _builderKey,
        // Override the default text scaling behavior.
        // Can be a range: minScaleFactor: 1.0, maxScaleFactor: 2.0
        data: mediaQueryData.copyWith(
          // textScaler: TextScaler.noScaling,
          textScaler: TextScaler.linear(mediaQueryData.textScaler.scale(textScale).clamp(0.5, 2)),
        ),
        child: WindowScope(
          title: Localization.of(context).appTitle,
          height: 24, // TODO
          child: OctopusTools(
            enable: !environment.isProduction,
            octopus: router,
            child: AppMessageScope(
              octopus: router,
              child: AuthenticationScope(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
