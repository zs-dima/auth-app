import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User implements IUserInfo, Comparable<User> {
  static const String type = '2204CA60-2D98-4BF7-8140-9BF746F4CFE1';

  const User._();

  const factory User({
    required UserId id,
    required String name,
    required String email,
    required UserRole role,
    String? blurhash,
    required bool deleted,
  }) = _User;

  static const User empty = User(
    id: Uuid.NAMESPACE_NIL,
    name: '',
    email: '',
    role: UserRole.user,
    deleted: false,
  );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  int compareTo(User other) => name.toLowerCase().compareTo(other.name.toLowerCase());
}
