import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';

abstract interface class IUsersRepository {
  Stream<User> loadUsers(UserId currentUserId);

  Stream<IUserInfo> loadUsersInfo();
  Stream<UserAvatar> loadUserAvatar(List<UserId> userId);
  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo);
}

class UsersRepository implements IUsersRepository {
  final IAuthApi _api;

  UsersRepository({
    required final IAuthApi apiClient,
  }) : _api = apiClient;

  @override
  Stream<User> loadUsers(UserId currentUserId) => _api.loadUsers(currentUserId);

  @override
  Stream<IUserInfo> loadUsersInfo() => _api.loadUsersInfo();

  @override
  Stream<UserAvatar> loadUserAvatar(List<UserId> userId) => _api.loadUserAvatar(userId);

  @override
  Future<bool> createUser(User user, String password) => _api.createUser(user, password);
  @override
  Future<bool> updateUser(User user) => _api.updateUser(user);

  @override
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo) => _api.saveUserPhoto(userId, photo);
}
