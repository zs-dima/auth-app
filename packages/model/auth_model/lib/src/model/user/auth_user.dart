import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

typedef AuthenticatedCallback<T> = T Function(AuthenticatedUser user);
typedef UnauthenticatedCallback<T> = T Function();

/// {@template user}
/// The user entry model.
/// {@endtemplate}
@immutable
sealed class AuthUser with _AuthUserPatternMatching, _AuthUserShortcuts {
  /// {@macro user}
  const AuthUser._();

  /// {@macro user}
  @literal
  const factory AuthUser.unauthenticated() = UnauthenticatedUser;

  /// {@macro user}
  const factory AuthUser.authenticated({required final AccessCredentials credentials, required final UserId userId}) =
      AuthenticatedUser;

  /// {@macro user}
  factory AuthUser.fromJson(Map<String, Object?> json) => switch (json['userId']) {
    final UserId userId => AuthUser.authenticated(
      credentials: AccessCredentials.fromJson(json['credentials']! as Map<String, dynamic>),
      userId: userId,
    ),
    _ => const UnauthenticatedUser(),
  };

  Map<String, Object?> toJson();
}

/// {@macro user}
///
/// Unauthenticated user.
class UnauthenticatedUser extends AuthUser {
  /// {@macro user}
  const UnauthenticatedUser() : super._();

  /// {@macro user}
  // ignore: avoid_unused_constructor_parameters
  factory UnauthenticatedUser.fromJson(Map<String, Object?> json) => const UnauthenticatedUser();

  @override
  bool get isAuthenticated => false;

  @override
  int get hashCode => -1;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'user',
    'status': 'unauthenticated',
    'authenticated': false,
    'userId': null,
  };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) => unauthenticated(this);

  @override
  AuthUser copyWith({AccessCredentials? credentials, UserId? userId}) =>
      userId == null ? const UnauthenticatedUser() : AuthUser.authenticated(userId: userId, credentials: credentials!);

  @override
  bool operator ==(Object other) => identical(this, other) || other is UnauthenticatedUser;

  @override
  String toString() => 'UnauthenticatedUser{}';
}

/// {@macro user}
final class AuthenticatedUser extends AuthUser {
  /// {@macro user}
  const AuthenticatedUser({required this.credentials, required this.userId}) : super._();

  /// {@macro user}
  factory AuthenticatedUser.fromJson(Map<String, Object?> json) {
    if (json.isEmpty) throw FormatException('Json is empty', json);
    if (json case <String, Object?>{'userId': final UserId userId})
      return AuthenticatedUser(
        credentials: AccessCredentials.fromJson(json['credentials']! as Map<String, dynamic>),
        userId: userId,
      );
    throw FormatException('Invalid json format', json);
  }

  /// The user's credentials.
  @nonVirtual
  final AccessCredentials? credentials;

  /// The user's details.
  @nonVirtual
  final UserId userId;

  @override
  @nonVirtual
  bool get isAuthenticated => true;

  @override
  int get hashCode => userId.hashCode ^ credentials.hashCode;

  @override
  Map<String, Object?> toJson() => <String, Object?>{
    'type': 'user',
    'status': 'authenticated',
    'authenticated': true,
    'userId': userId,
    'credentials': credentials?.toJson(),
  };

  @override
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  }) => authenticated(this);

  @override
  AuthenticatedUser copyWith({AccessCredentials? credentials, UserId? userId}) =>
      AuthenticatedUser(credentials: credentials ?? this.credentials, userId: userId ?? this.userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthenticatedUser && userId == other.userId && credentials == other.credentials);

  @override
  String toString() =>
      'AuthenticatedUser{'
      'credentials: $credentials, '
      'user: $userId'
      '}';
}

mixin _AuthUserPatternMatching {
  /// Pattern matching on [AuthUser] subclasses.
  T map<T>({
    required T Function(UnauthenticatedUser user) unauthenticated,
    required T Function(AuthenticatedUser user) authenticated,
  });

  /// Pattern matching on [AuthUser] subclasses.
  T maybeMap<T>({
    required T Function() orElse,
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) => map<T>(
    unauthenticated: (user) => unauthenticated?.call(user) ?? orElse(),
    authenticated: (user) => authenticated?.call(user) ?? orElse(),
  );

  /// Pattern matching on [AuthUser] subclasses.
  T? mapOrNull<T>({
    T Function(UnauthenticatedUser user)? unauthenticated,
    T Function(AuthenticatedUser user)? authenticated,
  }) => map<T?>(
    unauthenticated: (user) => unauthenticated?.call(user),
    authenticated: (user) => authenticated?.call(user),
  );
}

mixin _AuthUserShortcuts on _AuthUserPatternMatching {
  /// AuthUser is authenticated.
  bool get isAuthenticated;

  /// AuthUser is not authenticated.
  bool get isNotAuthenticated => !isAuthenticated;

  /// Copy with new values.
  AuthUser copyWith({AccessCredentials? credentials, UserId? userId});
}
