import 'package:auth_app/_core/log/telemetry.dart';
import 'package:auth_app/_core/router/authentication_guard.dart';
import 'package:auth_app/_core/router/email_verified_guard.dart';
import 'package:auth_app/_core/router/home_guard.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:flutter/widgets.dart' show NavigatorObserver, State, StatefulWidget, ValueNotifier, WidgetsBinding;
import 'package:octopus/octopus.dart';
import 'package:sentry_flutter/sentry_flutter.dart' show SentryNavigatorObserver;

typedef RouterErrorDef = ({Object error, StackTrace stackTrace});

mixin RouterStateMixin<T extends StatefulWidget> on State<T> {
  /// How many router errors [errorsObserver] keeps; the newest win.
  static const int _maxObservedErrors = 20;

  late final Octopus router;
  late final ValueNotifier<List<RouterErrorDef>> errorsObserver;

  @override
  void initState() {
    super.initState();

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
        EmailVerifiedGuard(authenticationController: dependencies.authenticationController),
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
      onError: (error, stackTrace) {
        // The dev menu reads this list; telemetry is what carries the failure off the device.
        log.e('Router | navigation | failed', error: error, stackTrace: stackTrace);
        errorsObserver.value = <RouterErrorDef>[
          (error: error, stackTrace: stackTrace),
          ...errorsObserver.value.take(_maxObservedErrors - 1),
        ];
      },
      observers: <NavigatorObserver>[
        // Navigation breadcrumbs and `contexts.app.view_names` on every report — which screen the
        // user was on is the question a crash report is read with.
        //
        // Auto transactions are OFF deliberately: this app's tracing is controller-centric
        // (`ControllerObserver` starts a `bindToScope: true` transaction per handler, with the
        // state timeline attached), and a navigation transaction competing for the scope's span
        // would leave both half-parented. Screen-load timing is not worth that.
        SentryNavigatorObserver(enableAutoTransactions: false),
      ],
    );

    // One journal line per navigation. Sentry has had its own breadcrumbs from the observer
    // above, but the journal — the thing a tester's bug report is made of, and the only source
    // offline — had no idea which screen anything happened on.
    router.observer.addListener(_logNavigation);
  }

  @override
  void dispose() {
    router.observer.removeListener(_logNavigation);
    super.dispose();
  }

  /// The route NAMES, never `OctopusState.location`.
  ///
  /// `location` encodes each node's arguments as query parameters, and the
  /// recovery route carries the password-reset token in exactly those — so the
  /// full location would land in the journal, in a release device log (the
  /// console floor is `info`), and as a Sentry tag. Names are what a trail is
  /// for; the values are what it must not carry.
  void _logNavigation() => log.i(
    'Router | navigate | changed',
    meta: <String, Object?>{'app.route': routeNamesOf(router.observer.value)},
  );
}

/// The node names of [state], `a/b/c`, with every argument left behind.
///
/// This is the ONLY shape a route takes as an attribute value. A named function rather than an
/// inline `map`, because the rule has to hold at every site that reports one — in the twin app a
/// second site was added later and wrote the LOCATION, which for a route carrying a secret in its
/// arguments is the whole problem. Accepts a state or a location string.
String routeNamesOf(Object state) => switch (state) {
  final OctopusState parsed => parsed.children.map((node) => node.name).join('/'),
  final String location => routeNamesOf(OctopusState.fromLocation(location)),
  _ => throw ArgumentError.value(state, 'state', 'an OctopusState or a location string'),
};
