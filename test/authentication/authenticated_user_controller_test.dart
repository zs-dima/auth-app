import 'dart:async';

import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/authentication/controller/authenticated_user_controller.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticatedUserController.getUser', () {
    const kUserId = 'a7f1c8d2-0000-4000-8000-000000000001';

    // `loading` is published before the fetch; a throw used to leave it there for the rest of the
    // process, so the scope rendered an empty user forever and no loaded state ever reached
    // ImpersonateScope. The error path must always land on a terminal state.
    test('reaches a terminal state when the user lookup throws', () async {
      final controller = _buildController(const _FakeUsersRepository(users: <User>[]));
      addTearDown(controller.dispose);

      controller.getUser(const AuthenticatedUser(userId: kUserId, credentials: null));
      await _settle();

      expect(controller.state, isA<AuthenticatedUserLoadedState>());
      expect(controller.state.user.id, equals(UserIdX.empty));
    });

    test('publishes the loaded user on success', () async {
      const user = User(id: kUserId, name: 'Ada', email: 'ada@mail.com', role: .user, status: .active);
      final controller = _buildController(const _FakeUsersRepository(users: <User>[user]));
      addTearDown(controller.dispose);

      controller.getUser(const AuthenticatedUser(userId: kUserId, credentials: null));
      await _settle();

      expect(controller.state, isA<AuthenticatedUserLoadedState>());
      expect(controller.state.user.id, equals(kUserId));
    });
  });
}

AuthenticatedUserController _buildController(IUsersRepository repository) => .new(
  usersController: UsersController(repository: repository, messenger: UiMessenger()),
);

/// Drains the controller's sequential queue plus the fetch it awaits.
Future<void> _settle() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(.zero);
  }
}

final class _FakeUsersRepository implements IUsersRepository {
  const _FakeUsersRepository({required this.users});

  final List<User> users;

  @override
  Stream<User> listUsers({ListUsersFilter? filter}) => Stream<User>.fromIterable(users);

  @override
  Stream<IUserInfo> listUsersInfo({ListUsersFilter? filter}) {
    final ids = filter?.userIds;
    final matched = ids == null ? users : users.where((u) => ids.contains(u.id));
    return Stream<IUserInfo>.fromIterable(matched);
  }

  @override
  Future<User?> createUser(CreateUserData data) async => null;

  @override
  Future<User?> updateUser(UpdateUserData data) async => null;

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) =>
      throw UnimplementedError();

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async => true;

  @override
  Future<bool> deleteUserAvatar(UserId userId) async => true;
}
