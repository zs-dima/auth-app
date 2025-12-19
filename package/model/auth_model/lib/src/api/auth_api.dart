import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';
import 'package:auth_model/src/api/auth_api_converter.dart';
import 'package:auth_model/src/api/proto/auth.pb.dart' as rpc;
import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart';
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as pb;

class AuthApi implements IAuthApi {
  final AuthApiClient _client;

  const AuthApi({required AuthApiClient client}) : _client = client;

  @override
  Future<AccessCredentials> refreshTokens(RefreshToken refreshToken) async {
    try {
      final result = await _client.refreshTokens(rpc.RefreshTokenRequest()..refreshToken = refreshToken);

      return AccessCredentials(
        accessToken: AccessToken.fromJwtToken(result.accessToken),
        refreshToken: result.refreshToken,
      );
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Token refresh'), s);
    }
  }

  @override
  Future<bool> validateCredentials() async {
    try {
      final result = await _client.validateCredentials(pb.Empty());
      return result.result;
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Validate credentials'), s);
    }
  }

  @override
  Future<AuthenticatedUser> signIn(ISignInData signInData, IDeviceInfo device) async {
    try {
      final request = rpc.SignInRequest()
        ..email = signInData.login
        ..password = signInData.password
        ..installationId = device.installationId.toUUID()
        ..deviceInfo = (rpc.DeviceInfo()
          ..id = device.deviceId.toUUID()
          ..name = device.deviceName
          ..model = device.deviceModel
          ..osInfo = (rpc.OsInfo()
            ..os = device.deviceOs.toOs()
            ..version = device.deviceOsVersion));

      final result = await _client.signIn(request);

      return AuthenticatedUser(
        credentials: AccessCredentials(
          accessToken: AccessToken.fromJwtToken(result.accessToken),
          refreshToken: result.refreshToken,
        ),
        userInfo: result.toUserInfo(signInData.login),
      );
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Sign in'), s);
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      final result = await _client.signOut(pb.Empty());
      return result.result;
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Sign out'), s);
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      final result = await _client.resetPassword(rpc.ResetPasswordRequest()..email = email);
      return result.result;
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Reset password'), s);
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
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Set password'), s);
    }
  }

  @override
  Stream<IUserInfo> loadUsersInfo() => _client
      .loadUsersInfo(pb.Empty())
      .where((i) => !i.deleted)
      .map((i) => i.toUserInfo())
      .handleError(_handleStreamError('Load users info'), test: (e) => e is GrpcError);

  @override
  Stream<UserAvatar> loadUserAvatar(List<UserId> userId) {
    final request = rpc.LoadUserAvatarRequest()..userId.addAll(userId.map((i) => i.toUUID()));
    return _client
        .loadUserAvatar(request)
        .map((i) => i.toUserAvatar())
        .handleError(_handleStreamError('Load user avatar'), test: (e) => e is GrpcError);
  }

  @override
  Stream<User> loadUsers(UserId currentUserId) => _client
      .loadUsers(rpc.UserId()..id = currentUserId.toUUID())
      .map((i) => i.toUser())
      .handleError(_handleStreamError('Load users'), test: (e) => e is GrpcError);

  @override
  Future<bool> createUser(User user, String password) async {
    try {
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
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Create user'), s);
    }
  }

  @override
  Future<bool> updateUser(User user) async {
    try {
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
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Update user'), s);
    }
  }

  @override
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo) async {
    try {
      final userPhoto = rpc.UserPhoto()..userId = userId.toUUID();
      if (photo != null) userPhoto.photo = photo;
      final result = await _client.saveUserPhoto(userPhoto);
      return result.result;
    } on GrpcError catch (e, s) {
      Error.throwWithStackTrace(AuthError.fromGrpc(e, 'Save user photo'), s);
    }
  }

  void Function(Object, StackTrace) _handleStreamError(String operation) =>
      (e, s) => Error.throwWithStackTrace(AuthError.fromGrpc(e as GrpcError, operation), s);
}
