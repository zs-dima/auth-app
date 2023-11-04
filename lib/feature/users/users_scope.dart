import 'dart:async';

import 'package:auth_app/app/app.dart';
import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/auth/bloc/auth_bloc.dart';
import 'package:auth_app/feature/users/bloc/user_bloc.dart';
import 'package:auth_app/feature/users/bloc/users_avatars_bloc.dart';
import 'package:auth_app/feature/users/bloc/users_bloc.dart';
import 'package:auth_model/auth_model.dart';
import 'package:collection/collection.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ui_tool/ui_tool.dart';

extension UsersScopeX on BuildContext {
  /// {@macro users_controller}
  UsersController users({bool listen = false}) => UsersScope.of(this, listen: listen);
}

/// {@template users_controller}
/// A controller that holds and operates the app users.
/// {@endtemplate}
abstract interface class UsersController {
  UsersBloc get bloc;
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
  static UsersController of(BuildContext context, {bool listen = false}) =>
      context.scopeOf<_UsersScopeInherited>(listen: listen).controller;

  final Widget child;

  @override
  State<UsersScope> createState() => _UsersScopeState();
}

class _UsersScopeState extends State<UsersScope> implements UsersController {
  late AuthBloc _authBloc;
  late UsersAvatarsBloc _avatarBloc;
  IUserInfo? _currentUser;
  late final UserBloc _userBloc;

  @override
  late final UsersBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = UsersBloc(
      repository: context.dependencies.usersRepository,
      messageBloc: context.message.bloc,
    );

    _userBloc = UserBloc(
      repository: context.dependencies.usersRepository,
      messageBloc: context.message.bloc,
    );

    _authBloc = context.auth(listen: false).bloc;
    _avatarBloc = context.auth(listen: false).avatarBloc;

    _subscription = bloc.stream.listen(_listener);
  }

  void _listener(UsersState state) {
    if (!mounted) return;
    state.whenOrNull(
      loaded: (_, stateUsers) {
        if (users == stateUsers) return;

        // Update authenticated user info
        final updatedUser = stateUsers.firstWhereOrNull((user) => user.id == _currentUser?.id);
        if (updatedUser != null && updatedUser != _currentUser) {
          _authBloc.add(AuthEvent.updateUserInfo(updatedUser));
          _currentUser = updatedUser;
        }

        setState(() => users = stateUsers);
      },
    );
  }

  @override
  User? byId(UserId id) => bloc.state.whenOrNull(
        loaded: (_, stateUsers) => users.firstWhereOrNull((user) => user.id == id),
      );

  @override
  Future<void> createUser(User user, String password) async {
    _userBloc.add(UserEvent.createUser(user, password));
    await _userBloc.whereState<UserCreateState>().first;

    final currentUser = _currentUser;
    if (currentUser != null) bloc.add(UsersEvent.loadUsers(userId: currentUser.id));
  }

  @override
  Future<void> updateUser(User user) async {
    if (user == bloc.state.users.firstWhereOrNull((u) => u.id == user.id)) {
      return;
    }
    _userBloc.add(UserEvent.updateUser(user));
    await _userBloc.whereState<UserUpdateState>().first;

    final currentUser = _currentUser;
    if (currentUser != null) bloc.add(UsersEvent.loadUsers(userId: currentUser.id));
  }

  @override
  void savePhoto(UserId userId, Uint8List? photo) => _avatarBloc.add(UsersAvatarsEvent.savePhoto(userId, photo));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentUser = AuthScope.userOf(context).maybeCast<AuthenticatedUser>()?.userInfo;

    if (_currentUser == currentUser) return;
    _currentUser = currentUser;

    bloc.add(UsersEvent.loadUsers(userId: currentUser?.id ?? UserIdX.empty));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    bloc.close();
    _userBloc.close();
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

  final UsersController controller;

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
