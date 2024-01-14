import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/app_widget.dart';
import 'package:auth_app/app/theme/model/app_theme.dart';
import 'package:auth_app/feature/settings/controller/settings_controller.dart';
import 'package:auth_app/feature/settings/settings_scope.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

class AppTree extends StatelessWidget {
  const AppTree({super.key});

  // TODO RootRestorationScope( restorationId: 'root', child:

  @override
  Widget build(BuildContext context) {
    final settings = context.dependencies.settings;
    return SettingsScope(
      settingsController: SettingsController(
        repository: settings,
        // TODO rework
        initialState: SettingsState.idle(
          appTheme: AppTheme(
            mode: settings.themeMode ?? ThemeMode.system,
            seed: settings.themeColor,
            size: ScreenUtil.screenSize,
          ),
          locale: settings.locale,
        ),
      ),
      child: const AppWidget(),
    );
  }
}
