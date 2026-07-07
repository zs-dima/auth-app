//
//  Generated code. Do not modify.
//  source: users/v1/users.proto
//

import "package:connectrpc/connect.dart" as connect;
import "users.pb.dart" as usersv1users;
import "users.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

/// User Service - User CRUD, avatars, admin functions
/// =========================================================================
/// User Management
/// =========================================================================
extension type UserServiceClient(connect.Transport _transport) {
  /// Load user info (server-streaming).
  /// Transport behavior: native server-streaming on gRPC and gRPC-Web;
  /// the Connect protocol streams enveloped JSON or binary-protobuf
  /// frames over the same POST endpoint (works from browsers via fetch).
  Stream<usersv1users.UserInfo> listUsersInfo(
    usersv1users.ListUsersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.UserService.listUsersInfo,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Load users (server-streaming).
  /// Transport behavior: native server-streaming on gRPC and gRPC-Web;
  /// the Connect protocol streams enveloped JSON or binary-protobuf
  /// frames over the same POST endpoint (works from browsers via fetch).
  Stream<usersv1users.User> listUsers(
    usersv1users.ListUsersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.UserService.listUsers,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Create a new user
  Future<usersv1users.User> createUser(
    usersv1users.CreateUserRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UserService.createUser,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Update user
  Future<usersv1users.User> updateUser(
    usersv1users.UpdateUserRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UserService.updateUser,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set password (admin only - bypasses current password requirement)
  /// For user self-service password change, use AuthService.ChangePassword
  Future<googleprotobufempty.Empty> setPassword(
    usersv1users.SetPasswordRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UserService.setPassword,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get presigned URL for avatar upload
  Future<usersv1users.GetAvatarUploadUrlResponse> getAvatarUploadUrl(
    usersv1users.GetAvatarUploadUrlRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UserService.getAvatarUploadUrl,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Confirm avatar upload completed
  Future<googleprotobufempty.Empty> confirmAvatarUpload(
    usersv1users.ConfirmAvatarUploadRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UserService.confirmAvatarUpload,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Delete user avatar
  Future<googleprotobufempty.Empty> deleteAvatar(
    usersv1users.DeleteAvatarRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.UserService.deleteAvatar,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
