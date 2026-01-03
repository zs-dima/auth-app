// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'auth.pb.dart' as $0;
import 'core.pb.dart' as $2;

export 'auth.pb.dart';

@$pb.GrpcServiceName('auth.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.AuthInfo> signIn(
    $0.SignInRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$signIn, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> signOut(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$signOut, request, options: options);
  }

  $grpc.ResponseFuture<$0.RefreshTokenReply> refreshTokens(
    $0.RefreshTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshTokens, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> validateCredentials(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validateCredentials, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> resetPassword(
    $0.ResetPasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$resetPassword, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> setPassword(
    $0.SetPasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPassword, request, options: options);
  }

  $grpc.ResponseStream<$0.UserInfo> loadUsersInfo(
    $0.LoadUsersInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$loadUsersInfo, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.User> loadUsers(
    $0.UserId request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$loadUsers, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> createUser(
    $0.CreateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createUser, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> updateUser(
    $0.UpdateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateUser, request, options: options);
  }

  /// Avatar management with presigned URLs (client uploads directly to S3)
  /// Get a presigned URL for uploading avatar directly to S3
  $grpc.ResponseFuture<$0.AvatarUploadUrl> getAvatarUploadUrl(
    $0.GetAvatarUploadUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAvatarUploadUrl, request, options: options);
  }

  /// Confirm avatar upload completed
  $grpc.ResponseFuture<$2.ResultReply> confirmAvatarUpload(
    $0.ConfirmAvatarUploadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmAvatarUpload, request, options: options);
  }

  /// Delete user avatar from S3
  $grpc.ResponseFuture<$2.ResultReply> deleteUserAvatar(
    $0.UserId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteUserAvatar, request, options: options);
  }

  /// Session management
  /// List all active sessions for the current user
  $grpc.ResponseFuture<$0.ListSessionsReply> listSessions(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSessions, request, options: options);
  }

  /// Revoke a specific session
  $grpc.ResponseFuture<$2.ResultReply> revokeSession(
    $0.RevokeSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeSession, request, options: options);
  }

  /// Revoke all sessions except current
  $grpc.ResponseFuture<$0.RevokeSessionsReply> revokeOtherSessions(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeOtherSessions, request, options: options);
  }

  // method descriptors

  static final _$signIn = $grpc.ClientMethod<$0.SignInRequest, $0.AuthInfo>(
      '/auth.AuthService/SignIn', ($0.SignInRequest value) => value.writeToBuffer(), $0.AuthInfo.fromBuffer);
  static final _$signOut = $grpc.ClientMethod<$1.Empty, $2.ResultReply>(
      '/auth.AuthService/SignOut', ($1.Empty value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$refreshTokens = $grpc.ClientMethod<$0.RefreshTokenRequest, $0.RefreshTokenReply>(
      '/auth.AuthService/RefreshTokens',
      ($0.RefreshTokenRequest value) => value.writeToBuffer(),
      $0.RefreshTokenReply.fromBuffer);
  static final _$validateCredentials = $grpc.ClientMethod<$1.Empty, $2.ResultReply>(
      '/auth.AuthService/ValidateCredentials', ($1.Empty value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$resetPassword = $grpc.ClientMethod<$0.ResetPasswordRequest, $2.ResultReply>(
      '/auth.AuthService/ResetPassword',
      ($0.ResetPasswordRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$setPassword = $grpc.ClientMethod<$0.SetPasswordRequest, $2.ResultReply>(
      '/auth.AuthService/SetPassword',
      ($0.SetPasswordRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$loadUsersInfo = $grpc.ClientMethod<$0.LoadUsersInfoRequest, $0.UserInfo>(
      '/auth.AuthService/LoadUsersInfo',
      ($0.LoadUsersInfoRequest value) => value.writeToBuffer(),
      $0.UserInfo.fromBuffer);
  static final _$loadUsers = $grpc.ClientMethod<$0.UserId, $0.User>(
      '/auth.AuthService/LoadUsers', ($0.UserId value) => value.writeToBuffer(), $0.User.fromBuffer);
  static final _$createUser = $grpc.ClientMethod<$0.CreateUserRequest, $2.ResultReply>(
      '/auth.AuthService/CreateUser', ($0.CreateUserRequest value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$updateUser = $grpc.ClientMethod<$0.UpdateUserRequest, $2.ResultReply>(
      '/auth.AuthService/UpdateUser', ($0.UpdateUserRequest value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$getAvatarUploadUrl = $grpc.ClientMethod<$0.GetAvatarUploadUrlRequest, $0.AvatarUploadUrl>(
      '/auth.AuthService/GetAvatarUploadUrl',
      ($0.GetAvatarUploadUrlRequest value) => value.writeToBuffer(),
      $0.AvatarUploadUrl.fromBuffer);
  static final _$confirmAvatarUpload = $grpc.ClientMethod<$0.ConfirmAvatarUploadRequest, $2.ResultReply>(
      '/auth.AuthService/ConfirmAvatarUpload',
      ($0.ConfirmAvatarUploadRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$deleteUserAvatar = $grpc.ClientMethod<$0.UserId, $2.ResultReply>(
      '/auth.AuthService/DeleteUserAvatar', ($0.UserId value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$listSessions = $grpc.ClientMethod<$1.Empty, $0.ListSessionsReply>(
      '/auth.AuthService/ListSessions', ($1.Empty value) => value.writeToBuffer(), $0.ListSessionsReply.fromBuffer);
  static final _$revokeSession = $grpc.ClientMethod<$0.RevokeSessionRequest, $2.ResultReply>(
      '/auth.AuthService/RevokeSession',
      ($0.RevokeSessionRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$revokeOtherSessions = $grpc.ClientMethod<$1.Empty, $0.RevokeSessionsReply>(
      '/auth.AuthService/RevokeOtherSessions',
      ($1.Empty value) => value.writeToBuffer(),
      $0.RevokeSessionsReply.fromBuffer);
}

@$pb.GrpcServiceName('auth.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'auth.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SignInRequest, $0.AuthInfo>(
        'SignIn',
        signIn_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SignInRequest.fromBuffer(value),
        ($0.AuthInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.ResultReply>('SignOut', signOut_Pre, false, false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value), ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshTokenRequest, $0.RefreshTokenReply>(
        'RefreshTokens',
        refreshTokens_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshTokenRequest.fromBuffer(value),
        ($0.RefreshTokenReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.ResultReply>(
        'ValidateCredentials',
        validateCredentials_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResetPasswordRequest, $2.ResultReply>(
        'ResetPassword',
        resetPassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ResetPasswordRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetPasswordRequest, $2.ResultReply>(
        'SetPassword',
        setPassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetPasswordRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoadUsersInfoRequest, $0.UserInfo>(
        'LoadUsersInfo',
        loadUsersInfo_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.LoadUsersInfoRequest.fromBuffer(value),
        ($0.UserInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserId, $0.User>('LoadUsers', loadUsers_Pre, false, true,
        ($core.List<$core.int> value) => $0.UserId.fromBuffer(value), ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateUserRequest, $2.ResultReply>(
        'CreateUser',
        createUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateUserRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateUserRequest, $2.ResultReply>(
        'UpdateUser',
        updateUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateUserRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAvatarUploadUrlRequest, $0.AvatarUploadUrl>(
        'GetAvatarUploadUrl',
        getAvatarUploadUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetAvatarUploadUrlRequest.fromBuffer(value),
        ($0.AvatarUploadUrl value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmAvatarUploadRequest, $2.ResultReply>(
        'ConfirmAvatarUpload',
        confirmAvatarUpload_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmAvatarUploadRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserId, $2.ResultReply>('DeleteUserAvatar', deleteUserAvatar_Pre, false, false,
        ($core.List<$core.int> value) => $0.UserId.fromBuffer(value), ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListSessionsReply>(
        'ListSessions',
        listSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListSessionsReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeSessionRequest, $2.ResultReply>(
        'RevokeSession',
        revokeSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RevokeSessionRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.RevokeSessionsReply>(
        'RevokeOtherSessions',
        revokeOtherSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.RevokeSessionsReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthInfo> signIn_Pre($grpc.ServiceCall $call, $async.Future<$0.SignInRequest> $request) async {
    return signIn($call, await $request);
  }

  $async.Future<$0.AuthInfo> signIn($grpc.ServiceCall call, $0.SignInRequest request);

  $async.Future<$2.ResultReply> signOut_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return signOut($call, await $request);
  }

  $async.Future<$2.ResultReply> signOut($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.RefreshTokenReply> refreshTokens_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RefreshTokenRequest> $request) async {
    return refreshTokens($call, await $request);
  }

  $async.Future<$0.RefreshTokenReply> refreshTokens($grpc.ServiceCall call, $0.RefreshTokenRequest request);

  $async.Future<$2.ResultReply> validateCredentials_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return validateCredentials($call, await $request);
  }

  $async.Future<$2.ResultReply> validateCredentials($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$2.ResultReply> resetPassword_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ResetPasswordRequest> $request) async {
    return resetPassword($call, await $request);
  }

  $async.Future<$2.ResultReply> resetPassword($grpc.ServiceCall call, $0.ResetPasswordRequest request);

  $async.Future<$2.ResultReply> setPassword_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetPasswordRequest> $request) async {
    return setPassword($call, await $request);
  }

  $async.Future<$2.ResultReply> setPassword($grpc.ServiceCall call, $0.SetPasswordRequest request);

  $async.Stream<$0.UserInfo> loadUsersInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoadUsersInfoRequest> $request) async* {
    yield* loadUsersInfo($call, await $request);
  }

  $async.Stream<$0.UserInfo> loadUsersInfo($grpc.ServiceCall call, $0.LoadUsersInfoRequest request);

  $async.Stream<$0.User> loadUsers_Pre($grpc.ServiceCall $call, $async.Future<$0.UserId> $request) async* {
    yield* loadUsers($call, await $request);
  }

  $async.Stream<$0.User> loadUsers($grpc.ServiceCall call, $0.UserId request);

  $async.Future<$2.ResultReply> createUser_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.CreateUserRequest> $request) async {
    return createUser($call, await $request);
  }

  $async.Future<$2.ResultReply> createUser($grpc.ServiceCall call, $0.CreateUserRequest request);

  $async.Future<$2.ResultReply> updateUser_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UpdateUserRequest> $request) async {
    return updateUser($call, await $request);
  }

  $async.Future<$2.ResultReply> updateUser($grpc.ServiceCall call, $0.UpdateUserRequest request);

  $async.Future<$0.AvatarUploadUrl> getAvatarUploadUrl_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GetAvatarUploadUrlRequest> $request) async {
    return getAvatarUploadUrl($call, await $request);
  }

  $async.Future<$0.AvatarUploadUrl> getAvatarUploadUrl($grpc.ServiceCall call, $0.GetAvatarUploadUrlRequest request);

  $async.Future<$2.ResultReply> confirmAvatarUpload_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmAvatarUploadRequest> $request) async {
    return confirmAvatarUpload($call, await $request);
  }

  $async.Future<$2.ResultReply> confirmAvatarUpload($grpc.ServiceCall call, $0.ConfirmAvatarUploadRequest request);

  $async.Future<$2.ResultReply> deleteUserAvatar_Pre($grpc.ServiceCall $call, $async.Future<$0.UserId> $request) async {
    return deleteUserAvatar($call, await $request);
  }

  $async.Future<$2.ResultReply> deleteUserAvatar($grpc.ServiceCall call, $0.UserId request);

  $async.Future<$0.ListSessionsReply> listSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listSessions($call, await $request);
  }

  $async.Future<$0.ListSessionsReply> listSessions($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$2.ResultReply> revokeSession_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RevokeSessionRequest> $request) async {
    return revokeSession($call, await $request);
  }

  $async.Future<$2.ResultReply> revokeSession($grpc.ServiceCall call, $0.RevokeSessionRequest request);

  $async.Future<$0.RevokeSessionsReply> revokeOtherSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return revokeOtherSessions($call, await $request);
  }

  $async.Future<$0.RevokeSessionsReply> revokeOtherSessions($grpc.ServiceCall call, $1.Empty request);
}
