import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
abstract class AuthUser {
  @literal
  const factory AuthUser.unauthenticated() = UnauthenticatedUser;

  const factory AuthUser.authenticated({
    required final AccessCredentials credentials,
    required final IUserInfo userInfo,
  }) = AuthenticatedUser;

  bool get isAuthenticated;
  bool get isNotAuthenticated;

  T when<T extends Object?>({
    required final T Function(AuthenticatedUser user) authenticated,
    required final T Function() unauthenticated,
  });
}

@immutable
class UnauthenticatedUser implements AuthUser {
  @literal
  const UnauthenticatedUser();

  @override
  bool get isAuthenticated => false;

  @override
  bool get isNotAuthenticated => true;

  @override
  T when<T extends Object?>({
    required final T Function(AuthenticatedUser user) authenticated,
    required final T Function() unauthenticated,
  }) =>
      unauthenticated();

  @override
  String toString() => 'User is not authenticated';

  @override
  bool operator ==(final Object other) => other is UnauthenticatedUser;

  @override
  int get hashCode => 0;
}

@immutable
class AuthenticatedUser implements AuthUser {
  const AuthenticatedUser({
    required this.credentials,
    required this.userInfo,
  });

  @override
  bool get isAuthenticated => !isNotAuthenticated;

  @override
  bool get isNotAuthenticated => credentials?.accessToken.hasExpired ?? true;

  final AccessCredentials? credentials;
  final IUserInfo userInfo;

  @override
  T when<T extends Object?>({
    required final T Function(AuthenticatedUser user) authenticated,
    required final T Function() unauthenticated,
  }) =>
      authenticated(this);

  @override
  String toString() => 'AuthenticatedUser('
      'credentials: $credentials, '
      'user: $userInfo)';

  @override
  bool operator ==(final Object other) => other is AuthenticatedUser && userInfo == other.userInfo;

  @override
  int get hashCode => userInfo.hashCode;
}
