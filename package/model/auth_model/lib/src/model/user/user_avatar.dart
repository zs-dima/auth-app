import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_converter/json_converter.dart';

part 'user_avatar.freezed.dart';

@freezed
class UserAvatar with _$UserAvatar implements Comparable<UserAvatar> {
  static const String type = '8D15A784-AACD-47AA-9D90-0133C4D3801C';

  const UserAvatar._();

  const factory UserAvatar({
    required UserId userId,
    @ByteArrayNullJsonConverter() Uint8List? avatar,
    required bool loaded,
  }) = _UserAvatar;

  static const UserAvatar empty = UserAvatar(userId: UserIdX.empty, avatar: null, loaded: false);

  @override
  int compareTo(UserAvatar other) => userId.compareTo(other.userId);
}
