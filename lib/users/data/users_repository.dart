import 'dart:async';

import 'package:auth_model/auth_model.dart';

abstract interface class IUsersRepository {
  Stream<User> loadUsers({ListUsersFilter? filter});
  Stream<IUserInfo> loadUsersInfo({ListUsersFilter? filter});

  Future<User?> createUser(CreateUserData data);
  Future<User?> updateUser(UpdateUserData data);

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
  Stream<User> loadUsers({ListUsersFilter? filter}) async* {
    final currentUserId = await _getUserId();
    if (currentUserId == null) return;
    yield* _api.listUsers(currentUserId, filter: filter).cast<User>();
  }

  @override
  Stream<IUserInfo> loadUsersInfo({ListUsersFilter? filter}) async* {
    final currentUserId = await _getUserId();
    if (currentUserId == null) return;

    yield* _api.listUsersInfo(currentUserId, filter: filter);
  }

  @override
  Future<User?> createUser(CreateUserData data) => _api.createUser(data);

  @override
  Future<User?> updateUser(UpdateUserData data) => _api.updateUser(data);

  @override
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) =>
      _api.getAvatarUploadUrl(userId, contentType, contentSize);

  @override
  Future<bool> confirmAvatarUpload(UserId userId) => _api.confirmAvatarUpload(userId);

  @override
  Future<bool> deleteUserAvatar(UserId userId) => _api.deleteUserAvatar(userId);
}
