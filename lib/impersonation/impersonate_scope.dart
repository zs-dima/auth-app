import 'dart:async';

import 'package:auth_app/authentication/controller/authenticated_user_controller.dart';
import 'package:auth_app/impersonation/controller/impersonate_controller.dart';
import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:ui/ui.dart';

extension ImpersonateScopeX on BuildContext {
  IImpersonateController impersonation({bool listen = false}) => ImpersonateScope.of(this, listen: listen);
}

abstract interface class IImpersonateController {
  ImpersonateController get controller;
  void impersonate(IUserInfo user);
}

/// {@template impersonate_scope}
/// ImpersonateScope widget.
/// {@endtemplate}
class ImpersonateScope extends StatefulWidget {
  /// {@macro impersonate_scope}
  const ImpersonateScope({required this.authenticatedUser, required this.child, super.key});

  /// Impersonated user.
  static IUserInfo userOf(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_InheritedImpersonateScope>(listen: listen).user;

  /// Get the [UsersController] of the closest [UsersScope] ancestor.
  static IImpersonateController of(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_InheritedImpersonateScope>(listen: listen).controller;

  /// Authenticated user.
  final IUserInfo authenticatedUser;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<ImpersonateScope> createState() => _ImpersonateScopeState();
}

/// State for widget ImpersonateScope.
class _ImpersonateScopeState extends State<ImpersonateScope> implements IImpersonateController {
  StreamSubscription? _authUserSubscription;

  @override
  late final ImpersonateController controller;

  @override
  void initState() {
    super.initState();

    controller = context.dependencies.impersonateController;

    final authenticatedUserController = context.dependencies.authenticatedUserController;
    _authUserSubscription =
        authenticatedUserController //
            .toStream()
            .listen(
              (state) => switch (state) {
                AuthenticatedUserLoadedState(:final user) => impersonate(user),
                _ => null,
              },
              cancelOnError: false,
            );

    final currentUser = authenticatedUserController.state.user;
    if (currentUser.id != UserIdX.empty) impersonate(currentUser);
  }

  @override
  void impersonate(IUserInfo user) {
    // if (user.id == UserIdX.empty) return; // TODO cleanup app data

    // reload related data
  }

  @override
  void dispose() {
    _authUserSubscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StateConsumer<ImpersonateController, ImpersonateState>(
    controller: controller,
    builder: (context, state, _) => _InheritedImpersonateScope(controller: this, user: state.user, child: widget.child),
  );
}

/// Inherited widget for quick access in the element tree.
class _InheritedImpersonateScope extends InheritedWidget {
  const _InheritedImpersonateScope({required this.controller, required this.user, required super.child});

  final IImpersonateController controller;

  final IUserInfo user;

  @override
  bool updateShouldNotify(covariant _InheritedImpersonateScope oldWidget) => !identical(user, oldWidget.user);
}
