import 'package:auth_app/_core/app_widget.dart';
import 'package:auth_app/_core/theme/model/app_theme.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/settings/controller/settings_controller.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:ui/ui.dart';

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
