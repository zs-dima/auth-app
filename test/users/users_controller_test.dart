import 'dart:async';

import 'package:auth_app/_core/message/ui_messenger.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/data/users_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const kIdA = 'a7f1c8d2-0000-4000-8000-000000000001';
  const kIdB = 'a7f1c8d2-0000-4000-8000-000000000002';

  group('UsersController.getUserInfo', () {
    // The wedge this pins: `reset()` publishes `loading` WITHOUT starting a load, and callers do
    // exactly that right before asking for the current user. Waiting on the state would park on a
    // `UsersLoadedState` that nobody will ever emit — forever, holding the caller's mutex with it.
    test('returns instead of parking when the state is loading but no load is in flight', () async {
      final repository = _FakeUsersRepository(users: <User>[_user(kIdB)]);
      final controller = _buildController(repository);
      addTearDown(controller.dispose);

      await controller.reset();
      expect(controller.isProcessing, isFalse, reason: 'reset publishes `loading` but starts no load');

      final result = await controller.getUserInfo(kIdB).timeout(const Duration(seconds: 2));

      expect(result.id, equals(kIdB));
      expect(repository.listUsersInfoCalls, equals(1), reason: 'falls through to the targeted fetch');
    });

    test('waits for an in-flight listUsers and serves the user from its result', () async {
      final repository = _FakeUsersRepository(users: <User>[_user(kIdA), _user(kIdB)]);
      final controller = _buildController(repository);
      addTearDown(controller.dispose);

      controller.listUsers(kIdA);
      expect(controller.isProcessing, isTrue);

      final result = await controller.getUserInfo(kIdB).timeout(const Duration(seconds: 2));

      expect(result.id, equals(kIdB));
      expect(repository.listUsersInfoCalls, isZero, reason: 'the in-flight list already had the user');
    });
  });
}

User _user(UserId id) => .new(id: id, name: 'User $id', email: '$id@mail.com', role: .user, status: .active);

UsersController _buildController(IUsersRepository repository) => .new(repository: repository, messenger: UiMessenger());

final class _FakeUsersRepository implements IUsersRepository {
  _FakeUsersRepository({required this.users});

  final List<User> users;
  int listUsersInfoCalls = 0;

  @override
  Stream<User> listUsers({ListUsersFilter? filter}) async* {
    // One event-loop turn, so the controller is genuinely mid-flight while the test asks.
    await Future<void>.delayed(.zero);
    yield* Stream<User>.fromIterable(users);
  }

  @override
  Stream<IUserInfo> listUsersInfo({ListUsersFilter? filter}) {
    listUsersInfoCalls++;
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
