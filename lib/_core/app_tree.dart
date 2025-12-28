import 'package:auth_app/_core/app_widget.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:ui/ui.dart';

class AppTree extends StatelessWidget {
  const AppTree({super.key});

  // TODO RootRestorationScope( restorationId: 'root', child:

  @override
  Widget build(BuildContext context) => const SettingsScope(
    child: AppWidget(),
  );
}
