import 'dart:async';

import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/avatar_upload_url.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_id.dart';

/// Filter options for listing users.
class ListUsersFilter {
  const ListUsersFilter({
    this.userIds,
    this.statuses,
    this.roles,
    this.query,
    this.pageSize,
    this.pageToken,
  });

  /// Filter by specific user IDs.
  final List<UserId>? userIds;

  /// Filter by user statuses.
  final List<UserStatus>? statuses;

  /// Filter by user roles.
  final List<UserRole>? roles;

  /// Search query (name, email).
  final String? query;

  /// Page size for pagination.
  final int? pageSize;

  /// Page token for pagination.
  final String? pageToken;
}

/// Data for creating a new user.
class CreateUserData {
  const CreateUserData({
    required this.name,
    required this.email,
    this.phone,
    this.password,
    this.role,
    this.locale,
    this.timezone,
  });

  final String name;
  final String email;
  final String? phone;
  final String? password;
  final UserRole? role;
  final String? locale;
  final String? timezone;
}

/// Data for updating a user with field mask support.
class UpdateUserData {
  const UpdateUserData({
    required this.userId,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.status,
    this.locale,
    this.timezone,
  });

  final UserId userId;
  final String? name;
  final String? email;
  final String? phone;
  final UserRole? role;
  final UserStatus? status;
  final String? locale;
  final String? timezone;

  /// Get the list of fields to update (for FieldMask).
  List<String> get updateFields => [
    if (name != null) 'name',
    if (email != null) 'email',
    if (phone != null) 'phone',
    if (role != null) 'role',
    if (status != null) 'status',
    if (locale != null) 'locale',
    if (timezone != null) 'timezone',
  ];
}

/// User management API interface.
///
/// Handles user CRUD operations, avatar management, and admin functions.
/// Corresponds to the UserService in users.proto.
abstract interface class IUsersApi {
  /// List user info (streaming).
  /// Returns lightweight user info for listings.
  Stream<IUserInfo> listUsersInfo(UserId currentUserId, {ListUsersFilter? filter});

  /// List users (streaming).
  /// Returns full user details.
  Stream<User> listUsers(UserId currentUserId, {ListUsersFilter? filter});

  /// Create a new user.
  /// Returns the created user, or null on failure.
  Future<User?> createUser(CreateUserData data);

  /// Update user with partial updates using FieldMask.
  /// Only fields specified in [data] will be updated.
  /// Returns the updated user, or null on failure.
  Future<User?> updateUser(UpdateUserData data);

  /// Set password (admin only - bypasses current password requirement).
  Future<bool> setPassword({required UserId userId, required String password});

  /// Get a presigned URL for uploading avatar directly to S3.
  Future<AvatarUploadUrl> getAvatarUploadUrl(UserId userId, String contentType, int contentSize);

  /// Confirm avatar upload.
  Future<bool> confirmAvatarUpload(UserId userId);

  /// Delete user avatar from S3.
  Future<bool> deleteUserAvatar(UserId userId);
}
