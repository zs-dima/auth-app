/*import 'dart:async';

import 'package:auth_model/src/api/i_users_api.dart';
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/avatar_upload_url.dart';
import 'package:auth_model/src/model/user/user.dart';
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
  Future<bool> createUser(User user, String password) async => true;

  @override
  Future<bool> updateUser(User user) async => true;

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) async =>
      const AvatarUploadUrl(uploadUrl: 'https://mock-s3-url.example.com/upload', expiresIn: 3600);

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async => true;

  @override
  Future<bool> deleteUserAvatar(UserId userId) async => true;
}
*/
