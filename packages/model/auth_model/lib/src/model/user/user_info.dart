import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info.freezed.dart';
part 'user_info.g.dart';

@freezed
sealed class UserInfo with _$UserInfo implements IUserInfo, Comparable<UserInfo> {
  static const type$ = '987FCBC3-C8EF-4AE6-8DBD-B9049DF84B4C';

  const factory UserInfo({
    required UserId id,
    required String name,
    required String email,
    required UserRole role,
    required String? blurhash,
  }) = _UserInfo;

  const UserInfo._();

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  @override
  int compareTo(UserInfo other) => name.toLowerCase().compareTo(other.name.toLowerCase());
}
