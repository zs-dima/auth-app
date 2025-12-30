import 'package:auth_app/_core/core.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/users/controller/user_controller.dart';
import 'package:auth_app/users/controller/users_avatars_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:collection/collection.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/ui.dart';

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
  // late AuthenticationController _authController;
  late UsersAvatarsController _avatarController;
  UserId _currentUserId = UserIdX.empty;
  late final UserController _userController;

  @override
  late final UsersController controller;

  @override
  void initState() {
    super.initState();

    controller = context.dependencies.usersController;

    _userController = UserController(
      repository: context.dependencies.usersRepository,
      messageController: context.message,
    );

    // _authController = context.dependencies.authenticationController;
    _avatarController = context.dependencies.avatarController;
  }

  Future<void> _reloadUsers() async {
    if (!mounted) return;
    final currentUser = context.dependencies.authenticationController.state.user;
    if (currentUser is AuthenticatedUser) {
      controller.loadUsers(currentUser.userId);
    } else {
      await controller.reset();
    }
  }

  @override
  User? byId(UserId id) => controller.state.whenOrNull(
    loaded: (_, stateUsers) => users.firstWhereOrNull((user) => user.id == id),
  );

  @override
  Future<void> createUser(User user, String password) async {
    _userController.createUser(user, password);
    await _userController.toStream().where((i) => i is UserCreateState).first;

    await _reloadUsers();
  }

  @override
  Future<void> updateUser(User user) async {
    if (user == controller.state.users.firstWhereOrNull((u) => u.id == user.id)) {
      return;
    }
    _userController.updateUser(user);
    await _userController.toStream().where((i) => i is UserUpdateState).first;

    await _reloadUsers();
  }

  @override
  void savePhoto(UserId userId, Uint8List? photo) => _avatarController.savePhoto(userId, photo);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentUserId =
        AuthenticationScope.userOf(context) //
            .maybeCast<AuthenticatedUser>()
            ?.userId ??
        UserIdX.empty;

    if (_currentUserId == currentUserId) return;
    _currentUserId = currentUserId;

    // TODO cleanup app data
    if (currentUserId != UserIdX.empty) controller.loadUsers(currentUserId);
  }

  @override
  void dispose() {
    // _userController.dispose();
    super.dispose();
  }

  @override
  List<User> users = UnmodifiableListView<User>([]);

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
