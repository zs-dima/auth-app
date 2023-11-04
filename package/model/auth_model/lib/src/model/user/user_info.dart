import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info.freezed.dart';
part 'user_info.g.dart';

@freezed
class UserInfo with _$UserInfo implements IUserInfo, Comparable<UserInfo> {
  static const type = '987FCBC3-C8EF-4AE6-8DBD-B9049DF84B4C';

  const UserInfo._();

  const factory UserInfo({
    required UserId id,
    required String name,
    required String email,
    required UserRole role,
    required String? blurhash,
  }) = _UserInfo;

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  @override
  int compareTo(UserInfo other) => name.toLowerCase().compareTo(other.name.toLowerCase());
}
