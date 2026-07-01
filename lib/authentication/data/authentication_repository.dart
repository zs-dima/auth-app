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
  /// Serializes ALL auth-state mutations (refresh + logout), so a refresh cannot interleave with
  /// a logout. Instance-scoped (not `static`): one lock per repository, so multi-account /
  /// impersonation / test instances don't head-of-line block each other (A22).
  final Mutex _refreshingMutex = Mutex();

  /// Monotonic session generation. Bumped whenever the session ends ([_endSession]); a refresh
  /// started in an older generation must not commit its rotated tokens (A2 — prevents a logout
  /// that races an in-flight refresh from being "resurrected" with fresh credentials).
  int _sessionEpoch = 0;

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
    // Contract: returns the rotated creds on success; `null` on a definitive rejection
    // (session already ended); and rethrows a transient failure (session left intact) so
    // the caller surfaces the original error and a later request can retry.
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
    // End the session synchronously (bump epoch + cancel the token) BEFORE awaiting the lock, so an
    // in-flight refresh holding the mutex sees the new epoch and discards its rotated tokens instead
    // of resurrecting this just-ended session (A2). Clearing of state then runs under the mutex so
    // it is serialized after any in-flight refresh commit.
    _endSession();
    return _refreshingMutex.synchronize(() async {
      try {
        if (_user case final AuthenticatedUser authenticatedUser) {
          final accessToken = authenticatedUser.credentials?.accessToken;
          if (accessToken != null && accessToken.token.isNotEmpty) _api.signOut(accessToken).ignore();
        }
      } finally {
        _userController.add(_user = const AuthUser.unauthenticated());
        // Await the local clears (don't fire-and-forget): a logout must durably erase credentials
        // before it completes, and awaiting under the mutex lets it actually ORDER these writes ahead
        // of any sign-in commit racing the same secure storage (which has no cross-call ordering).
        await _settings.setUserId(UserIdX.empty);
        await _settings.setCredentials(null);
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

    // A corrupt or schema-incompatible persisted credentials blob must NOT hard-fail app startup:
    // clear it and degrade to logged-out so the user can sign in again (the 'Restore credentials'
    // init step would otherwise rethrow this as fatal).
    AccessCredentials? credentials;
    try {
      credentials = await _settings.getCredentials();
    } on Object catch (e, st) {
      logger.w('Failed to restore credentials; clearing persisted session', error: e, stackTrace: st);
      await _settings.setUserId(UserIdX.empty);
      await _settings.setCredentials(null);
      return _user;
    }

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
  Future<AuthUser> _handleAuthResult(AuthResult result) async {
    switch (result) {
      case AuthResultSuccess(:final userId, :final credentials):
        // Commit under the SAME mutex as refresh/logout, so persist + in-memory set + emit are atomic
        // (A2). Without this, the sign-in commit is the only state-mutating path outside the mutex, so
        // a concurrent signOut() (delivered by the authHandler subscription, which bypasses the
        // controller's sequential handler) could interleave between the awaits below and leave
        // in-memory state disagreeing with what is persisted (session resurrection / torn storage).
        // The network authenticate() ran in the caller, outside the lock — only this short commit is
        // serialized. Whichever of {sign-in, logout} reaches the mutex last wins cleanly.
        //
        // Persist BEFORE publishing the session: a sign-in succeeds only once the credentials are
        // durably stored, otherwise it would not survive a restart. [_persistSession] fails closed —
        // on a write error it revokes the just-issued server session best-effort and rethrows, so we
        // never surface a half-established session instead of swallowing the failure.
        return _refreshingMutex.synchronize(() async {
          await _persistSession(userId, credentials);
          final authUser = AuthUser.authenticated(credentials: credentials, userId: userId);
          _userController.add(_user = authUser);
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

  /// Persists the freshly authenticated session (userId + credentials). On a write failure the
  /// session could not be stored locally — we authenticated with the server but cannot keep the
  /// session — so roll back any partial local write, revoke it server-side best-effort (don't leak
  /// an orphaned session the client can no longer see) and rethrow so the caller fails closed rather
  /// than proceeding half-signed-in.
  Future<void> _persistSession(UserId userId, AccessCredentials credentials) async {
    try {
      await _settings.setUserId(userId);
      await _settings.setCredentials(credentials);
    } on Object catch (error, stackTrace) {
      logger.w('Failed to persist session after authentication; revoking server session', error: error, stackTrace: stackTrace);
      // Fail closed locally too: roll back any partial write (e.g. userId written but credentials not)
      // so a later restore() can't rebuild a half / mismatched session. Best-effort — if storage
      // itself is the failure, swallow the rollback error and still rethrow the original.
      try {
        await _settings.setUserId(UserIdX.empty);
        await _settings.setCredentials(null);
      } on Object {/* best-effort rollback */}
      final accessToken = credentials.accessToken;
      if (accessToken.token.isNotEmpty) _api.signOut(accessToken).ignore();
      rethrow;
    }
  }

  /// Ends the current session scope, aborting any in-flight request bound to
  /// [sessionCancelToken] (called on logout and on a failed refresh). Bumps [_sessionEpoch] so a
  /// concurrent in-flight refresh won't commit into the ended session. The next read of
  /// [sessionCancelToken] vends a fresh, uncancelled token.
  void _endSession() {
    _sessionEpoch++;
    if (!_sessionCancelToken.isCancelled) _sessionCancelToken.cancel();
  }

  /// Ends the session and clears all local auth state — the definitive logout used when the
  /// server rejects the refresh token (or credentials are unrecoverable). Aborts in-flight
  /// requests bound to [sessionCancelToken] and emits `unauthenticated`.
  Future<void> _logOutSession() async {
    _endSession();
    _userController.add(_user = const AuthUser.unauthenticated());
    // Await the local clears so a definitive logout durably erases credentials before returning
    // (same rationale as [signOut]). Always runs inside [_refreshingMutex] via [_doRefresh].
    await _settings.setUserId(UserIdX.empty);
    await _settings.setCredentials(null);
  }

  /// Single source of truth for refreshing tokens. Always invoked inside [_refreshingMutex],
  /// so only one refresh runs at a time.
  ///
  /// Failure policy (OAuth2 best practice — only a definitive rejection ends the session):
  /// - **Definitive rejection** ([CredentialsRejectedException], or a `null` result): log out
  ///   and return `null`.
  /// - **Transient failure** (network/timeout/5xx): keep the session — on the proactive path
  ///   ([force] `false`) fall back to the current still-valid credentials; on the reactive path
  ///   ([force] `true`, after a `401`) rethrow so the caller surfaces the error and retries later.
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

        // Snapshot the session generation: if a logout ends the session while the network refresh
        // is in flight, the rotated tokens below must be discarded (A2 — no session resurrection).
        final epoch = _sessionEpoch;
        try {
          final refresh = await _api.refreshTokens(credentials.accessToken.token, credentials.refreshToken);

          // The session ended (logout) while we were awaiting the refresh — drop the rotated tokens
          // so they are neither persisted nor emitted; the logout's cleared state stands.
          if (epoch != _sessionEpoch) return null;

          // Defensive: an API that signals rejection via `null` instead of throwing.
          if (refresh == null) {
            await _logOutSession();
            return null;
          }

          _settings
            ..setUserId(userId).ignore()
            ..setCredentials(refresh).ignore();
          _userController.add(_user = AuthUser.authenticated(credentials: refresh, userId: userId));
          return refresh;
        } on CredentialsRejectedException {
          // Definitive: the refresh token is invalid/expired/revoked — end the session.
          await _logOutSession();
          return null;
        } on Object {
          // Transient: keep the session. Proactive ⇒ use the current (still-valid) token;
          // reactive ⇒ surface the error so a later request can retry the refresh.
          if (!force) return credentials;
          rethrow;
        }

      default:
        return null;
    }
  }
}
