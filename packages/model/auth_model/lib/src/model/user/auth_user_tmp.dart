import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

typedef AuthenticatedCallback<T extends Object?> = T Function(AuthenticatedUser user);
typedef UnauthenticatedCallback<T extends Object?> = T Function();

/// {@template user}
/// The user entry model.
/// {@endtemplate}
@immutable
sealed class AuthUser with _UserPatternMatching, _UserShortcuts {
  /// The user's id.
  abstract final UserId? id;

  /// {@macro user}
  const AuthUser._();

  /// {@macro user}
  @literal
  const factory AuthUser.unauthenticated() = UnauthenticatedUser;

  /// {@macro user}
  const factory AuthUser.authenticated({
    required UserId id,
  }) = AuthenticatedUser;

  /// {@macro user}
  factory AuthUser.fromJson(Map<String, Object?> json) => switch (json['id']) {
        final UserId id => AuthenticatedUser(id: id),
        _ => const UnauthenticatedUser(),
      };

  Map<String, Object?> toJson();
}

/// {@macro user}
///
/// Unauthenticated user.
class UnauthenticatedUser extends AuthUser {
  @override
  UserId? get id => null;

  @override
  bool get isAuthenticated => false;

  @override
  int get hashCode => -1;

  /// {@macro user}
  const UnauthenticatedUser() : super._();

  /// {@macro user}
  // ignore: avoid_unused_constructor_parameters
  factory UnauthenticatedUser.fromJson(Map<String, Object?> json) => const UnauthenticatedUser();

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'user',
        'status': 'unauthenticated',
        'authenticated': false,
        'id': null,
      };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) =>
      unauthenticated(this);

  @override
  AuthUser copyWith({
    UserId? id,
  }) =>
      id != null ? AuthenticatedUser(id: id) : const UnauthenticatedUser();

  @override
  bool operator ==(Object other) => identical(this, other) || other is UnauthenticatedUser && id == other.id;

  @override
  String toString() => 'UnauthenticatedUser{}';
}

/// {@macro user}
final class AuthenticatedUser extends AuthUser {
  @override
  @nonVirtual
  final UserId id;

  @override
  @nonVirtual
  bool get isAuthenticated => true;

  @override
  int get hashCode => id.hashCode;

  /// {@macro user}
  const AuthenticatedUser({
    required this.id,
  }) : super._();

  /// {@macro user}
  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    if (json.isEmpty) throw FormatException('Json is empty', json);
    if (json
        case <String, Object?>{
          'id': final UserId id,
        }) return AuthenticatedUser(id: id);
    throw FormatException('Invalid json format', json);
  }

  @override
  Map<String, Object?> toJson() => <String, Object?>{
        'type': 'user',
        'status': 'authenticated',
        'authenticated': true,
        'id': id,
      };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) =>
      authenticated(this);

  @override
  AuthenticatedUser copyWith({
    UserId? id,
  }) =>
      AuthenticatedUser(
        id: id ?? this.id,
      );

  @override
  bool operator ==(Object other) => identical(this, other) || other is AuthenticatedUser && id == other.id;

  @override
  String toString() => 'AuthenticatedUser{id: $id}';
}

mixin _UserPatternMatching {
  /// Pattern matching on [User] subclasses.
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  });

  /// Pattern matching on [User] subclasses.
  T maybeMap<T>({
    required T Function() orElse,
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) =>
      map<T>(
        unauthenticated: (user) => unauthenticated?.call(user) ?? orElse(),
        authenticated: (user) => authenticated?.call(user) ?? orElse(),
      );

  /// Pattern matching on [User] subclasses.
  T? mapOrNull<T>({
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) =>
      map<T?>(
        unauthenticated: (user) => unauthenticated?.call(user),
        authenticated: (user) => authenticated?.call(user),
      );
}

mixin _UserShortcuts on _UserPatternMatching {
  /// User is authenticated.
  bool get isAuthenticated;

  /// User is not authenticated.
  bool get isNotAuthenticated => !isAuthenticated;

  /// Copy with new values.
  AuthUser copyWith({
    UserId? id,
  });
}
