import 'dart:async';

import 'package:auth_model/auth_model.dart';
import 'package:flutter/widgets.dart';
import 'package:octopus/octopus.dart';

/// A router guard that checks if the user is authenticated.
class AuthenticationGuard extends OctopusGuard {
  AuthenticationGuard({
    required FutureOr<AuthUser> Function() getUser,
    required Set<String> routes,
    required OctopusState signinNavigation,
    required OctopusState homeNavigation,
    OctopusState? lastNavigation,
    super.refresh,
  }) : _getUser = getUser,
       _routes = routes,
       _homeNavigation = homeNavigation,
       _signinNavigation = signinNavigation,
       _lastNavigation = lastNavigation ?? homeNavigation {
    if (lastNavigation != null) return;

    // Seed `_lastNavigation` from the cold-start URL so a deep-link reload returns the user to
    // where they were after sign-in. We deliberately reject auth-route URLs (e.g. `/signin`):
    // otherwise stripping the auth route from `state` and returning `_lastNavigation` would just
    // navigate back to the same page, leaving the user stuck in a redirect loop.
    try {
      final parsed = OctopusState.fromLocation(WidgetsBinding.instance.platformDispatcher.defaultRouteName);
      if (parsed.isNotEmpty && !_containsAuthRoute(parsed)) _lastNavigation = parsed;
    } on Object {
      /* ignore */
    }
  }

  /// Get the current user.
  final FutureOr<AuthUser> Function() _getUser;

  /// Routes names that stand for the authentication routes (e.g. `signin`, `signup`).
  final Set<String> _routes;

  /// The navigation to use when the user is not authenticated.
  final OctopusState _signinNavigation;

  /// Safe fallback whenever [_lastNavigation] is missing or unsafe to restore.
  final OctopusState _homeNavigation;

  /// Last non-auth navigation observed for the current session. Reset to [_homeNavigation]
  /// whenever the session becomes unauthenticated, so a previous user's URL cannot leak into the
  /// next sign-in (e.g. another tab / a shared device).
  OctopusState _lastNavigation;

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) async {
    final getUserOr = _getUser(); // Get the current user.
    final user = getUserOr is Future ? await getUserOr : getUserOr;

    context['user'] = user; // Save the user in the context.

    if (!user.isAuthenticated) {
      // Drop any session-scoped memory so the next signed-in user (or another tab) cannot inherit
      // a private deep link.
      _lastNavigation = _homeNavigation;
    }

    final isAuthNav = state.children.any((child) => _routes.contains(child.name));
    if (isAuthNav) {
      // New state is an authentication navigation.
      if (user.isAuthenticated) {
        // User authenticated. Strip the auth routes but keep any open dialog.
        state.removeWhere((child) => !child.name.endsWith('-dialog') && _routes.contains(child.name));
        if (state.isNotEmpty) return state;
        // Restore the last navigation, but never an auth route (would loop back here).
        return _containsAuthRoute(_lastNavigation) ? _homeNavigation : _lastNavigation;
      }
      // User not authenticated.
      // Remove any navigation that is not an authentication navigation.
      state.removeWhere((child) => !_routes.contains(child.name));
      // Add the signin navigation if the state is empty.
      // Or return the state if it contains the signin navigation.
      return state.isEmpty ? _signinNavigation : state;
    }
    // New state is not an authentication navigation.
    if (user.isAuthenticated) {
      // User authenticated.
      // Save the current navigation as the last navigation.
      _lastNavigation = state;
      return super(history, state, context);
    }
    // User not authenticated.
    // Replace the current navigation with the signin navigation.
    return _signinNavigation;
  }

  bool _containsAuthRoute(OctopusState state) => state.children.any((child) => _routes.contains(child.name));
}
