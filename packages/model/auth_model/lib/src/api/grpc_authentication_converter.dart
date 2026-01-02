import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_info.dart';
import 'package:grpc_model/grpc_model.dart';

extension AppUserRoleX on UserRole {
  rpc.UserRole toRole() => rpc.UserRole.valueOf(index)!;
}

extension UserRoleX on rpc.UserRole {
  UserRole toRole() => .values[value];
}

extension AuthInfoX on rpc.AuthInfo {
  IUserInfo toUserInfo(String email) => UserInfo(
    id: userId.toId(),
    name: userName,
    email: email,
    role: userRole.toRole(),
  );
}

extension UserInfoX on rpc.UserInfo {
  IUserInfo toUserInfo() => UserInfo(
    id: id.toId(),
    name: name,
    email: email,
    role: role.toRole(),
  );
}

extension UserX on rpc.User {
  User toUser() => .new(
    id: id.toId(),
    name: name,
    email: email,
    role: role.toRole(),
    deleted: deleted,
  );
}

extension AppUserX on User {
  rpc.User toUser() => rpc.User()
    ..id = id.toUUID()
    ..name = name
    ..email = email
    ..role = role.toRole()
    ..deleted = deleted;
}
