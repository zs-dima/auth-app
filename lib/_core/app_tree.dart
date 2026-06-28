import 'package:auth_app/_core/app_widget.dart';
import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/initialization/initialization.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:flutter/widgets.dart';

class AppTree extends StatefulWidget {
  const AppTree({super.key});

  // TODO RootRestorationScope( restorationId: 'root', child:

  @override
  State<AppTree> createState() => _AppTreeState();
}

class _AppTreeState extends State<AppTree> with WidgetsBindingObserver {
  Dependencies? _dependencies;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // InheritedDependencies is an ancestor; capture the container so teardown never touches the
    // element tree at shutdown.
    _dependencies ??= Dependencies.of(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App-wide teardown (A6): when the engine detaches, release the gRPC channels, the external HTTP
    // client, and the auth handler/repository. `detached` is best-effort on mobile but reliable on
    // desktop/web/hot-restart.
    if (state != .detached) return;
    final dependencies = _dependencies;
    if (dependencies != null) $disposeApp(dependencies).ignore();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SettingsScope(
    child: AppWidget(),
  );
}
