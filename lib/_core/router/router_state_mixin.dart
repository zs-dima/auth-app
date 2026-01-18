import 'package:auth_app/_core/router/authentication_guard.dart';
import 'package:auth_app/_core/router/email_verified_guard.dart';
import 'package:auth_app/_core/router/home_guard.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/widgets.dart' show State, StatefulWidget, ValueNotifier, WidgetsBinding;
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

    // Create router with initial state from browser URL for deep linking.
    final initialLocation = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    router = Octopus(
      routes: Routes.values,
      defaultRoute: Routes.home,
      initialState: OctopusState.fromLocation(initialLocation),
      guards: <IOctopusGuard>[
        // Intercept email-verified route: call confirmVerification API.
        EmailVerifiedGuard(
          messageController: dependencies.messageController,
          authenticationController: dependencies.authenticationController,
        ),
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
