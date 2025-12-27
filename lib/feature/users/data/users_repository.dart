import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';

abstract interface class IUsersRepository {
  Stream<User> loadUsers(UserId currentUserId);

  Stream<IUserInfo> loadUsersInfo();
  Stream<UserAvatar> loadUserAvatar([List<UserId>? userIds]);
  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo);
}

class UsersRepository implements IUsersRepository {
  const UsersRepository({
    required final IUsersApi apiClient,
  }) : _api = apiClient;

  final IUsersApi _api;

  @override
  Stream<User> loadUsers(UserId currentUserId) => _api.loadUsers(currentUserId).cast<User>();

  @override
  Stream<IUserInfo> loadUsersInfo() => _api.loadUsersInfo();

  @override
  Stream<UserAvatar> loadUserAvatar([List<UserId>? userIds]) => _api.loadUserAvatar(userIds);

  @override
  Future<bool> createUser(User user, String password) => _api.createUser(user, password);
  @override
  Future<bool> updateUser(User user) => _api.updateUser(user);

  @override
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo) => _api.saveUserPhoto(userId, photo);
}
