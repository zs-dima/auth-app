import 'dart:async';

import 'package:auth_app/_core/model/dependencies.dart';
import 'package:auth_app/authentication/controller/authenticated_user_controller.dart';
import 'package:auth_app/impersonation/controller/impersonate_controller.dart';
import 'package:auth_app/impersonation/data/impersonate_repository.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/widgets.dart';
import 'package:ui/ui.dart' show BuildContextX;

/// {@template authenticated_scope}
/// Owns everything that belongs to ONE signed-in user.
///
/// Keyed by the user id, so signing out disposes this whole subtree and signing
/// in builds a fresh one. That is the point of the widget: these four
/// controllers used to be created by the composition root, which meant they
/// outlived the session that produced them — `AvatarController` kept its
/// cache-busting versions across accounts, and `ImpersonateController` kept a
/// repository nobody closed. Per-user state now lives exactly as long as the
/// user does.
///
/// The [builder] receives the current [IUserInfo]; whatever it returns is
/// mounted BELOW this scope, so descendants reach the controllers through the
/// static accessors.
/// {@endtemplate}
class AuthenticatedScope extends StatefulWidget {
  /// {@macro authenticated_scope}
  const AuthenticatedScope({required this.authUser, required this.builder, super.key});

  /// The users list of the current session.
  static UsersController usersControllerOf(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_InheritedAuthenticatedScope>(listen: listen).usersController;

  /// The signed-in user's own profile.
  static AuthenticatedUserController userControllerOf(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_InheritedAuthenticatedScope>(listen: listen).userController;

  /// Avatar upload/delete and the cache-busting URL.
  static AvatarController avatarControllerOf(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_InheritedAuthenticatedScope>(listen: listen).avatarController;

  /// Which user the app is acting as.
  static ImpersonateController impersonateControllerOf(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_InheritedAuthenticatedScope>(listen: listen).impersonateController;

  /// The signed-in user, or [AuthUser.unauthenticated] before sign-in.
  final AuthUser authUser;

  /// Builds the subtree, given the profile of [authUser] as it currently loads.
  final Widget Function(BuildContext context, IUserInfo userInfo) builder;

  @override
  State<AuthenticatedScope> createState() => _AuthenticatedScopeState();
}

/// State for widget AuthenticatedScope.
class _AuthenticatedScopeState extends State<AuthenticatedScope> {
  late final UsersController _usersController;
  late final AuthenticatedUserController _userInfoController;
  late final AvatarController _avatarController;
  late final ImpersonateRepository _impersonateRepository;
  late final ImpersonateController _impersonateController;

  StreamSubscription<AuthenticatedUserState>? _userInfoSubscription;

  @override
  void initState() {
    super.initState();
    final dependencies = Dependencies.of(context);

    // Creation order is the dependency order, and `dispose` below is its exact reverse.
    _usersController = UsersController(repository: dependencies.usersRepository, messenger: dependencies.messenger);
    _userInfoController = AuthenticatedUserController(usersController: _usersController);
    _avatarController = AvatarController(
      s3Url: dependencies.environment.s3Url,
      repository: dependencies.usersRepository,
      httpClient: dependencies.externalHttpClient,
      messenger: dependencies.messenger,
    );
    _impersonateRepository = ImpersonateRepository(currentUser: _userInfoController.state.user);
    _impersonateController = ImpersonateController(repository: _impersonateRepository);

    // The app acts as whoever just loaded, until something impersonates someone else.
    _userInfoSubscription = _userInfoController.toStream().listen(
      (state) => switch (state) {
        AuthenticatedUserLoadedState(:final user) => _impersonateController.impersonate(user),
        _ => null,
      },
      cancelOnError: false,
    );

    _userInfoController.getUser(widget.authUser);
  }

  @override
  void didUpdateWidget(AuthenticatedScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Same user, new credentials (a refresh): the profile is already loaded and `getUser` returns
    // early. A DIFFERENT user never reaches here — the key changes, so the whole scope is replaced.
    if (widget.authUser != oldWidget.authUser) _userInfoController.getUser(widget.authUser);
  }

  @override
  void dispose() {
    _userInfoSubscription?.cancel();
    _impersonateController.dispose();
    _impersonateRepository.terminate();
    _avatarController.dispose();
    _userInfoController.dispose();
    _usersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StateConsumer<AuthenticatedUserController, AuthenticatedUserState>(
    controller: _userInfoController,
    builder: (context, state, _) => _InheritedAuthenticatedScope(
      usersController: _usersController,
      userController: _userInfoController,
      avatarController: _avatarController,
      impersonateController: _impersonateController,
      child: widget.builder(context, state.user),
    ),
  );
}

/// Carries the session's controllers down the tree. They never change for a
/// given scope — the key is the identity — so nothing here has to notify.
class _InheritedAuthenticatedScope extends InheritedWidget {
  const _InheritedAuthenticatedScope({
    required this.usersController,
    required this.userController,
    required this.avatarController,
    required this.impersonateController,
    required super.child,
  });

  final UsersController usersController;
  final AuthenticatedUserController userController;
  final AvatarController avatarController;
  final ImpersonateController impersonateController;

  @override
  bool updateShouldNotify(covariant _InheritedAuthenticatedScope oldWidget) =>
      !identical(usersController, oldWidget.usersController);
}
