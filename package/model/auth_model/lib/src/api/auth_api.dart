import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';
import 'package:auth_model/src/api/auth_api_converter.dart';
import 'package:auth_model/src/api/proto/auth.pb.dart' as rpc;
import 'package:core_model/core_model.dart';
import 'package:grpc_model/grpc_model.dart' as rpc;

class AuthApi implements IAuthApi {
  final AuthApiClient _client;

  AuthApi({required AuthApiClient client}) : _client = client;

  @override
  Future<AccessCredentials> refreshTokens(RefreshToken refreshToken) async {
    final result = await _client.refreshTokens(
      rpc.RefreshTokenRequest()..refreshToken = refreshToken,
    );

    final accessToken = AccessToken.fromJwtToken(result.accessToken);

    return AccessCredentials(
      accessToken: accessToken,
      refreshToken: result.refreshToken,
    );
  }

  @override
  Future<bool> validateCredentials() async {
    final result = await _client.validateCredentials(rpc.Empty());
    return result.result;
  }

  @override
  Future<AuthenticatedUser> signIn(ISignInData signInData, IDeviceInfo device) async {
    final osInfo = rpc.OsInfo()
      ..os = device.deviceOs.toOs()
      ..version = device.deviceOsVersion;

    final deviceInfo = rpc.DeviceInfo()
      ..id = device.deviceId.toUUID()
      ..osInfo = osInfo
      ..name = device.deviceName
      ..model = device.deviceModel;

    final request = rpc.SignInRequest()
      ..email = signInData.login
      ..password = signInData.password
      ..deviceInfo = deviceInfo
      ..installationId = device.installationId.toUUID();

    final result = await _client.signIn(request);

    final accessToken = AccessToken.fromJwtToken(result.accessToken);
    final credentials = AccessCredentials(
      accessToken: accessToken,
      refreshToken: result.refreshToken,
    );

    return AuthUser.authenticated(
      credentials: credentials,
      userInfo: result.toUserInfo(signInData.login),
    ) as AuthenticatedUser;
  }

  @override
  Future<bool> signOut() async {
    try {
      final result = await _client.signOut(rpc.Empty());
      return result.result;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      final result = await _client.resetPassword(rpc.ResetPasswordRequest()..email = email);
      return result.result;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> setPassword(UserId userId, String email, String password) async {
    try {
      final result = await _client.setPassword(
        rpc.SetPasswordRequest()
          ..userId = userId.toUUID()
          ..email = email
          ..password = password,
      );
      return result.result;
    } on Exception {
      return false;
    }
  }

  @override
  Stream<IUserInfo> loadUsersInfo() async* {
    final users = _client.loadUsersInfo(rpc.Empty());
    yield* users.where((i) => !i.deleted).map((i) => i.toUserInfo());
  }

  @override
  Stream<UserAvatar> loadUserAvatar(List<UserId> userId) async* {
    final request = rpc.LoadUserAvatarRequest()..userId.addAll(userId.map((i) => i.toUUID()));
    final avatars = _client.loadUserAvatar(request);
    yield* avatars.map(
      (i) => i.toUserAvatar(),
    );
  }

  @override
  Stream<User> loadUsers(UserId currentUserId) async* {
    final users = _client.loadUsers(rpc.UserId()..id = currentUserId.toUUID());
    yield* users.map((i) => i.toUser());
  }

  @override
  Future<bool> createUser(User user, String password) async {
    final rpcUser = user.toUser();
    final result = await _client.createUser(
      rpc.CreateUserRequest()
        ..id = rpcUser.id
        ..name = rpcUser.name
        ..email = rpcUser.email
        ..role = rpcUser.role
        ..deleted = rpcUser.deleted
        ..password = password,
    );
    return result.result;
  }

  @override
  Future<bool> updateUser(User user) async {
    final rpcUser = user.toUser();
    final result = await _client.updateUser(
      rpc.UpdateUserRequest()
        ..id = rpcUser.id
        ..name = rpcUser.name
        ..email = rpcUser.email
        ..role = rpcUser.role
        ..deleted = rpcUser.deleted,
    );
    return result.result;
  }

  @override
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo) async {
    final userPhoto = rpc.UserPhoto()..userId = userId.toUUID();
    if (photo != null) userPhoto.photo = photo;
    final result = await _client.saveUserPhoto(userPhoto);

    return result.result;
  }
}
