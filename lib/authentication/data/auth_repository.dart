import 'dart:async';

import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
import 'package:rxdart/rxdart.dart';

abstract interface class IAuthRepository {
  Stream<AuthUser> get userChanges;
  AuthUser get user;
  IAuthenticationHandler get authHandler;

  Future<UserId?> getUserId();

  Future<AccessCredentials?> getAccessCredentials();
  Future<AccessCredentials> refreshTokens(String accessToken, RefreshToken refreshToken);
  Future<void> validateCredentials(AuthenticatedUser credentials);

  Future<void> signIn(ISignInData signInData, IDeviceInfo device);
  Future<void> signOut();

  Future<void> updateUserInfo(IUserInfo user);

  Future<bool> resetPassword(String email);
  Future<bool> setPassword(UserId userId, String email, String password);

  Future<void> terminate();
}

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required final IAuthenticationApi apiClient,
    required this.authHandler,
    required final ISettingsRepository settings,
  }) : _api = apiClient,
       _settings = settings {
    _userChangesSubscription =
        userChanges //
            .whereType<AuthenticatedUser>()
            .listen((u) => authHandler.handleAuthenticated());

    _authSubscription =
        authHandler //
            .where((i) => i == AuthenticationState.unauthenticated)
            .listen(
              (_) => signOut(),
            );
  }

  final ISettingsRepository _settings;

  final IAuthenticationApi _api;

  StreamSubscription? _authSubscription;
  StreamSubscription? _userChangesSubscription;

  final _userController = StreamController<AuthUser>.broadcast();

  @override
  IAuthenticationHandler authHandler;

  @override
  Stream<AuthUser> get userChanges => _userController.stream;

  AuthUser _user = const AuthUser.unauthenticated();
  @override
  AuthUser get user => _user;

  @override
  Future<AccessCredentials?> getAccessCredentials() async {
    if (_user case final AuthenticatedUser authUser) {
      return authUser.credentials;
    }
    return null;
  }

  @override
  Future<void> validateCredentials(AuthenticatedUser user) async {
    var result = false;
    _user = user;
    try {
      result = await _api.validateCredentials();
    } on GrpcError catch (error, s) {
      if (error.code != StatusCode.unauthenticated) Error.throwWithStackTrace(error, s);
    } finally {
      if (result) {
        _userController.add(user);
      } else {
        _user = const AuthUser.unauthenticated();
        _settings
          ..setUser(null).ignore()
          ..setCredentials(null).ignore();
      }
    }
  }

  @override
  Future<AccessCredentials> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        final AuthenticatedUser(:IUserInfo userInfo) = authUser;
        final refresh = await _api.refreshTokens(accessToken, refreshToken);

        await _settings.setUser(userInfo);
        await _settings.setCredentials(refresh);

        _userController.add(
          _user = AuthenticatedUser(
            credentials: refresh,
            userInfo: userInfo,
          ),
        );
        if (refresh == null) {
          throw Exception('Failed to refresh tokens');
        }
        return refresh;

      default:
        throw Exception('User is not authenticated');
    }
  }

  @override
  Future<UserId?> getUserId() async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        final AuthenticatedUser(:IUserInfo userInfo) = authUser;
        return userInfo.id;

      default:
        return null;
    }
  }

  @override
  Future<void> signIn(ISignInData signInData, IDeviceInfo device) async {
    final result = await _api.signIn(signInData, device);
    _user = result;
    _userController.add(_user);
  }

  @override
  Future<void> signOut() async {
    final token = _user is AuthenticatedUser ? ((_user as AuthenticatedUser).credentials?.accessToken.token ?? '') : '';

    return _api.signOut(token);
  }

  @override
  Future<void> updateUserInfo(IUserInfo userInfo) async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        final AuthenticatedUser(:AccessCredentials? credentials) = authUser;
        _userController.add(
          _user = AuthenticatedUser(userInfo: userInfo, credentials: credentials),
        );
        await _settings.setUser(userInfo);

      default:
    }
  }

  @override
  Future<bool> resetPassword(String email) => _api.resetPassword(email);

  @override
  Future<bool> setPassword(UserId userId, String email, String password) => _api.setPassword(userId, email, password);

  @override
  Future<void> terminate() async {
    await _authSubscription?.cancel();
    await _userChangesSubscription?.cancel();
    await _userController.close();
  }
}
