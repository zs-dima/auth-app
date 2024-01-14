import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/feature/authentication/controller/authentication_controller.dart';
import 'package:auth_app/feature/authentication/widget/authentication_scope.dart';
import 'package:auth_app/feature/users/controller/user_controller.dart';
import 'package:auth_app/feature/users/controller/users_avatars_controller.dart';
import 'package:auth_app/feature/users/controller/users_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:collection/collection.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ui_tool/ui_tool.dart';

extension UsersScopeX on BuildContext {
  /// {@macro users_controller}
  IUsersController users({bool listen = false}) => UsersScope.of(this, listen: listen);
}

/// {@template users_controller}
/// A controller that holds and operates the app users.
/// {@endtemplate}
abstract interface class IUsersController {
  UsersController get controller;
  List<User> get users;
  User? byId(UserId id);
  Future<void> createUser(User user, String password);
  Future<void> updateUser(User user);
  void savePhoto(UserId userId, Uint8List? photo);
}

@immutable
class UsersScope extends StatefulWidget {
  const UsersScope({
    required this.child,
    super.key,
  });

  /// Loaded users.
  static List<User> usersOf(BuildContext context, {bool listen = true}) =>
      context.scopeOf<_UsersScopeInherited>(listen: listen).users;

  /// Get the [UsersController] of the closest [UsersScope] ancestor.
  static IUsersController of(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_UsersScopeInherited>(listen: listen).controller;

  final Widget child;

  @override
  State<UsersScope> createState() => _UsersScopeState();
}

class _UsersScopeState extends State<UsersScope> implements IUsersController {
  late AuthenticationController _authController;
  late UsersAvatarsController _avatarController;
  IUserInfo? _currentUser;
  late final UserController _userController;

  @override
  late final UsersController controller;

  @override
  void initState() {
    super.initState();

    controller = UsersController(
      repository: context.dependencies.usersRepository,
      messageController: context.message,
    );

    _userController = UserController(
      repository: context.dependencies.usersRepository,
      messageController: context.message,
    );

    _authController = context.dependencies.authenticationController;
    _avatarController = context.dependencies.avatarController;

    _subscription = controller.toStream().listen(_listener);
  }

  void _listener(UsersState state) {
    if (!mounted) return;
    state.whenOrNull(
      loaded: (_, stateUsers) {
        if (users == stateUsers) return;

        // Update authenticated user info
        final updatedUser = stateUsers.firstWhereOrNull((user) => user.id == _currentUser?.id);
        if (updatedUser != null && updatedUser != _currentUser) {
          _authController.updateUserInfo(updatedUser);
          _currentUser = updatedUser;
        }

        setState(() => users = stateUsers);
      },
    );
  }

  @override
  User? byId(UserId id) => controller.state.whenOrNull(
        loaded: (_, stateUsers) => users.firstWhereOrNull((user) => user.id == id),
      );

  @override
  Future<void> createUser(User user, String password) async {
    _userController.createUser(user, password);
    await _userController.toStream().where((i) => i is UserCreateState).first;

    final currentUser = _currentUser;
    if (currentUser != null) controller.loadUsers(currentUser.id);
  }

  @override
  Future<void> updateUser(User user) async {
    if (user == controller.state.users.firstWhereOrNull((u) => u.id == user.id)) {
      return;
    }
    _userController.updateUser(user);
    await _userController.toStream().where((i) => i is UserUpdateState).first;

    final currentUser = _currentUser;
    if (currentUser != null) controller.loadUsers(currentUser.id);
  }

  @override
  void savePhoto(UserId userId, Uint8List? photo) => _avatarController.savePhoto(userId, photo);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentUser = AuthenticationScope.userOf(context).maybeCast<AuthenticatedUser>()?.userInfo;

    if (_currentUser == currentUser) return;
    _currentUser = currentUser;

    controller.loadUsers(currentUser?.id ?? UserIdX.empty);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    controller.dispose();
    _userController.dispose();
    super.dispose();
  }

  @override
  List<User> users = UnmodifiableListView<User>([]);

  StreamSubscription<void>? _subscription;

  @override
  Widget build(BuildContext context) => _UsersScopeInherited(
        users: users,
        controller: this,
        child: widget.child,
      );
}

@immutable
class _UsersScopeInherited extends InheritedWidget {
  const _UsersScopeInherited({
    required this.controller,
    required this.users,
    required super.child,
  });

  final IUsersController controller;

  final List<User> users;

  @override
  bool updateShouldNotify(covariant _UsersScopeInherited oldWidget) => !identical(users, oldWidget.users);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<List<User>>('users', users),
    );
  }
}
