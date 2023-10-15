import 'dart:async';

import 'package:auth_app/app/settings/repository/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
import 'package:rxdart/rxdart.dart';

abstract interface class IAuthRepository {
  Stream<AuthUser> get userChanges;
  AuthUser get user;
  FutureOr<UserId?> getUserId();

  IAuthenticationHandler get authHandler;

  FutureOr<AccessCredentials?> getAccessCredentials();
  FutureOr<AccessCredentials> refreshTokens(RefreshToken refreshToken);
  FutureOr<void> validateCredentials(AuthenticatedUser credentials);

  Future<void> signIn(ISignInData signInData, IDeviceInfo device);
  Future<void> signOut();

  FutureOr<void> updateUserInfo(IUserInfo user);

  Future<bool> resetPassword(String email);
  Future<bool> setPassword(UserId userId, String email, String password);

  FutureOr<void> terminate();
}

class AuthRepository implements IAuthRepository {
  AuthRepository({
    required final IAuthApi apiClient,
    required this.authHandler,
    required final ISettingsRepository settings,
  })  : _api = apiClient,
        _settings = settings {
    _userChangesSubscription = userChanges //
        .whereType<AuthenticatedUser>()
        .listen((user) => authHandler.handleAuthenticated());

    _authSubscription = authHandler //
        .where((i) => i == AuthenticationState.unauthenticated)
        .listen((_) => signOut());
  }

  @override
  IAuthenticationHandler authHandler;

  final ISettingsRepository _settings;

  @override
  FutureOr<AccessCredentials?> getAccessCredentials() {
    switch (_user) {
      case final AuthenticatedUser user:
        final AuthenticatedUser(:AccessCredentials? credentials) = user;
        return credentials;
      default:
        // We don't use credentials for sign in
        return null;
    }
  }

  @override
  FutureOr<void> validateCredentials(AuthenticatedUser user) async {
    var result = false;
    _user = user;
    try {
      result = await _api.validateCredentials();
    } on GrpcError catch (e, s) {
      if (e.code != StatusCode.unauthenticated) Error.throwWithStackTrace(e, s);
    } finally {
      if (result) {
        _userController.add(user);
      } else {
        _user = const AuthUser.unauthenticated();
        _settings
          ..setUser(null)
          ..setCredentials(null);
      }
    }
  }

  @override
  FutureOr<AccessCredentials> refreshTokens(RefreshToken refreshToken) async {
    switch (_user) {
      case final AuthenticatedUser user:
        final AuthenticatedUser(:IUserInfo userInfo) = user;
        final refresh = await _api.refreshTokens(refreshToken);

        _settings
          ..setUser(userInfo)
          ..setCredentials(refresh);

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

  final IAuthApi _api;

  StreamSubscription? _authSubscription;
  StreamSubscription? _userChangesSubscription;

  final StreamController<AuthUser> _userController = StreamController<AuthUser>.broadcast();

  @override
  Stream<AuthUser> get userChanges => _userController.stream;

  @override
  AuthUser get user => _user;
  AuthUser _user = const AuthUser.unauthenticated();

  @override
  FutureOr<UserId?> getUserId() async {
    switch (_user) {
      case final AuthenticatedUser user:
        final AuthenticatedUser(:IUserInfo userInfo) = user;
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
  FutureOr<void> updateUserInfo(IUserInfo userInfo) {
    switch (_user) {
      case final AuthenticatedUser user:
        final AuthenticatedUser(:AccessCredentials? credentials) = user;
        _userController.add(
          _user = AuthenticatedUser(userInfo: userInfo, credentials: credentials),
        );
        _settings.setUser(userInfo);
      default:
        return null;
    }
  }

  @override
  Future<bool> resetPassword(String email) => _api.resetPassword(email);

  @override
  Future<bool> setPassword(UserId userId, String email, String password) => _api.setPassword(userId, email, password);

  @override
  FutureOr<void> terminate() {
    _authSubscription?.cancel();
    _userChangesSubscription?.cancel();
    _userController.close();
  }
}
