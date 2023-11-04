import 'dart:async';

import 'package:auth_app/app/settings/repository/settings_repository.dart';
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
  Future<AccessCredentials> refreshTokens(RefreshToken refreshToken);
  Future<void> validateCredentials(AuthenticatedUser credentials);

  Future<void> signIn(ISignInData signInData, IDeviceInfo device);
  Future<void> signOut();

  Future<void> updateUserInfo(IUserInfo user);

  Future<bool> resetPassword(String email);
  Future<bool> setPassword(UserId userId, String email, String password);

  Future<void> terminate();
}

class AuthRepository implements IAuthRepository {
  @override
  IAuthenticationHandler authHandler;

  final ISettingsRepository _settings;

  final IAuthApi _api;

  StreamSubscription? _authSubscription;
  StreamSubscription? _userChangesSubscription;

  final _userController = StreamController<AuthUser>.broadcast();

  AuthUser _user = const AuthUser.unauthenticated();

  @override
  Stream<AuthUser> get userChanges => _userController.stream;

  @override
  AuthUser get user => _user;
  AuthRepository({
    required final IAuthApi apiClient,
    required this.authHandler,
    required final ISettingsRepository settings,
  })  : _api = apiClient,
        _settings = settings {
    _userChangesSubscription = userChanges //
        .whereType<AuthenticatedUser>()
        .listen((u) => authHandler.handleAuthenticated());

    _authSubscription = authHandler //
        .where((i) => i == AuthenticationState.unauthenticated)
        .listen((_) => signOut());
  }

  @override
  Future<AccessCredentials?> getAccessCredentials() {
    switch (_user) {
      case final AuthenticatedUser authUser:
        final AuthenticatedUser(:AccessCredentials? credentials) = authUser;
        return Future.value(credentials);

      default:
        // We don't use credentials for sign in
        return Future.value(null);
    }
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
  Future<AccessCredentials> refreshTokens(RefreshToken refreshToken) async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        final AuthenticatedUser(:IUserInfo userInfo) = authUser;
        final refresh = await _api.refreshTokens(refreshToken);

        await _settings.setUser(userInfo);
        await _settings.setCredentials(refresh);

        _userController.add(
          _user = AuthenticatedUser(
            credentials: refresh,
            userInfo: userInfo,
          ),
        );
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
  Future<void> signIn(ISignInData signInData, IDeviceInfo device) => Future<void>.sync(
        () async => _userController.add(
          _user = await _api.signIn(signInData, device),
        ),
      );

  @override
  Future<void> signOut() => Future<void>.sync(
        () async {
          final result = await _api.signOut();
          if (result) {
            _userController.add(
              _user = const AuthUser.unauthenticated(),
            );
          }
        },
      );

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
        return;
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
