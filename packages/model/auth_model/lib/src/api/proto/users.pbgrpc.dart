// This is a generated file - do not edit.
//
// Generated from users.proto.

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

import 'users.pb.dart' as $0;

export 'users.pb.dart';

/// User Service - User CRUD, avatars, admin functions
@$pb.GrpcServiceName('users.UserService')
class UserServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  UserServiceClient(super.channel, {super.options, super.interceptors});

  /// Load user info (streaming)
  $grpc.ResponseStream<$0.UserInfo> listUsersInfo(
    $0.ListUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$listUsersInfo, $async.Stream.fromIterable([request]), options: options);
  }

  /// Load users (streaming)
  $grpc.ResponseStream<$0.User> listUsers(
    $0.ListUsersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$listUsers, $async.Stream.fromIterable([request]), options: options);
  }

  /// Create a new user
  $grpc.ResponseFuture<$0.User> createUser(
    $0.CreateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createUser, request, options: options);
  }

  /// Update user
  $grpc.ResponseFuture<$0.User> updateUser(
    $0.UpdateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateUser, request, options: options);
  }

  /// Set password (admin only - bypasses current password requirement)
  $grpc.ResponseFuture<$1.Empty> setPassword(
    $0.SetPasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPassword, request, options: options);
  }

  /// Get presigned URL for avatar upload
  $grpc.ResponseFuture<$0.GetAvatarUploadUrlResponse> getAvatarUploadUrl(
    $0.GetAvatarUploadUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAvatarUploadUrl, request, options: options);
  }

  /// Confirm avatar upload completed
  $grpc.ResponseFuture<$1.Empty> confirmAvatarUpload(
    $0.ConfirmAvatarUploadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmAvatarUpload, request, options: options);
  }

  /// Delete user avatar
  $grpc.ResponseFuture<$1.Empty> deleteAvatar(
    $0.DeleteAvatarRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteAvatar, request, options: options);
  }

  // method descriptors

  static final _$listUsersInfo = $grpc.ClientMethod<$0.ListUsersRequest, $0.UserInfo>(
      '/users.UserService/ListUsersInfo', ($0.ListUsersRequest value) => value.writeToBuffer(), $0.UserInfo.fromBuffer);
  static final _$listUsers = $grpc.ClientMethod<$0.ListUsersRequest, $0.User>(
      '/users.UserService/ListUsers', ($0.ListUsersRequest value) => value.writeToBuffer(), $0.User.fromBuffer);
  static final _$createUser = $grpc.ClientMethod<$0.CreateUserRequest, $0.User>(
      '/users.UserService/CreateUser', ($0.CreateUserRequest value) => value.writeToBuffer(), $0.User.fromBuffer);
  static final _$updateUser = $grpc.ClientMethod<$0.UpdateUserRequest, $0.User>(
      '/users.UserService/UpdateUser', ($0.UpdateUserRequest value) => value.writeToBuffer(), $0.User.fromBuffer);
  static final _$setPassword = $grpc.ClientMethod<$0.SetPasswordRequest, $1.Empty>(
      '/users.UserService/SetPassword', ($0.SetPasswordRequest value) => value.writeToBuffer(), $1.Empty.fromBuffer);
  static final _$getAvatarUploadUrl = $grpc.ClientMethod<$0.GetAvatarUploadUrlRequest, $0.GetAvatarUploadUrlResponse>(
      '/users.UserService/GetAvatarUploadUrl',
      ($0.GetAvatarUploadUrlRequest value) => value.writeToBuffer(),
      $0.GetAvatarUploadUrlResponse.fromBuffer);
  static final _$confirmAvatarUpload = $grpc.ClientMethod<$0.ConfirmAvatarUploadRequest, $1.Empty>(
      '/users.UserService/ConfirmAvatarUpload',
      ($0.ConfirmAvatarUploadRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$deleteAvatar = $grpc.ClientMethod<$0.DeleteAvatarRequest, $1.Empty>(
      '/users.UserService/DeleteAvatar', ($0.DeleteAvatarRequest value) => value.writeToBuffer(), $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('users.UserService')
abstract class UserServiceBase extends $grpc.Service {
  $core.String get $name => 'users.UserService';

  UserServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListUsersRequest, $0.UserInfo>(
        'ListUsersInfo',
        listUsersInfo_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.ListUsersRequest.fromBuffer(value),
        ($0.UserInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListUsersRequest, $0.User>(
        'ListUsers',
        listUsers_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.ListUsersRequest.fromBuffer(value),
        ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateUserRequest, $0.User>(
        'CreateUser',
        createUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateUserRequest.fromBuffer(value),
        ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateUserRequest, $0.User>(
        'UpdateUser',
        updateUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateUserRequest.fromBuffer(value),
        ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetPasswordRequest, $1.Empty>(
        'SetPassword',
        setPassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetPasswordRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAvatarUploadUrlRequest, $0.GetAvatarUploadUrlResponse>(
        'GetAvatarUploadUrl',
        getAvatarUploadUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetAvatarUploadUrlRequest.fromBuffer(value),
        ($0.GetAvatarUploadUrlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmAvatarUploadRequest, $1.Empty>(
        'ConfirmAvatarUpload',
        confirmAvatarUpload_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmAvatarUploadRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeleteAvatarRequest, $1.Empty>(
        'DeleteAvatar',
        deleteAvatar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeleteAvatarRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Stream<$0.UserInfo> listUsersInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ListUsersRequest> $request) async* {
    yield* listUsersInfo($call, await $request);
  }

  $async.Stream<$0.UserInfo> listUsersInfo($grpc.ServiceCall call, $0.ListUsersRequest request);

  $async.Stream<$0.User> listUsers_Pre($grpc.ServiceCall $call, $async.Future<$0.ListUsersRequest> $request) async* {
    yield* listUsers($call, await $request);
  }

  $async.Stream<$0.User> listUsers($grpc.ServiceCall call, $0.ListUsersRequest request);

  $async.Future<$0.User> createUser_Pre($grpc.ServiceCall $call, $async.Future<$0.CreateUserRequest> $request) async {
    return createUser($call, await $request);
  }

  $async.Future<$0.User> createUser($grpc.ServiceCall call, $0.CreateUserRequest request);

  $async.Future<$0.User> updateUser_Pre($grpc.ServiceCall $call, $async.Future<$0.UpdateUserRequest> $request) async {
    return updateUser($call, await $request);
  }

  $async.Future<$0.User> updateUser($grpc.ServiceCall call, $0.UpdateUserRequest request);

  $async.Future<$1.Empty> setPassword_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetPasswordRequest> $request) async {
    return setPassword($call, await $request);
  }

  $async.Future<$1.Empty> setPassword($grpc.ServiceCall call, $0.SetPasswordRequest request);

  $async.Future<$0.GetAvatarUploadUrlResponse> getAvatarUploadUrl_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GetAvatarUploadUrlRequest> $request) async {
    return getAvatarUploadUrl($call, await $request);
  }

  $async.Future<$0.GetAvatarUploadUrlResponse> getAvatarUploadUrl(
      $grpc.ServiceCall call, $0.GetAvatarUploadUrlRequest request);

  $async.Future<$1.Empty> confirmAvatarUpload_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmAvatarUploadRequest> $request) async {
    return confirmAvatarUpload($call, await $request);
  }

  $async.Future<$1.Empty> confirmAvatarUpload($grpc.ServiceCall call, $0.ConfirmAvatarUploadRequest request);

  $async.Future<$1.Empty> deleteAvatar_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DeleteAvatarRequest> $request) async {
    return deleteAvatar($call, await $request);
  }

  $async.Future<$1.Empty> deleteAvatar($grpc.ServiceCall call, $0.DeleteAvatarRequest request);
}
