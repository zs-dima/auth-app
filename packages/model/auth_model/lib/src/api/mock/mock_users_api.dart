/*import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/src/api/i_users_api.dart';
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_avatar.dart';
import 'package:auth_model/src/model/user/user_id.dart';

class MockUsersApi implements IUsersApi {
  const MockUsersApi();

  User get _testUser1 => const User(
        id: 1,
        email: 'email 1',
        name: 'name 1',
        role: UserRole.user,
        // deleted: false,
      );
  User get _testUser2 => const User(
        id: 2,
        email: 'email 2',
        name: 'name 2',
        role: UserRole.user,
        // deleted: false,
      );

  @override
  Stream<User> loadUsersInfo(
    UserId currentUserId, {
    int page = 1,
    int perPage = 100,
    String sortBy = 'created_at desc',
  }) =>
      Stream<User>.fromIterable(
        [
          _testUser1,
          _testUser2,
        ],
      );

  @override
  Stream<User> loadUsers(
    UserId currentUserId, {
    int page = 1,
    int perPage = 100,
    String sortBy = 'created_at desc',
  }) =>
      Stream<User>.fromIterable(
        [
          _testUser1,
          _testUser2,
        ],
      );

  @override
  Stream<UserAvatar> loadUserAvatar([List<UserId>? userIds]) => Stream<UserAvatar>.fromIterable(
        [],
      );

  @override
  Future<bool> createUser(User user, String password) async => true;

  @override
  Future<bool> updateUser(User user) async => true;

  @override
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo) async => true;
}
*/
