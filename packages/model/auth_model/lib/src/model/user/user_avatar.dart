import 'dart:typed_data';

import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_converter/json_converter.dart';

part 'user_avatar.freezed.dart';

@freezed
sealed class UserAvatar with _$UserAvatar implements Comparable<UserAvatar> {
  static const type$ = '8D15A784-AACD-47AA-9D90-0133C4D3801C';

  static const empty = UserAvatar(userId: UserIdX.empty, avatar: null, loaded: false);

  const factory UserAvatar({
    required UserId userId,
    @ByteArrayNullJsonConverter() Uint8List? avatar,
    required bool loaded,
  }) = _UserAvatar;

  const UserAvatar._();

  @override
  int compareTo(UserAvatar other) => userId.compareTo(other.userId);
}
