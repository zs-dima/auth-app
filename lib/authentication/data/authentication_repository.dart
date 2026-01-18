import 'dart:async';

import 'package:auth_app/_core/api/http/mutex.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/_core/tool/device_info.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:rxdart/rxdart.dart';

/// Authentication exception with status information.
class AuthenticationException implements Exception {
  const AuthenticationException(this.result);

  final AuthResult result;

  String get message => _getMessage();

  @override
  String toString() => 'AuthenticationException: $message';

  String _getMessage() => switch (result) {
    AuthResultFailed(message: final msg) => msg ?? 'Authentication failed',
    AuthResultLocked(message: final msg, :final lockoutInfo) =>
      msg ?? 'Account locked. Try again in ${lockoutInfo.retryAfterSeconds} seconds.',
    AuthResultSuspended(message: final msg) => msg ?? 'Account suspended',
    AuthResultPending(message: final msg) => msg ?? 'Account pending verification',
    AuthResultMfaRequired() => 'MFA verification required',
    _ => 'Authentication failed',
  };
}

abstract interface class IAuthenticationRepository {
  Stream<AuthUser> get userChanges;
  AuthUser get user;
  Future<UserId> getUserId();

  Future<AuthUser> restore();
  Future<AccessCredentials?> getAccessCredentials();

  /// Authenticate with credentials.
  /// Returns [AuthUser] on success.
  /// Throws [AuthenticationException] with [AuthResultMfaRequired] if MFA is needed.
  Future<AuthUser> signIn(ISignInData signInData);

  /// Complete MFA verification.
  Future<AuthUser> verifyMfa({
    required String challengeToken,
    required MfaMethod method,
    required String code,
  });

  /// Register a new account.
  /// Returns [AuthUser] on success (auto-login) or throws [AuthenticationException].
  Future<AuthUser> signUp(SignUpData data);

  Future<void> signOut();

  Future<bool> recoveryStart(String identifier, {IdentifierType identifierType});
  Future<bool> recoveryConfirm({required String token, required String newPassword});
  Future<bool> changePassword({required String currentPassword, required String newPassword});

  /// Confirm email/phone verification with token.
  /// Returns [AuthUser] on success for seamless auto-login.
  Future<AuthUser> confirmVerification({required String token, required VerificationType type});

  /// Request verification email/SMS resend.
  Future<bool> requestVerification(VerificationType type);

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
    final result = await _api.authenticate(signInData, deviceInfo);
    return _handleAuthResult(result);
  }

  @override
  Future<AuthUser> verifyMfa({
    required String challengeToken,
    required MfaMethod method,
    required String code,
  }) async {
    final deviceInfo = await DeviceInfo.instance(metadata.appVersion, _settings.installationId);
    final result = await _api.verifyMfa(
      challengeToken: challengeToken,
      method: method,
      code: code,
      deviceInfo: deviceInfo,
    );
    return _handleAuthResult(result);
  }

  @override
  Future<AuthUser> signUp(SignUpData data) async {
    final deviceInfo = await DeviceInfo.instance(metadata.appVersion, _settings.installationId);
    final result = await _api.signUp(data, deviceInfo);
    return _handleAuthResult(result);
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
  Future<bool> recoveryStart(String identifier, {IdentifierType identifierType = .email}) =>
      _api.recoveryStart(identifier: identifier, identifierType: identifierType);

  @override
  Future<bool> recoveryConfirm({required String token, required String newPassword}) =>
      _api.recoveryConfirm(token: token, newPassword: newPassword);

  @override
  Future<bool> changePassword({required String currentPassword, required String newPassword}) =>
      _api.changePassword(currentPassword: currentPassword, newPassword: newPassword);

  @override
  Future<AuthUser> confirmVerification({required String token, required VerificationType type}) async {
    final deviceInfo = await DeviceInfo.instance(metadata.appVersion, _settings.installationId);
    final result = await _api.confirmVerification(token: token, type: type, deviceInfo: deviceInfo);
    return _handleAuthResult(result);
  }

  @override
  Future<bool> requestVerification(VerificationType type) => _api.requestVerification(type);

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

  /// Handles authentication result, returning user on success or throwing on failure/MFA.
  AuthUser _handleAuthResult(AuthResult result) {
    switch (result) {
      case AuthResultSuccess(:final userId, :final credentials):
        final authUser = AuthUser.authenticated(credentials: credentials, userId: userId);
        _userController.add(_user = authUser);
        _settings.setUserId(userId).ignore();
        _settings.setCredentials(credentials).ignore();
        return authUser;

      case AuthResultMfaRequired():
      case AuthResultFailed():
      case AuthResultLocked():
      case AuthResultSuspended():
      case AuthResultPending():
        throw AuthenticationException(result);
    }
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
