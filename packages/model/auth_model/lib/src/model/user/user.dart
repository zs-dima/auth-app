import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User status enum matching proto UserStatus.
enum UserStatus {
  unspecified,
  active,
  pending,
  suspended,
  deleted,
}

@freezed
sealed class User with _$User implements IUserInfo, Comparable<User> {
  static const type$ = '2204CA60-2D98-4BF7-8140-9BF746F4CFE1';

  static const empty = User(
    id: Uuid.NAMESPACE_NIL,
    name: '',
    email: '',
    role: .user,
    status: .active,
  );

  const factory User({
    required UserId id,
    required String name,
    required String email,
    required UserRole role,
    required UserStatus status,
    String? phone,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    @Default(false) bool mfaEnabled,
    @Default(false) bool hasPassword,
    String? avatarUrl,
    String? locale,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Whether user is deleted (convenience getter for status).
  bool get deleted => status == .deleted;

  @override
  int compareTo(User other) => name.toLowerCase().compareTo(other.name.toLowerCase());

  // PII redact-at-source (refresh_token.md §13): reachable from logs/state-observer/Sentry.
  // Freezed skips generating toString when the class declares one.
  @override
  String toString() =>
      'User(id: $id, name: ***, email: ***, role: $role, status: $status, phone: ***, '
      'emailVerified: $emailVerified, phoneVerified: $phoneVerified, mfaEnabled: $mfaEnabled, '
      'hasPassword: $hasPassword, avatarUrl: $avatarUrl, locale: $locale, timezone: $timezone, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';
}
