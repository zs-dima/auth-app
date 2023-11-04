import 'package:auth_model/auth_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
abstract class AuthUser {
  bool get isAuthenticated;
  bool get isNotAuthenticated;

  @literal
  const factory AuthUser.unauthenticated() = UnauthenticatedUser;

  const factory AuthUser.authenticated({
    required final AccessCredentials credentials,
    required final IUserInfo userInfo,
  }) = AuthenticatedUser;

  T when<T extends Object?>({
    required final T Function(AuthenticatedUser user) authenticated,
    required final T Function() unauthenticated,
  });
}

@immutable
class UnauthenticatedUser implements AuthUser {
  @override
  bool get isAuthenticated => false;

  @override
  bool get isNotAuthenticated => true;

  @override
  int get hashCode => 0;
  @literal
  const UnauthenticatedUser();

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
}

@immutable
class AuthenticatedUser implements AuthUser {
  final AccessCredentials? credentials;
  final IUserInfo userInfo;

  @override
  bool get isAuthenticated => !isNotAuthenticated;

  @override
  bool get isNotAuthenticated => credentials?.accessToken.hasExpired ?? true;

  @override
  int get hashCode => userInfo.hashCode;
  const AuthenticatedUser({
    required this.credentials,
    required this.userInfo,
  });

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
}
