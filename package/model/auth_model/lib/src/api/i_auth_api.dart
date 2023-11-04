import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';

abstract interface class IAuthApi {
  Future<AccessCredentials> refreshTokens(RefreshToken refreshToken);
  Future<bool> validateCredentials();

  Future<AuthenticatedUser> signIn(ISignInData signInData, IDeviceInfo device);
  Future<bool> signOut();
  Future<bool> resetPassword(String email);
  Future<bool> setPassword(UserId userId, String email, String password);

  Stream<User> loadUsers(UserId currentUserId);

  Stream<IUserInfo> loadUsersInfo();
  Stream<UserAvatar> loadUserAvatar(List<UserId> userId);
  Future<bool> createUser(User user, String password);
  Future<bool> updateUser(User user);
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo);
}
