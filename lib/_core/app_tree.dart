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
    final dependencies = _dependencies;
    if (dependencies == null) return;

    switch (state) {
      // App-wide teardown (A6): when the engine detaches, release the gRPC channels, the external HTTP
      // client, and the auth handler/repository. `detached` is best-effort on mobile but reliable on
      // desktop/web/hot-restart.
      case .detached:
        $disposeApp(dependencies).ignore();

      // On resume (returning from background), proactively refresh a token that may have expired while
      // suspended, so the first authenticated call doesn't pay a reactive 401→refresh round-trip.
      // Single-flight + only refreshes when `expiresSoon`; `force:false` never logs out or throws
      // outward, so this is safe to fire-and-forget. Skipped when there is no session.
      case .resumed:
        final repository = dependencies.authenticationRepository;
        if (repository.user.isAuthenticated) repository.getAccessCredentials().ignore();

      case .inactive:
      case .paused:
      case .hidden:
        break;
    }
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
