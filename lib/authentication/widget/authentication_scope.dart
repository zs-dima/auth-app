import 'package:auth_app/_core/app.dart';
import 'package:auth_app/authentication/controller/authentication_controller.dart';
import 'package:auth_app/authentication/controller/authentication_state.dart';
import 'package:auth_app/authentication/data/model/sign_in_data.dart';
import 'package:auth_app/users/controller/users_avatars_controller.dart';
import 'package:auth_model/auth_model.dart' show AuthUser;
import 'package:flutter/widgets.dart';

extension AuthScopeX on BuildContext {
  // _AuthController auth({bool listen = false}) => AuthenticationScope.of(this, listen: listen);
  AuthenticationController get auth => AuthenticationScope.controllerOf(this);
}

/// {@template auth_controller}
/// A controller that holds and operates the app authentication.
/// {@endtemplate}
abstract interface class _AuthController {
  AuthenticationController get controller;
  UsersAvatarsController get avatarController;

  AuthUser get user;
  void signIn(SignInData data);
  void signOut();
}

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthenticationScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthenticationScope({
    required this.child,
    super.key,
  });

  // /// Get the [_AuthController] of the closest [AuthenticationScope] ancestor.
  // static _AuthController of(BuildContext context, {bool listen = false}) =>
  //     context.scopeOf<_InheritedAuthenticationScope>(listen: listen).state as _AuthController;

  /// Get the current [AuthUser]
  static AuthUser userOf(BuildContext context, {bool listen = true}) =>
      _InheritedAuthenticationScope.of(context, listen: listen).state.user;

  /// Get the current [AuthenticationController]
  static AuthenticationController controllerOf(BuildContext context) =>
      _InheritedAuthenticationScope.of(context, listen: false);

  /// Sign-In
  static void signIn(BuildContext context, SignInData data) =>
      _InheritedAuthenticationScope.of(context, listen: false).signIn(data);

  /// Sign-Out
  static void signOut(BuildContext context) => _InheritedAuthenticationScope.of(context, listen: false).signOut();

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<AuthenticationScope> createState() => _AuthenticationScopeState();
}

/// State for widget AuthenticationScope.
class _AuthenticationScopeState extends State<AuthenticationScope> {
  @override
  late final AuthenticationController controller;

  @override
  void initState() {
    super.initState();
    controller = context.dependencies.authenticationController;
    controller.addListener(_listener);
  }

  void _listener() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    controller
      ..removeListener(_listener)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InheritedAuthenticationScope(
    controller: controller,
    state: controller.state,
    child: widget.child,
  );
}

/// Inherited widget for quick access in the element tree.
class _InheritedAuthenticationScope extends InheritedWidget {
  const _InheritedAuthenticationScope({
    required this.controller,
    required this.state,
    required super.child,
  });

  static AuthenticationController? maybeOf(BuildContext context, {bool listen = true}) =>
      (listen
              ? context.dependOnInheritedWidgetOfExactType<_InheritedAuthenticationScope>()
              : context.getInheritedWidgetOfExactType<_InheritedAuthenticationScope>())
          ?.controller;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
    'Out of scope, not found inherited widget a _InheritedAuthenticationScope of the exact type',
    'out_of_scope',
  );

  static AuthenticationController of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  final AuthenticationController controller;
  final AuthenticationState state;

  @override
  bool updateShouldNotify(covariant _InheritedAuthenticationScope oldWidget) => !identical(oldWidget.state, state);
}
