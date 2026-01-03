import 'dart:async';

import 'package:auth_model/src/api/grpc_authentication_converter.dart';
import 'package:auth_model/src/api/i_authentication_api.dart';
import 'package:auth_model/src/api/i_users_api.dart';
import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/api/proto/core.pb.dart' as core;
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:grpc/grpc.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:auth_model/src/model/user/auth_user.dart';
import 'package:auth_model/src/model/user/avatar_upload_url.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:core_model/core_model.dart';
import 'package:fixnum/fixnum.dart';
import 'package:grpc_model/grpc_model.dart' as rpc;

/// gRPC client for authentication service.
class GrpcAuthenticationClient extends rpc.GrpcClient<rpc.AuthServiceClient> implements IAuthenticationApi, IUsersApi {
  GrpcAuthenticationClient(super.options) : super(factory: rpc.AuthServiceClient.new);

  @override
  Future<AccessCredentials> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    final result = await client.refreshTokens(
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
    final result = await client.validateCredentials(rpc.Empty());
    return result.result;
  }

  @override
  Future<AuthenticatedUser> signIn(ISignInData signInData, IDeviceInfo device) async {
    final clientInfo = rpc.ClientInfo()
      ..deviceId = device.deviceId
      ..deviceName = device.deviceName
      ..deviceType = '${device.deviceModel} on ${device.deviceOs}'
      ..metadata = (core.Struct()
        ..fields['os'] = core.Value(stringValue: device.deviceOs)
        ..fields['os_version'] = core.Value(stringValue: device.deviceOsVersion)
        ..fields['device_model'] = core.Value(stringValue: device.deviceModel))
      ..clientVersion = device.appVersion;

    final request = rpc.SignInRequest()
      ..email = signInData.login
      ..password = signInData.password
      ..clientInfo = clientInfo
      ..installationId = device.installationId.toUUID();

    final result = await client.signIn(request);

    final accessToken = AccessToken.fromJwtToken(result.accessToken);
    final credentials = AccessCredentials(
      accessToken: accessToken,
      refreshToken: result.refreshToken,
    );

    return AuthUser.authenticated(
          credentials: credentials,
          userId: result.userId.toId(),
        )
        as AuthenticatedUser;
  }

  @override
  Future<bool> signOut(String token) async {
    try {
      final result = await client.signOut(
        rpc.Empty(),
        options: CallOptions(
          metadata: <String, String>{
            'authorization': 'Bearer $token',
          },
        ),
      );
      return result.result;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> resetPassword(String email) async {
    try {
      final result = await client.resetPassword(rpc.ResetPasswordRequest()..email = email);
      return result.result;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> setPassword(UserId userId, String email, String password) async {
    try {
      final result = await client.setPassword(
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
  Stream<IUserInfo> loadUsersInfo(UserId currentUserId, {List<UserId>? userIds}) async* {
    final users = client.loadUsersInfo(
      rpc.LoadUsersInfoRequest()
        ..userId = currentUserId.toUUID()
        ..userIds.addAll(userIds?.map((e) => e.toUUID()) ?? []),
    );
    yield* users.where((i) => !i.deleted).map((i) => i.toUserInfo());
  }

  @override
  Stream<User> loadUsers(UserId currentUserId) async* {
    final users = client.loadUsers(rpc.UserId(id: currentUserId.toUUID()));
    yield* users.map((i) => i.toUser());
  }

  @override
  Future<bool> createUser(User user, String password) async {
    final rpcUser = user.toUser();
    final result = await client.createUser(
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
    final result = await client.updateUser(
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
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize) async {
    final result = await client.getAvatarUploadUrl(
      rpc.GetAvatarUploadUrlRequest()
        ..userId = userId.toUUID()
        ..contentType = contentType
        ..contentSize = Int64(contentSize),
    );

    return AvatarUploadUrl(
      uploadUrl: result.uploadUrl,
      expiresIn: result.expiresIn.toInt(),
    );
  }

  @override
  Future<bool> confirmAvatarUpload(UserId userId) async {
    try {
      final result = await client.confirmAvatarUpload(
        rpc.ConfirmAvatarUploadRequest()..userId = userId.toUUID(),
      );
      return result.result;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> deleteUserAvatar(UserId userId) async {
    try {
      final result = await client.deleteUserAvatar(
        rpc.UserId(id: userId.toUUID()),
      );
      return result.result;
    } on Exception {
      return false;
    }
  }
}
