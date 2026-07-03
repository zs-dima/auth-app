import 'dart:async';

import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/_core/tool/device_info.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';
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
      msg ??
          (lockoutInfo.retryAfterSeconds > 0
              ? 'Account locked. Try again in ${lockoutInfo.retryAfterSeconds} seconds.'
              : 'Account locked. Please try again later.'),
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

  /// Forces a token refresh after a request was rejected with `401`. Single-flight via the same
  /// mutex as [getAccessCredentials]: one 401 wave performs one network refresh, the rest reuse
  /// the rotated token. Returns `null` (and logs out) on a definitive rejection.
  ///
  /// Throws [RequestSessionEndedException] when [usedAccessToken] was not minted in the current
  /// session (A27): the stale request fails without touching the current session.
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
  /// Serializes all auth-state mutations (refresh, sign-in commit, logout). Instance-scoped —
  /// one lock per repository (A22).
  final Mutex _refreshingMutex = Mutex();

  /// Monotonic session generation, bumped by [_endSession]: a refresh started in an older
  /// generation must not commit its rotated tokens (A2 — no session resurrection).
  int _sessionEpoch = 0;

  /// Access tokens minted in THIS session (seeded at sign-in/restore, extended per rotation,
  /// cleared by [_endSession]). Guards [refreshCredentials] against serving another session's
  /// credentials to a stale request (A27 — refresh_token.md §7.2).
  final Set<String> _sessionAccessTokens = <String>{};

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
    // A27: a token not minted in this session means the request outlived a sign-out/sign-in —
    // fail it (transient-shaped, no logout), never hand it this session's credentials (§7.2).
    if (!_sessionAccessTokens.contains(usedAccessToken)) throw const RequestSessionEndedException();
    final current = switch (_user) {
      AuthenticatedUser(:final credentials) => credentials,
      _ => null,
    };
    // Same-wave dedup: the stored token already rotated past [usedAccessToken] — reuse it.
    if (current != null && current.accessToken.token != usedAccessToken) return current;
    return _doRefresh(force: true);
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
  Future<void> signOut() {
    // End the session synchronously BEFORE awaiting the lock, so an in-flight refresh sees the
    // new epoch and discards its rotation (A2); state clearing then serializes on the mutex.
    _endSession();
    return _refreshingMutex.synchronize(() async {
      try {
        if (_user case final AuthenticatedUser authenticatedUser) {
          final accessToken = authenticatedUser.credentials?.accessToken;
          if (accessToken != null && accessToken.token.isNotEmpty) _api.signOut(accessToken).ignore();
        }
      } finally {
        _emit(const AuthUser.unauthenticated());
        // Awaited under the mutex so the clears order after any in-flight commit (F1); best-effort
        // (F2): a storage fault must not fail the logout (refresh_token.md §11.3).
        try {
          await _settings.setUserId(UserIdX.empty);
          await _settings.setCredentials(null);
        } on Object catch (error, stackTrace) {
          logger.w('Failed to clear the persisted session on logout', error: error, stackTrace: stackTrace);
        }
      }
    });
  }

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

    // A corrupt persisted blob must not hard-fail startup: clear it, degrade to logged-out (F2).
    AccessCredentials? credentials;
    try {
      credentials = await _settings.getCredentials();
    } on Object catch (e, st) {
      logger.w('Failed to restore credentials; clearing persisted session', error: e, stackTrace: st);
      // The recovery itself must not throw either — degrade to logged-out no matter what.
      try {
        await _settings.setUserId(UserIdX.empty);
        await _settings.setCredentials(null);
      } on Object catch (error, stackTrace) {
        logger.w('Failed to clear the corrupt persisted session', error: error, stackTrace: stackTrace);
      }
      return _user;
    }

    if (userId == UserIdX.empty || credentials == null) return _user;

    // A fresh session boundary for the provenance guard (A27).
    _sessionAccessTokens
      ..clear()
      ..add(credentials.accessToken.token);
    // Emit the rehydrated session BEFORE the network refresh so a returning user does not flash
    // the sign-in screen (F6); the refresh below corrects the state (refresh_token.md §11.1).
    _emit(AuthUser.authenticated(userId: userId, credentials: credentials));
    await _refreshingMutex.synchronize(() => _doRefresh(force: false));
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
  Future<AuthUser> _handleAuthResult(AuthResult result) async {
    switch (result) {
      case AuthResultSuccess(:final userId, :final credentials):
        // Commit under the SAME mutex as refresh/logout so persist + set + emit are atomic against
        // a racing signOut (A2); only this short commit is locked — the network call ran in the
        // caller. Persist BEFORE publish: an unpersisted session is not a session (fails closed).
        return _refreshingMutex.synchronize(() async {
          await _persistSession(userId, credentials);
          // Every sign-in commit is a new session boundary for the provenance guard (A27).
          _sessionAccessTokens
            ..clear()
            ..add(credentials.accessToken.token);
          final authUser = AuthUser.authenticated(credentials: credentials, userId: userId);
          _emit(authUser);
          return authUser;
        });

      case AuthResultMfaRequired():
      case AuthResultFailed():
      case AuthResultLocked():
      case AuthResultSuspended():
      case AuthResultPending():
        throw AuthenticationException(result);
    }
  }

  /// Persists the freshly authenticated session. Fails closed on a write error: rolls back any
  /// partial write, best-effort revokes the just-issued server session, and rethrows.
  Future<void> _persistSession(UserId userId, AccessCredentials credentials) async {
    try {
      await _settings.setUserId(userId);
      await _settings.setCredentials(credentials);
    } on Object catch (error, stackTrace) {
      logger.w('Failed to persist session after authentication; revoking server session', error: error, stackTrace: stackTrace);
      // Roll back a partial write so restore() can't rebuild a mismatched session; best-effort.
      try {
        await _settings.setUserId(UserIdX.empty);
        await _settings.setCredentials(null);
      } on Object {/* best-effort rollback */}
      final accessToken = credentials.accessToken;
      if (accessToken.token.isNotEmpty) _api.signOut(accessToken).ignore();
      rethrow;
    }
  }

  /// Publishes [user]: in-memory state updates unconditionally; the stream add is skipped once the
  /// controller is closed, so late refresh/logout emits can't throw after [terminate].
  void _emit(AuthUser user) {
    _user = user;
    if (!_userController.isClosed) _userController.add(user);
  }

  /// Ends the session scope: bumps [_sessionEpoch] (A2), clears [_sessionAccessTokens] (A27), and
  /// cancels [sessionCancelToken] (a fresh one is vended on the next read).
  void _endSession() {
    _sessionEpoch++;
    _sessionAccessTokens.clear();
    if (!_sessionCancelToken.isCancelled) _sessionCancelToken.cancel();
  }

  /// Definitive logout (rejected refresh token / unrecoverable credentials): ends the session,
  /// emits `unauthenticated`, clears storage. Always runs inside [_refreshingMutex].
  Future<void> _logOutSession() async {
    _endSession();
    _emit(const AuthUser.unauthenticated());
    // Awaited (F1) and best-effort (F2): a storage fault must not escape [_doRefresh] as a
    // pseudo-transient error after the session already ended in memory.
    try {
      await _settings.setUserId(UserIdX.empty);
      await _settings.setCredentials(null);
    } on Object catch (error, stackTrace) {
      logger.w('Failed to clear the persisted session on logout', error: error, stackTrace: stackTrace);
    }
  }

  /// Single source of truth for refreshing tokens; always invoked inside [_refreshingMutex].
  ///
  /// Only a definitive rejection ends the session (refresh_token.md §8):
  /// - definitive ([CredentialsRejectedException] or a `null` result) → log out, return `null`;
  /// - transient (network/timeout/5xx) → keep the session: proactive ([force] `false`) falls back
  ///   to the current credentials, reactive ([force] `true`) rethrows.
  Future<AccessCredentials?> _doRefresh({bool force = false}) async {
    switch (_user) {
      case final AuthenticatedUser authUser:
        final AuthenticatedUser(:AccessCredentials? credentials, :UserId userId) = authUser;
        // Missing credentials on an "authenticated" user is an unrecoverable, definitive state.
        if (credentials == null || credentials.accessToken.token.isNullOrSpace) {
          await _logOutSession();
          return null;
        }

        // Proactive: nothing to do unless the token is about to expire.
        if (!force && !credentials.accessToken.expiresSoon) return credentials;

        // Epoch snapshot: a logout during the refresh must discard the rotated tokens (A2).
        final epoch = _sessionEpoch;
        try {
          final refresh = await _api.refreshTokens(credentials.accessToken.token, credentials.refreshToken);

          // The session ended while we awaited — the logout's cleared state stands (A2).
          if (epoch != _sessionEpoch) return null;

          // Defensive: an API that signals rejection via `null` instead of throwing.
          if (refresh == null) {
            await _logOutSession();
            return null;
          }

          // AWAIT the writes: a detached write could be overtaken by a queued logout's clears and
          // resurrect the session on the next restore (F1).
          await _settings.setUserId(userId);
          await _settings.setCredentials(refresh);

          // Re-check after the persist awaits: a logout that raced them wins — skip the emission;
          // its queued clears leave storage cleared (A2).
          if (epoch != _sessionEpoch) return null;

          // Register the rotation only after the re-check, so a discarded one never enters (A27).
          _sessionAccessTokens.add(refresh.accessToken.token);
          _emit(AuthUser.authenticated(credentials: refresh, userId: userId));
          return refresh;
        } on CredentialsRejectedException {
          // Definitive: the refresh token is dead — end the session.
          await _logOutSession();
          return null;
        } on Object {
          // Transient: keep the session (proactive → current token; reactive → rethrow).
          if (!force) return credentials;
          rethrow;
        }

      default:
        return null;
    }
  }
}
