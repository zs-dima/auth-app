import 'dart:async';

import 'package:auth_app/app/router/routes.dart';
import 'package:auth_model/auth_model.dart';
import 'package:octopus/octopus.dart';

/// Check routes always contain the home route at the first position.
/// Only exception for not authenticated users.
class HomeGuard extends OctopusGuard {
  static final _homeName = Routes.home.name;

  HomeGuard();

  @override
  FutureOr<OctopusState> call(
    List<OctopusHistoryEntry> history,
    OctopusState$Mutable state,
    Map<String, Object?> context,
  ) {
    // If the user is not authenticated, do nothing.
    // The home route should not be in the state.
    if (context['user'] case final AuthUser user) if (!user.isAuthenticated) return state;

    // Home route should be the first route in the state
    // and should be only one in whole state.
    if (state.isEmpty) return _fix(state);
    final count = state.findAllByName(_homeName).length;
    if (count != 1) return _fix(state);
    if (state.children.first.name != _homeName) return _fix(state);
    return state;
  }

  /// Change the state of the nested navigation.
  OctopusState _fix(OctopusState$Mutable state) => state
    ..clear()
    ..putIfAbsent(_homeName, () => Routes.home.node());
}
