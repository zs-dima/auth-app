import 'dart:async';

import 'package:auth_app/_core/api/http/mutex.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/_core/tool/device_info.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:rxdart/rxdart.dart';

abstract interface class IAuthenticationRepository {
  Stream<AuthUser> get userChanges;
  AuthUser get user;
  Future<UserId> getUserId();

  Future<AuthUser> restore();
  Future<AccessCredentials?> getAccessCredentials();
  // Future<AccessCredentials?> refreshTokens();

  Future<AuthUser> signIn(ISignInData signInData);
  Future<void> signOut();

  Future<bool> resetPassword(String email);
  Future<bool> setPassword(UserId userId, String email, String password);

  Future<void> terminate();
}

class AuthenticationRepository implements IAuthenticationRepository {
  /// Prevents concurrent refresh attempts
  static final Mutex _refreshingMutex = Mutex();

  AuthenticationRepository({
    required final IAuthenticationApi api,
    required IAuthenticationHandler authHandler,
    required final ISettingsRepository settings,
    required this.metadata,
  }) : _api = api,
       _settings = settings {
    _userChangesSubscription =
        userChanges //
            .whereType<AuthenticatedUser>()
            .listen((u) => authHandler.handleAuthenticated(), cancelOnError: false);

    _authSubscription =
        authHandler //
            .where((i) => i == .unauthenticated)
            .listen((_) => signOut(), cancelOnError: false);
  }
  final IAuthenticationApi _api;

  final ISettingsRepository _settings;

  StreamSubscription? _authSubscription;

  StreamSubscription? _userChangesSubscription;

  final _userController = StreamController<AuthUser>.broadcast();

  final AppMetadata metadata;
  @override
  Stream<AuthUser> get userChanges => _userController.stream;
  @override
  AuthUser get user => _user;

  AuthUser _user = const AuthUser.unauthenticated();

  @override
  Future<AccessCredentials?> getAccessCredentials() async => _refreshingMutex.synchronize(_refreshTokens);

  @override
  Future<UserId> getUserId() async => switch (_user) {
    AuthenticatedUser(:final userId) => userId,
    _ => UserIdX.empty,
  };

  @override
  Future<AuthUser> signIn(ISignInData signInData) async {
    final deviceInfo = await DeviceInfo.instance(metadata.appVersion, _settings.installationId);

    final authUser = await _api.signIn(signInData, deviceInfo);

    _userController.add(_user = authUser);

    _settings.setUserId(authUser.userId).ignore();
    _settings.setCredentials(authUser.credentials).ignore();

    return _user;
  }

  @override
  Future<void> signOut() => Future<void>.delayed(.zero, () async {
    try {
      if (_user case final AuthenticatedUser authenticatedUser) {
        final token = authenticatedUser.credentials?.accessToken.token;
        if (!token.isNullOrEmpty) _api.signOut(token!).ignore();
      }
    } finally {
      _userController.add(_user = const AuthUser.unauthenticated());
      _settings
        ..setUserId(UserIdX.empty).ignore()
        ..setCredentials(null).ignore();
    }
  });

  @override
  Future<bool> resetPassword(String email) => _api.resetPassword(email);

  @override
  Future<bool> setPassword(UserId userId, String email, String password) => _api.setPassword(userId, email, password);

  @override
  Future<AuthUser> restore() async {
    final userId = _settings.userId;
    final credentials = await _settings.getCredentials();

    if (userId == UserIdX.empty || credentials == null) return _user;

    _user = AuthUser.authenticated(userId: userId, credentials: credentials);
    AccessCredentials? cr;
    try {
      cr = await _refreshingMutex.synchronize(_refreshTokens);
    } finally {
      if (cr != null) _userController.add(_user);
    }
    return _user;
  }

  @override
  Future<void> terminate() async {
    await _authSubscription?.cancel();
    await _userChangesSubscription?.cancel();
    await _userController.close();
  }

  // @override
  Future<AccessCredentials?> _refreshTokens() async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        try {
          final AuthenticatedUser(:AccessCredentials? credentials, :UserId userId) = authUser;
          if (credentials == null || credentials.accessToken.token.isNullOrSpace) {
            throw Exception('Credentials are missing');
          }

          if (!credentials.accessToken.expiresSoon) return credentials;

          // print('>>> accessToken: ${DateFormat().format(credentials.accessToken.expiry)}');
          // print('>>> accessToken: ${credentials.accessToken.token}');
          // print('>>> refreshToken: ${credentials.refreshToken}');

          final refresh = await _api.refreshTokens(
            credentials.accessToken.token,
            credentials.refreshToken,
          );

          if (refresh == null) {
            _settings
              ..setUserId(UserIdX.empty).ignore()
              ..setCredentials(null).ignore();

            _userController.add(_user = const AuthUser.unauthenticated());
            return null;
          }

          _settings
            ..setUserId(userId).ignore()
            ..setCredentials(refresh).ignore();

          _userController.add(_user = AuthUser.authenticated(credentials: refresh, userId: userId));

          return refresh;
        } on Object catch (error, stackTrace) {
          _settings
            ..setUserId(UserIdX.empty).ignore()
            ..setCredentials(null).ignore();

          _userController.add(_user = const AuthUser.unauthenticated());

          // print('>>> Failed to refresh tokens: $error');

          Error.throwWithStackTrace('Failed to refresh tokens "$error"', stackTrace);
        }

      default:
        return null;
      // throw Exception('User is not authenticated');
    }
  }
}
