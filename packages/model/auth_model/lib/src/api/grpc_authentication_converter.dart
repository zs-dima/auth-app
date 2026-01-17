import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/api/proto/users.pb.dart' as users;
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_info.dart';
import 'package:grpc_model/grpc_model.dart' as core;
import 'package:grpc_model/grpc_model.dart' hide UserRole, UserStatus;

// =============================================================================
// USER ROLE MAPPING
// =============================================================================

/// Maps app UserRole to proto UserRole.
extension AppUserRoleX on UserRole {
  core.UserRole toProtoRole() => switch (this) {
    .admin => core.UserRole.USER_ROLE_ADMIN,
    .user => core.UserRole.USER_ROLE_USER,
    .guest => core.UserRole.USER_ROLE_GUEST,
  };
}

/// Maps proto UserRole to app UserRole.
extension ProtoUserRoleX on core.UserRole {
  UserRole toRole() => switch (this) {
    core.UserRole.USER_ROLE_ADMIN => .admin,
    core.UserRole.USER_ROLE_USER => .user,
    core.UserRole.USER_ROLE_GUEST => .guest,
    _ => .guest,
  };
}

// =============================================================================
// USER STATUS MAPPING
// =============================================================================

/// Maps app UserStatus to proto UserStatus.
extension AppUserStatusX on UserStatus {
  core.UserStatus toProtoStatus() => switch (this) {
    .unspecified => core.UserStatus.USER_STATUS_UNSPECIFIED,
    .active => core.UserStatus.USER_STATUS_ACTIVE,
    .pending => core.UserStatus.USER_STATUS_PENDING,
    .suspended => core.UserStatus.USER_STATUS_SUSPENDED,
    .deleted => core.UserStatus.USER_STATUS_DELETED,
  };
}

/// Maps proto UserStatus to app UserStatus.
extension ProtoUserStatusX on core.UserStatus {
  UserStatus toStatus() => switch (this) {
    core.UserStatus.USER_STATUS_ACTIVE => .active,
    core.UserStatus.USER_STATUS_PENDING => .pending,
    core.UserStatus.USER_STATUS_SUSPENDED => .suspended,
    core.UserStatus.USER_STATUS_DELETED => .deleted,
    _ => .unspecified,
  };
}

// =============================================================================
// USER SNAPSHOT (from auth.proto)
// =============================================================================

/// Converts proto UserSnapshot to IUserInfo.
extension UserSnapshotX on rpc.UserSnapshot {
  IUserInfo toUserInfo() => UserInfo(
    id: userId.toId(),
    name: displayName,
    email: email,
    phone: phone.isNotEmpty ? phone : null,
    role: role.toRole(),
    status: .active, // UserSnapshot doesn't have status, assume active
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
  );
}

// =============================================================================
// USER INFO (from users.proto)
// =============================================================================

/// Converts proto UserInfo to app IUserInfo.
extension ProtoUserInfoX on users.UserInfo {
  IUserInfo toUserInfo() => UserInfo(
    id: id.toId(),
    name: name,
    email: email,
    phone: phone.isNotEmpty ? phone : null,
    role: role.toRole(),
    status: status.toStatus(),
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    locale: locale.isNotEmpty ? locale : null,
    timezone: timezone.isNotEmpty ? timezone : null,
  );
}

// =============================================================================
// USER (from users.proto)
// =============================================================================

/// Converts proto User to app User.
extension ProtoUserX on users.User {
  User toUser() => .new(
    id: id.toId(),
    name: name,
    email: email,
    phone: phone.isNotEmpty ? phone : null,
    role: role.toRole(),
    status: status.toStatus(),
    emailVerified: emailVerified,
    phoneVerified: phoneVerified,
    mfaEnabled: mfaEnabled,
    hasPassword: hasPassword,
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    locale: locale.isNotEmpty ? locale : null,
    timezone: timezone.isNotEmpty ? timezone : null,
    createdAt: hasCreatedAt() ? createdAt.toDateTime() : null,
    updatedAt: hasUpdatedAt() ? updatedAt.toDateTime() : null,
  );
}

/// Converts app User to proto User.
extension AppUserX on User {
  users.User toProtoUser() => users.User()
    ..id = id.toUUID()
    ..name = name
    ..email = email
    ..role = role.toProtoRole()
    ..status = status.toProtoStatus()
    ..emailVerified = emailVerified
    ..phoneVerified = phoneVerified
    ..mfaEnabled = mfaEnabled
    ..hasPassword = hasPassword
    ..also((u) {
      if (phone != null) u.phone = phone!;
      if (avatarUrl != null) u.avatarUrl = avatarUrl!;
      if (locale != null) u.locale = locale!;
      if (timezone != null) u.timezone = timezone!;
    });
}

/// Helper extension for fluent building.
extension _Also<T> on T {
  T also(void Function(T) block) {
    block(this);
    return this;
  }
}
