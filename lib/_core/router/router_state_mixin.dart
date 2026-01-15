import 'package:auth_app/_core/router/authentication_guard.dart';
import 'package:auth_app/_core/router/home_guard.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/widgets.dart' show State, StatefulWidget, ValueNotifier;
import 'package:octopus/octopus.dart';

typedef RouterErrorDef = ({Object error, StackTrace stackTrace});

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  late final Octopus router;
  late final ValueNotifier<List<RouterErrorDef>> errorsObserver;

  @override
  void initState() {
    final dependencies = context.dependencies;

    // Observe all errors.
    errorsObserver = ValueNotifier<List<RouterErrorDef>>(
      <RouterErrorDef>[],
    );

    // Create router.
    router = Octopus(
      routes: Routes.values,
      defaultRoute: Routes.home,
      guards: <IOctopusGuard>[
        // Check authentication.
        AuthenticationGuard(
          // Get current user from authentication controller.
          getUser: () => dependencies.authenticationController.state.user,
          // Available routes for non authenticated user.
          routes: <String>{
            Routes.signin.name,
            Routes.signup.name,
            Routes.authRecoveryStart.name,
            Routes.authRecoveryConfirm.name,
            Routes.emailVerified.name,
            // Routes.appUpdateAvailable.name,
          },
          // Default route for non authenticated user.
          signinNavigation: OctopusState.single(Routes.signin.node()),
          // Default route for authenticated user.
          homeNavigation: OctopusState.single(Routes.home.node()),
          // Check authentication on every authentication controller state change.
          refresh: dependencies.authenticationController,
        ),
        // Home route should be always on top.
        HomeGuard(),
      ],
      onError: (error, stackTrace) => errorsObserver.value = <RouterErrorDef>[
        (error: error, stackTrace: stackTrace),
        ...errorsObserver.value,
      ],
      /* observers: <NavigatorObserver>[
        HeroController(),
      ], */
    );
    super.initState();
  }
}
