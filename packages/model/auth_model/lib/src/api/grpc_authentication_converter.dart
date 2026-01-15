import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_info.dart';
import 'package:grpc_model/grpc_model.dart';

/// Maps app UserRole to proto UserRole.
/// Proto enum: UNSPECIFIED=0, ADMIN=1, USER=2, GUEST=3
/// App enum: admin=0, user=1, guest=2
extension AppUserRoleX on UserRole {
  rpc.UserRole toRole() => switch (this) {
    .admin => rpc.UserRole.USER_ROLE_ADMIN,
    .user => rpc.UserRole.USER_ROLE_USER,
    .guest => rpc.UserRole.USER_ROLE_GUEST,
  };
}

/// Maps proto UserRole to app UserRole.
extension UserRoleX on rpc.UserRole {
  UserRole toRole() => switch (this) {
    rpc.UserRole.USER_ROLE_ADMIN => .admin,
    rpc.UserRole.USER_ROLE_USER => .user,
    rpc.UserRole.USER_ROLE_GUEST => .guest,
    _ => .guest, // Default to guest for UNSPECIFIED
  };
}

/// Converts proto AuthInfo to IUserInfo.
extension AuthInfoX on rpc.AuthInfo {
  IUserInfo toUserInfo() => UserInfo(
    id: userId.toId(),
    name: displayName,
    email: email,
    role: userRole.toRole(),
  );
}

/// Converts proto UserInfo to app IUserInfo.
extension UserInfoX on rpc.UserInfo {
  IUserInfo toUserInfo() => UserInfo(
    id: id.toId(),
    name: name,
    email: email,
    role: role.toRole(),
  );
}

/// Converts proto User to app User.
extension UserX on rpc.User {
  User toUser() => .new(
    id: id.toId(),
    name: name,
    email: email,
    role: role.toRole(),
    deleted: deleted,
  );
}

/// Converts app User to proto User.
extension AppUserX on User {
  rpc.User toUser() => rpc.User()
    ..id = id.toUUID()
    ..name = name
    ..email = email
    ..role = role.toRole()
    ..deleted = deleted;
}
