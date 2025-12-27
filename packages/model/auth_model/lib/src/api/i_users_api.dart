import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_avatar.dart';
import 'package:auth_model/src/model/user/user_id.dart';

abstract interface class IUsersApi {
  Stream<IUserInfo> loadUsers(UserId currentUserId);
  Stream<IUserInfo> loadUsersInfo();

  Stream<UserAvatar> loadUserAvatar([List<UserId>? userIds]);
  // Future<User> loadUser(UserId userId);
  // Future<IUserInfo> loadUserInfo(UserId userId);
  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);
  // Future<bool> updateUserPassword(UserId userId, String password, String currentPassword);
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo);
}
