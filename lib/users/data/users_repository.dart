import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';

abstract interface class IUsersRepository {
  Future<IUserInfo> loadUserInfo(UserId userId);
  Stream<User> loadUsers();

  Stream<IUserInfo> loadUsersInfo();
  Stream<UserAvatar> loadUserAvatar([List<UserId>? userIds]);
  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo);
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
  Future<IUserInfo> loadUserInfo(UserId userId) async => _api.loadUserInfo(userId);

  @override
  Stream<User> loadUsers() async* {
    final currentUserId = await _getUserId();
    if (currentUserId == null) return;
    yield* _api.loadUsers(currentUserId).cast<User>();
  }

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
