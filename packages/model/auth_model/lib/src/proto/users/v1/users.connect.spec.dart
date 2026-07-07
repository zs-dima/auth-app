//
//  Generated code. Do not modify.
//  source: users/v1/users.proto
//

import "package:connectrpc/connect.dart" as connect;
import "users.pb.dart" as usersv1users;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

/// User Service - User CRUD, avatars, admin functions
/// =========================================================================
/// User Management
/// =========================================================================
abstract final class UserService {
  /// Fully-qualified name of the UserService service.
  static const name = 'users.v1.UserService';

  /// Load user info (server-streaming).
  /// Transport behavior: native server-streaming on gRPC and gRPC-Web;
  /// the Connect protocol streams enveloped JSON or binary-protobuf
  /// frames over the same POST endpoint (works from browsers via fetch).
  static const listUsersInfo = connect.Spec(
    '/$name/ListUsersInfo',
    connect.StreamType.server,
    usersv1users.ListUsersRequest.new,
    usersv1users.UserInfo.new,
  );

  /// Load users (server-streaming).
  /// Transport behavior: native server-streaming on gRPC and gRPC-Web;
  /// the Connect protocol streams enveloped JSON or binary-protobuf
  /// frames over the same POST endpoint (works from browsers via fetch).
  static const listUsers = connect.Spec(
    '/$name/ListUsers',
    connect.StreamType.server,
    usersv1users.ListUsersRequest.new,
    usersv1users.User.new,
  );

  /// Create a new user
  static const createUser = connect.Spec(
    '/$name/CreateUser',
    connect.StreamType.unary,
    usersv1users.CreateUserRequest.new,
    usersv1users.User.new,
  );

  /// Update user
  static const updateUser = connect.Spec(
    '/$name/UpdateUser',
    connect.StreamType.unary,
    usersv1users.UpdateUserRequest.new,
    usersv1users.User.new,
  );

  /// Set password (admin only - bypasses current password requirement)
  /// For user self-service password change, use AuthService.ChangePassword
  static const setPassword = connect.Spec(
    '/$name/SetPassword',
    connect.StreamType.unary,
    usersv1users.SetPasswordRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Get presigned URL for avatar upload
  static const getAvatarUploadUrl = connect.Spec(
    '/$name/GetAvatarUploadUrl',
    connect.StreamType.unary,
    usersv1users.GetAvatarUploadUrlRequest.new,
    usersv1users.GetAvatarUploadUrlResponse.new,
  );

  /// Confirm avatar upload completed
  static const confirmAvatarUpload = connect.Spec(
    '/$name/ConfirmAvatarUpload',
    connect.StreamType.unary,
    usersv1users.ConfirmAvatarUploadRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Delete user avatar
  static const deleteAvatar = connect.Spec(
    '/$name/DeleteAvatar',
    connect.StreamType.unary,
    usersv1users.DeleteAvatarRequest.new,
    googleprotobufempty.Empty.new,
  );
}
