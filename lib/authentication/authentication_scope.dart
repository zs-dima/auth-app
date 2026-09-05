import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/authentication/authenticated_scope.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/impersonation/impersonate_scope.dart';
import 'package:auth_app/users/users_scope.dart';
import 'package:auth_model/auth_model.dart' hide AuthenticationState;
import 'package:control/control.dart';
import 'package:ui/ui.dart';

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthenticationScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthenticationScope({required this.child, super.key});

  /// Get the [AuthenticationController] of the closest [AuthenticationScope] ancestor.
  static AuthenticationController controllerOf(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_InheritedAuthenticationScope>(listen: listen).controller;

  /// Get the [AuthUser] of the closest [AuthenticationScope] ancestor.
  static AuthUser userOf(BuildContext context) => context
      .inheritFrom<_AuthenticationScopeAspect, _InheritedAuthenticationScope>(
        aspect: _AuthenticationScopeAspect.authentication,
      )
      .authUser;

  /// Get the [IUserInfo] of the closest [AuthenticationScope] ancestor.
  static IUserInfo userInfoOf(BuildContext context) => context
      .inheritFrom<_AuthenticationScopeAspect, _InheritedAuthenticationScope>(
        aspect: _AuthenticationScopeAspect.userInfo,
      )
      .userInfo;

  /// Sign-In
  static void signIn(BuildContext context, SignInData data) => controllerOf(context, listen: false).signIn(data);

  /// Sign-Out
  static void signOut(BuildContext context) => controllerOf(context, listen: false).signOut();

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<AuthenticationScope> createState() => _AuthenticationScopeState();
}

/// State for widget AuthenticationScope.
class _AuthenticationScopeState extends State<AuthenticationScope> {
  late final AuthenticationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Dependencies.of(context).authenticationController;
  }

  @override
  Widget build(BuildContext context) => StateConsumer<AuthenticationController, AuthenticationState>(
    controller: _controller,
    builder: (context, state, _) => AuthenticatedScope(
      // The identity IS the key: a sign-out drops to the empty id and disposes the session's
      // controllers, a sign-in mints a new set. Nothing per-user survives the change.
      key: ValueKey<UserId>(switch (state.user) {
        AuthenticatedUser(:final userId) => userId,
        _ => UserIdX.empty,
      }),
      authUser: state.user,
      builder: (context, userInfo) => _InheritedAuthenticationScope(
        scope: this,
        controller: _controller,
        authUser: state.user,
        userInfo: userInfo,
        child: ImpersonateScope(
          authenticatedUser: userInfo,
          child: UsersScope(
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}

enum _AuthenticationScopeAspect {
  /// The authentication aspect.
  authentication,

  /// The userInfo aspect.
  userInfo,
}

/// Inherited widget for quick access in the element tree.
class _InheritedAuthenticationScope extends InheritedModel<_AuthenticationScopeAspect> {
  const _InheritedAuthenticationScope({
    required this.scope,
    required this.controller,
    required this.authUser,
    required this.userInfo,
    required super.child,
  });

  final AuthUser authUser;
  final IUserInfo userInfo;
  final _AuthenticationScopeState scope;
  final AuthenticationController controller;

  @override
  bool updateShouldNotify(_InheritedAuthenticationScope oldWidget) =>
      authUser != oldWidget.authUser || userInfo != oldWidget.userInfo;

  @override
  bool updateShouldNotifyDependent(
    covariant _InheritedAuthenticationScope oldWidget,
    Set<_AuthenticationScopeAspect> dependencies,
  ) {
    var shouldNotify = false;

    if (dependencies.contains(_AuthenticationScopeAspect.authentication)) {
      shouldNotify = shouldNotify || authUser != oldWidget.authUser;
    }

    if (dependencies.contains(_AuthenticationScopeAspect.userInfo)) {
      shouldNotify = shouldNotify || userInfo != oldWidget.userInfo;
    }

    return shouldNotify;
  }
}
