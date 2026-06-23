import 'dart:async';

import 'package:auth_app/_core/api/http/api_client.dart';
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

  /// Session-scoped cancellation: a single token whose lifetime matches the signed-in
  /// session. It is cancelled when the session ends (logout or a failed refresh), so any
  /// in-flight request bound to it is aborted; a fresh token is vended for the next session.
  CancelToken get sessionCancelToken;

  Future<UserId> getUserId();

  Future<AuthUser> restore();

  /// Returns the current credentials, proactively refreshing them if they are
  /// about to expire ([AccessToken.expiresSoon]). Single-flight: concurrent
  /// callers share one refresh.
  Future<AccessCredentials?> getAccessCredentials();

  /// Forces a token refresh after a request was rejected with `401`.
  ///
  /// Single-flight via the same mutex as [getAccessCredentials]: when many
  /// requests get `401` at once, only the first performs the network refresh;
  /// the rest see that the token already changed ([usedAccessToken] no longer
  /// matches the current one) and reuse it without another API call.
  /// Returns `null` (and logs the user out) when the refresh fails.
  Future<AccessCredentials?> refreshCredentials(String usedAccessToken);

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

  CancelToken _sessionCancelToken = CancelToken();

  @override
  CancelToken get sessionCancelToken {
    // A cancelled token means the previous session ended — vend a fresh scope.
    if (_sessionCancelToken.isCancelled) _sessionCancelToken = CancelToken();
    return _sessionCancelToken;
  }

  @override
  Future<AccessCredentials?> getAccessCredentials() async =>
      _refreshingMutex.synchronize(() => _doRefresh(force: false));

  @override
  Future<AccessCredentials?> refreshCredentials(String usedAccessToken) => _refreshingMutex.synchronize(() async {
    final current = switch (_user) {
      AuthenticatedUser(:final credentials) => credentials,
      _ => null,
    };
    // Token-generation guard: another request in the same 401 wave already
    // refreshed, so the stored token differs from the one that got rejected.
    // Reuse it instead of hitting the refresh endpoint again.
    if (current != null && current.accessToken.token != usedAccessToken) return current;
    try {
      return await _doRefresh(force: true);
    } on Object {
      // Failure already cleared credentials, emitted `unauthenticated`, and ended the
      // session. Signal "could not refresh" to the caller uniformly as null.
      return null;
    }
  });

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
      _endSession(); // abort in-flight requests bound to this session
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
      cr = await _refreshingMutex.synchronize(() => _doRefresh(force: false));
    } finally {
      if (cr != null) _userController.add(_user);
    }
    return _user;
  }

  @override
  Future<void> terminate() async {
    _endSession(); // abort any in-flight requests bound to the session
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

  /// Ends the current session scope, aborting any in-flight request bound to
  /// [sessionCancelToken] (called on logout and on a failed refresh). The next
  /// read of [sessionCancelToken] vends a fresh, uncancelled token.
  void _endSession() {
    if (!_sessionCancelToken.isCancelled) _sessionCancelToken.cancel();
  }

  /// Single source of truth for refreshing tokens. Always invoked inside
  /// [_refreshingMutex], so only one refresh runs at a time.
  ///
  /// When [force] is `false` (proactive path) the current credentials are
  /// returned untouched unless they are about to expire. When `true` (reactive
  /// path, after a `401`) the refresh endpoint is always called.
  Future<AccessCredentials?> _doRefresh({bool force = false}) async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        try {
          final AuthenticatedUser(:AccessCredentials? credentials, :UserId userId) = authUser;
          if (credentials == null || credentials.accessToken.token.isNullOrSpace) {
            throw Exception('Credentials are missing');
          }

          if (!force && !credentials.accessToken.expiresSoon) return credentials;

          // print('>>> accessToken: ${DateFormat().format(credentials.accessToken.expiry)}');
          // print('>>> accessToken: ${credentials.accessToken.token}');
          // print('>>> refreshToken: ${credentials.refreshToken}');

          final refresh = await _api.refreshTokens(
            credentials.accessToken.token,
            credentials.refreshToken,
          );

          if (refresh == null) {
            _endSession();
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
        } on Object {
          _endSession();
          _settings
            ..setUserId(UserIdX.empty).ignore()
            ..setCredentials(null).ignore();

          _userController.add(_user = const AuthUser.unauthenticated());

          rethrow;
        }

      default:
        return null;
      // Error.throwWithStackTrace('User is not authenticated', stackTrace);
    }
  }
}
