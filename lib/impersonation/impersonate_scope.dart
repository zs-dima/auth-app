import 'package:auth_app/authentication/authenticated_scope.dart';
import 'package:auth_app/impersonation/controller/impersonate_controller.dart';
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
///
/// Reads its controller from [AuthenticatedScope], which owns it for the length
/// of the session. The scope also drives "act as whoever just signed in", so
/// this widget no longer subscribes to the profile itself — one subscription,
/// in the place that owns the controller.
class _ImpersonateScopeState extends State<ImpersonateScope> implements IImpersonateController {
  @override
  late final ImpersonateController controller;

  @override
  void initState() {
    super.initState();
    controller = AuthenticatedScope.impersonateControllerOf(context);
  }

  @override
  void impersonate(IUserInfo user) => controller.impersonate(user);

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
