import 'dart:async';

import 'package:auth_model/auth_model.dart';

abstract interface class IUsersRepository {
  Stream<User> loadUsers();
  Stream<IUserInfo> loadUsersInfo({List<UserId>? userIds});

  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);

  /// Get a presigned URL for uploading avatar directly to S3.
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize);

  /// Confirm avatar upload.
  Future<bool> confirmAvatarUpload(UserId userId);

  /// Delete user avatar from S3.
  Future<bool> deleteUserAvatar(UserId userId);
}

class UsersRepository implements IUsersRepository {
  const UsersRepository({
    required final IUsersApi apiClient,
    required UserIdCallback getUserId,
  }) : _api = apiClient,
       _getUserId = getUserId;

  final IUsersApi _api;
  final UserIdCallback _getUserId;

  @override
  Stream<User> loadUsers() async* {
    final currentUserId = await _getUserId();
    if (currentUserId == null) return;
    yield* _api.loadUsers(currentUserId).cast<User>();
  }

  @override
  Stream<IUserInfo> loadUsersInfo({List<UserId>? userIds}) async* {
    final currentUserId = await _getUserId();
    if (currentUserId == null) return;

    yield* _api.loadUsersInfo(currentUserId, userIds: userIds);
  }

  @override
  Future<bool> createUser(User user, String password) => _api.createUser(user, password);
  @override
  Future<bool> updateUser(User user) => _api.updateUser(user);

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) =>
      _api.getAvatarUploadUrl(userId, contentType, contentSize);

  @override
  Future<bool> confirmAvatarUpload(UserId userId) => _api.confirmAvatarUpload(userId);

  @override
  Future<bool> deleteUserAvatar(UserId userId) => _api.deleteUserAvatar(userId);
}
