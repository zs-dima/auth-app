//
//  Generated code. Do not modify.
//  source: auth.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'auth.pb.dart' as $0;
import 'core.pb.dart' as $2;
import 'google/protobuf/empty.pb.dart' as $1;

export 'auth.pb.dart';

@$pb.GrpcServiceName('auth.AuthService')
class AuthServiceClient extends $grpc.Client {
  static final _$signIn = $grpc.ClientMethod<$0.SignInRequest, $0.AuthInfo>(
      '/auth.AuthService/SignIn',
      ($0.SignInRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.AuthInfo.fromBuffer(value));
  static final _$signOut = $grpc.ClientMethod<$1.Empty, $2.ResultReply>('/auth.AuthService/SignOut',
      ($1.Empty value) => value.writeToBuffer(), ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));
  static final _$refreshTokens = $grpc.ClientMethod<$0.RefreshTokenRequest, $0.RefreshTokenReply>(
      '/auth.AuthService/RefreshTokens',
      ($0.RefreshTokenRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.RefreshTokenReply.fromBuffer(value));
  static final _$validateCredentials = $grpc.ClientMethod<$1.Empty, $2.ResultReply>(
      '/auth.AuthService/ValidateCredentials',
      ($1.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));
  static final _$resetPassword = $grpc.ClientMethod<$0.ResetPasswordRequest, $2.ResultReply>(
      '/auth.AuthService/ResetPassword',
      ($0.ResetPasswordRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));
  static final _$setPassword = $grpc.ClientMethod<$0.SetPasswordRequest, $2.ResultReply>(
      '/auth.AuthService/SetPassword',
      ($0.SetPasswordRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));
  static final _$loadUsersInfo = $grpc.ClientMethod<$1.Empty, $0.UserInfo>('/auth.AuthService/LoadUsersInfo',
      ($1.Empty value) => value.writeToBuffer(), ($core.List<$core.int> value) => $0.UserInfo.fromBuffer(value));
  static final _$loadUserAvatar = $grpc.ClientMethod<$0.LoadUserAvatarRequest, $0.UserAvatar>(
      '/auth.AuthService/LoadUserAvatar',
      ($0.LoadUserAvatarRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.UserAvatar.fromBuffer(value));
  static final _$loadUsers = $grpc.ClientMethod<$0.UserId, $0.User>('/auth.AuthService/LoadUsers',
      ($0.UserId value) => value.writeToBuffer(), ($core.List<$core.int> value) => $0.User.fromBuffer(value));
  static final _$createUser = $grpc.ClientMethod<$0.CreateUserRequest, $2.ResultReply>(
      '/auth.AuthService/CreateUser',
      ($0.CreateUserRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));
  static final _$updateUser = $grpc.ClientMethod<$0.UpdateUserRequest, $2.ResultReply>(
      '/auth.AuthService/UpdateUser',
      ($0.UpdateUserRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));
  static final _$saveUserPhoto = $grpc.ClientMethod<$0.UserPhoto, $2.ResultReply>('/auth.AuthService/SaveUserPhoto',
      ($0.UserPhoto value) => value.writeToBuffer(), ($core.List<$core.int> value) => $2.ResultReply.fromBuffer(value));

  AuthServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options, $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.AuthInfo> signIn($0.SignInRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$signIn, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> signOut($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$signOut, request, options: options);
  }

  $grpc.ResponseFuture<$0.RefreshTokenReply> refreshTokens($0.RefreshTokenRequest request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$refreshTokens, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> validateCredentials($1.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$validateCredentials, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> resetPassword($0.ResetPasswordRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$resetPassword, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> setPassword($0.SetPasswordRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$setPassword, request, options: options);
  }

  $grpc.ResponseStream<$0.UserInfo> loadUsersInfo($1.Empty request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$loadUsersInfo, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.UserAvatar> loadUserAvatar($0.LoadUserAvatarRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$loadUserAvatar, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseStream<$0.User> loadUsers($0.UserId request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$loadUsers, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> createUser($0.CreateUserRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$createUser, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> updateUser($0.UpdateUserRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$updateUser, request, options: options);
  }

  $grpc.ResponseFuture<$2.ResultReply> saveUserPhoto($0.UserPhoto request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$saveUserPhoto, request, options: options);
  }
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
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.UserInfo>('LoadUsersInfo', loadUsersInfo_Pre, false, true,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value), ($0.UserInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoadUserAvatarRequest, $0.UserAvatar>(
        'LoadUserAvatar',
        loadUserAvatar_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.LoadUserAvatarRequest.fromBuffer(value),
        ($0.UserAvatar value) => value.writeToBuffer()));
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
    $addMethod($grpc.ServiceMethod<$0.UserPhoto, $2.ResultReply>(
        'SaveUserPhoto',
        saveUserPhoto_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UserPhoto.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthInfo> signIn_Pre($grpc.ServiceCall call, $async.Future<$0.SignInRequest> request) async {
    return signIn(call, await request);
  }

  $async.Future<$2.ResultReply> signOut_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return signOut(call, await request);
  }

  $async.Future<$0.RefreshTokenReply> refreshTokens_Pre(
      $grpc.ServiceCall call, $async.Future<$0.RefreshTokenRequest> request) async {
    return refreshTokens(call, await request);
  }

  $async.Future<$2.ResultReply> validateCredentials_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async {
    return validateCredentials(call, await request);
  }

  $async.Future<$2.ResultReply> resetPassword_Pre(
      $grpc.ServiceCall call, $async.Future<$0.ResetPasswordRequest> request) async {
    return resetPassword(call, await request);
  }

  $async.Future<$2.ResultReply> setPassword_Pre(
      $grpc.ServiceCall call, $async.Future<$0.SetPasswordRequest> request) async {
    return setPassword(call, await request);
  }

  $async.Stream<$0.UserInfo> loadUsersInfo_Pre($grpc.ServiceCall call, $async.Future<$1.Empty> request) async* {
    yield* loadUsersInfo(call, await request);
  }

  $async.Stream<$0.UserAvatar> loadUserAvatar_Pre(
      $grpc.ServiceCall call, $async.Future<$0.LoadUserAvatarRequest> request) async* {
    yield* loadUserAvatar(call, await request);
  }

  $async.Stream<$0.User> loadUsers_Pre($grpc.ServiceCall call, $async.Future<$0.UserId> request) async* {
    yield* loadUsers(call, await request);
  }

  $async.Future<$2.ResultReply> createUser_Pre(
      $grpc.ServiceCall call, $async.Future<$0.CreateUserRequest> request) async {
    return createUser(call, await request);
  }

  $async.Future<$2.ResultReply> updateUser_Pre(
      $grpc.ServiceCall call, $async.Future<$0.UpdateUserRequest> request) async {
    return updateUser(call, await request);
  }

  $async.Future<$2.ResultReply> saveUserPhoto_Pre($grpc.ServiceCall call, $async.Future<$0.UserPhoto> request) async {
    return saveUserPhoto(call, await request);
  }

  $async.Future<$0.AuthInfo> signIn($grpc.ServiceCall call, $0.SignInRequest request);
  $async.Future<$2.ResultReply> signOut($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$0.RefreshTokenReply> refreshTokens($grpc.ServiceCall call, $0.RefreshTokenRequest request);
  $async.Future<$2.ResultReply> validateCredentials($grpc.ServiceCall call, $1.Empty request);
  $async.Future<$2.ResultReply> resetPassword($grpc.ServiceCall call, $0.ResetPasswordRequest request);
  $async.Future<$2.ResultReply> setPassword($grpc.ServiceCall call, $0.SetPasswordRequest request);
  $async.Stream<$0.UserInfo> loadUsersInfo($grpc.ServiceCall call, $1.Empty request);
  $async.Stream<$0.UserAvatar> loadUserAvatar($grpc.ServiceCall call, $0.LoadUserAvatarRequest request);
  $async.Stream<$0.User> loadUsers($grpc.ServiceCall call, $0.UserId request);
  $async.Future<$2.ResultReply> createUser($grpc.ServiceCall call, $0.CreateUserRequest request);
  $async.Future<$2.ResultReply> updateUser($grpc.ServiceCall call, $0.UpdateUserRequest request);
  $async.Future<$2.ResultReply> saveUserPhoto($grpc.ServiceCall call, $0.UserPhoto request);
}
