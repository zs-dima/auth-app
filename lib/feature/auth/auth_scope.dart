import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/feature/auth/bloc/auth_bloc.dart';
import 'package:auth_app/feature/auth/data/model/sign_in_data.dart';
import 'package:auth_app/feature/users/bloc/users_avatars_bloc.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_tool/ui_tool.dart';

extension AuthScopeX on BuildContext {
  /// {@macro auth_controller}
  AuthController auth({bool listen = false}) => AuthScope.of(this);
}

/// {@template auth_controller}
/// A controller that holds and operates the app authentication.
/// {@endtemplate}
abstract interface class AuthController {
  AuthBloc get bloc;
  UsersAvatarsBloc get avatarBloc;

  AuthUser get user;
  void signIn(SignInData data);
  void signOut();
}

/// {@template authentication_scope}
/// AuthenticationScope widget.
/// {@endtemplate}
class AuthScope extends StatefulWidget {
  /// {@macro authentication_scope}
  const AuthScope({
    required this.child,
    super.key,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Authenticated user.
  static AuthUser userOf(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_AuthScopeInherited>(listen: listen).user;

  /// Get the [AuthController] of the closest [AuthScope] ancestor.
  static AuthController of(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_AuthScopeInherited>(listen: listen).controller;

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

/// State for widget AuthenticationScope.
class _AuthScopeState extends State<AuthScope> implements AuthController {
  @override
  late final AuthBloc bloc;

  @override
  late final UsersAvatarsBloc avatarBloc;

  @override
  void signIn(SignInData data) => bloc.add(AuthEvent.signIn(data));

  @override
  void signOut() => bloc.add(const AuthEvent.signOut());

  @override
  AuthUser user = const AuthUser.unauthenticated();
  StreamSubscription<void>? _subscription;

  void _listener(AuthState state) {
    final user = state.user;
    if (!mounted || this.user == user) return;

    setState(() => this.user = user);
  }

  @override
  void initState() {
    super.initState();

    bloc = AuthBloc(
      repository: context.dependencies.authenticationRepository,
      messageBloc: context.message.bloc,
    );

    avatarBloc = UsersAvatarsBloc(
      usersRepository: context.dependencies.usersRepository,
      messageBloc: context.message.bloc,
    );

    _subscription = bloc.stream.listen(_listener);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _AuthScopeInherited(
        user: user,
        controller: this,
        child: ClipRect(
          child: StatefulBuilder(
            builder: (context, setState) => widget.child,
          ),
        ),
      );
}

/// Inherited widget for quick access in the element tree.
class _AuthScopeInherited extends InheritedWidget {
  const _AuthScopeInherited({
    required this.controller,
    required this.user,
    required super.child,
  });

  final AuthController controller;

  final AuthUser user;

  @override
  bool updateShouldNotify(covariant _AuthScopeInherited oldWidget) => !identical(user, oldWidget.user);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<AuthUser>('authUser', user),
    );
  }
}
