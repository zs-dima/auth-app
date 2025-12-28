import 'dart:async';
import 'dart:typed_data';

import 'package:auth_model/src/api/grpc_authentication_converter.dart';
import 'package:auth_model/src/api/i_authentication_api.dart';
import 'package:auth_model/src/api/i_users_api.dart';
import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/api/proto/core.pb.dart' as core;
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:auth_model/src/model/user/auth_user.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_avatar.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/service_api.dart' as service_api;
import 'package:grpc_model/grpc_model.dart' as rpc;

class GrpcClientOptions {
  const GrpcClientOptions(
    this.channel, {
    this.timeout,
    this.metadata,
    this.compression,
    this.interceptors,
  });

  final service_api.ClientChannel channel;

  final Duration? timeout;
  final Map<String, String>? metadata;
  final Codec? compression;
  final Iterable<ClientInterceptor>? interceptors;
}

class GrpcApiClient<T extends Client> {
  GrpcApiClient(
    GrpcClientOptions options, {
    required T Function(
      service_api.ClientChannel channel, {
      CallOptions options,
      Iterable<ClientInterceptor>? interceptors,
    })
    factory,
  }) : client = factory(
         options.channel,
         options: CallOptions(
           timeout: options.timeout,
           metadata: options.metadata,
           compression: options.compression,
         ),
         interceptors: options.interceptors,
       );

  final T client;
}

/// gRPC client for authentication service.
class GrpcAuthenticationClient extends GrpcApiClient<rpc.AuthServiceClient> implements IAuthenticationApi, IUsersApi {
  GrpcAuthenticationClient(super.options) : super(factory: rpc.AuthServiceClient.new);

  // Unauthenticated endpoints
  // ResponseFuture<auth.AuthInfo> signIn(auth.SignInRequest request) => client.signIn(request);
  // ResponseFuture<auth.RefreshTokenReply> refreshTokens(auth.RefreshTokenRequest request) =>
  //     client.refreshTokens(request);
  // ResponseFuture<core.ResultReply> resetPassword(auth.ResetPasswordRequest request) => client.resetPassword(request);

  // Authenticated endpoints
  // ResponseFuture<core.ResultReply> signOut(pb.Empty request) => client.signOut(request);
  // ResponseFuture<core.ResultReply> validateCredentials(pb.Empty request) => client.validateCredentials(request);
  // ResponseFuture<core.ResultReply> setPassword(auth.SetPasswordRequest request) => client.setPassword(request);
  // ResponseStream<auth.UserInfo> loadUsersInfo(pb.Empty request) => client.loadUsersInfo(request);
  // ResponseStream<auth.UserAvatar> loadUserAvatar(auth.LoadUserAvatarRequest request) => client.loadUserAvatar(request);
  // ResponseStream<auth.User> loadUsers(auth.UserId request) => client.loadUsers(request);
  // ResponseFuture<core.ResultReply> createUser(auth.CreateUserRequest request) => client.createUser(request);
  // ResponseFuture<core.ResultReply> updateUser(auth.UpdateUserRequest request) => client.updateUser(request);
  // ResponseFuture<core.ResultReply> saveUserPhoto(auth.UserPhoto request) => client.saveUserPhoto(request);

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
      final result = await client.signOut(rpc.Empty());
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
  Future<IUserInfo> loadUserInfo(UserId userId) async {
    final result = await client.loadUserInfo(
      rpc.UserId(id: userId.toUUID()),
    );
    return result.toUserInfo();
  }

  @override
  Stream<IUserInfo> loadUsersInfo() async* {
    final users = client.loadUsersInfo(rpc.Empty());
    yield* users.where((i) => !i.deleted).map((i) => i.toUserInfo());
  }

  @override
  Stream<UserAvatar> loadUserAvatar([List<UserId>? userId]) async* {
    final request = userId == null
        ? rpc.LoadUserAvatarRequest()
        : (rpc.LoadUserAvatarRequest()..userId.addAll(userId.map((i) => i.toUUID())));

    final avatars = client.loadUserAvatar(request);
    yield* avatars.map(
      (i) => i.toUserAvatar(),
    );
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
  Future<bool> saveUserPhoto(UserId userId, Uint8List? photo) async {
    final userPhoto = rpc.UserPhoto()..userId = userId.toUUID();
    if (photo != null) userPhoto.photo = photo;
    final result = await client.saveUserPhoto(userPhoto);

    return result.result;
  }
}
