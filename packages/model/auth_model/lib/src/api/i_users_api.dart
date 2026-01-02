import 'dart:async';

import 'package:auth_model/src/model/user/avatar_upload_url.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_id.dart';

abstract interface class IUsersApi {
  Stream<IUserInfo> loadUsers(UserId currentUserId);
  Stream<IUserInfo> loadUsersInfo(UserId currentUserId, {List<UserId>? userIds});

  // Future<User> loadUser(UserId userId);
  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);
  // Future<bool> updateUserPassword(UserId userId, String password, String currentPassword);

  /// Get a presigned URL for uploading avatar directly to S3.
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize);

  /// Confirm avatar upload.
  Future<bool> confirmAvatarUpload(UserId userId);

  /// Delete user avatar from S3.
  Future<bool> deleteUserAvatar(UserId userId);
}
