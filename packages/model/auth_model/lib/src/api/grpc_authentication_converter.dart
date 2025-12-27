import 'dart:typed_data';

import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_avatar.dart';
import 'package:auth_model/src/model/user/user_info.dart';
import 'package:core_model/core_model.dart';
import 'package:grpc_model/grpc_model.dart';

extension AppUserRoleX on UserRole {
  rpc.UserRole toRole() => rpc.UserRole.valueOf(index)!;
}

extension UserRoleX on rpc.UserRole {
  UserRole toRole() => UserRole.values[value];
}

extension OsEnumX on OsEnum {
  rpc.OS toOs() => rpc.OS.valueOf(index)!;
}

extension AuthInfoX on rpc.AuthInfo {
  IUserInfo toUserInfo(String email) => UserInfo(
    id: userId.toId(),
    name: userName,
    email: email,
    role: userRole.toRole(),
    blurhash: hasBlurhash() ? blurhash : null,
  );
}

extension UserInfoX on rpc.UserInfo {
  IUserInfo toUserInfo() => UserInfo(
    id: id.toId(),
    name: name,
    email: email,
    role: role.toRole(),
    blurhash: hasBlurhash() ? blurhash : null,
  );
}

extension UserX on rpc.User {
  User toUser() => User(
    id: id.toId(),
    name: name,
    email: email,
    role: role.toRole(),
    deleted: deleted,
    blurhash: hasBlurhash() ? blurhash : null,
  );
}

extension AppUserX on User {
  rpc.User toUser() {
    final user = rpc.User()
      ..id = id.toUUID()
      ..name = name
      ..email = email
      ..role = role.toRole()
      ..deleted = deleted;

    if (blurhash != null) user.blurhash = blurhash!;

    return user;
  }
}

extension UserAvatarX on rpc.UserAvatar {
  UserAvatar toUserAvatar() => UserAvatar(
    userId: userId.toId(),
    avatar: hasAvatar() ? Uint8List.fromList(avatar) : null,
    loaded: true,
  );
}
