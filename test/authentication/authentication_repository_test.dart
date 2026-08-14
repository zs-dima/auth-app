import 'dart:async';

import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';

AccessCredentials _creds(String token) => .new(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(hours: 1))),
  refreshToken: RefreshToken('r-$token'),
);

/// Credentials whose access token is valid but within the `expiresSoon` window, so the
/// proactive path attempts a refresh.
AccessCredentials _credsExpiring(String token) => .new(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(seconds: 10))),
  refreshToken: RefreshToken('r-$token'),
);

final _metadata = AppMetadata(
  appName: 'test',
  appVersion: '1.0.0',
  appVersionMajor: 1,
  appVersionMinor: 0,
  appVersionPatch: 0,
  appBuildTimestamp: DateTime.utc(2024),
  appLaunchedTimestamp: DateTime.utc(2024),
  deviceScreenSize: '1x1',
  operatingSystem: 'test',
  processorsCount: 1,
  isWeb: false,
  isRelease: false,
  locale: 'en',
  deviceVersion: '0',
);

/// Counts `refreshTokens` calls; returns token `B`. Set [reject] to simulate a definitive
/// rejection (invalid refresh token) or [fail] to simulate a transient (network) failure.
class _FakeApi implements IAuthenticationApi {
  int refreshCalls = 0;
  bool fail = false; // transient failure → generic Exception
  bool reject = false; // definitive rejection → CredentialsRejectedException

  /// When set, `authenticate` returns it — lets a test commit a NEW session (sign-in) while the
  /// same fake keeps counting refresh calls.
  AuthResult? authResult;

  @override
  Future<AuthResult> authenticate(ISignInData signInData, IDeviceInfo device) async =>
      authResult ?? (throw StateError('_FakeApi.authResult is not set'));

  @override
  Future<AccessCredentials?> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    refreshCalls++;
    if (reject) throw const CredentialsRejectedException();
    if (fail) throw Exception('network blip');
    return _creds('B');
  }

  @override
  Future<void> signOut(AccessToken token) async {}

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Holds `refreshTokens` open on [gate] so a test can interleave a logout with an in-flight refresh.
class _GatedApi implements IAuthenticationApi {
  _GatedApi(this.gate);
  final Completer<void> gate;
  int refreshCalls = 0;

  /// When true, the gated refresh resolves to a definitive rejection instead of rotated tokens.
  bool reject = false;

  @override
  Future<AccessCredentials?> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    refreshCalls++;
    await gate.future;
    if (reject) throw const CredentialsRejectedException();
    return _creds('B');
  }

  @override
  Future<void> signOut(AccessToken token) async {}

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettings implements ISettingsRepository {
  _FakeSettings(this.stored);
  AccessCredentials? stored;

  /// When true, getCredentials throws — simulating a corrupt / schema-incompatible persisted blob.
  bool throwOnGetCredentials = false;

  /// When true, setCredentials(null)/setUserId throw — simulating a storage-layer fault during the
  /// corrupt-blob recovery path.
  bool throwOnClear = false;

  /// When true, ONLY `setUserId(empty)` throws — the ASYMMETRIC fault: one store faults while the
  /// other works. Pins the clear ordering (credentials first): pre-fix, the failing userId clear
  /// ran first and blocked the credentials clear, leaving the refresh token at rest with the
  /// userId still set — a cold start then resurrected the signed-out session.
  bool throwOnClearUserId = false;

  @override
  String get installationId => 'test-install';

  UserId _userId = 'user-1';

  @override
  UserId get userId => _userId;

  @override
  Future<AccessCredentials?> getCredentials() async {
    if (throwOnGetCredentials) throw const FormatException('corrupt credentials blob');
    return stored;
  }

  @override
  Future<void> setUserId(UserId userId) async {
    if ((throwOnClear || throwOnClearUserId) && userId == UserIdX.empty) throw Exception('storage fault');
    _userId = userId;
  }

  @override
  Future<void> setCredentials(AccessCredentials? value) async {
    if (throwOnClear && value == null) throw Exception('storage fault');
    stored = value;
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Fake API that returns a preset [AuthResult] from `authenticate()` and counts `signOut()` calls.
class _SignInApi implements IAuthenticationApi {
  _SignInApi(this.result);
  final AuthResult result;
  int signOutCalls = 0;

  @override
  Future<AuthResult> authenticate(ISignInData data, IDeviceInfo deviceInfo) async => result;

  @override
  Future<void> signOut(AccessToken token) async => signOutCalls++;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Settings that record userId + credentials and can park the FIRST [setCredentials] on a gate, so a
/// test can freeze a sign-in inside `_persistSession` and fire a concurrent logout. Also records the
/// order of writes and can delay non-null credential writes, so the refresh-persist ordering (F1) is
/// observable.
class _RecordingSettings implements ISettingsRepository {
  AccessCredentials? credentials;
  Completer<void>? gate; // one-shot: parks only the first setCredentials

  /// Ordered log of mutations, e.g. `set:B`, `clear`, `userId:user-1`, `userId:`.
  final List<String> writeLog = <String>[];

  /// Artificial latency applied to a non-null [setCredentials]; lets a fire-and-forget write stay
  /// pending long enough to (pre-fix) escape the mutex ordering.
  Duration credentialsWriteDelay = .zero;

  @override
  String get installationId => 'test-install';

  UserId _userId = UserIdX.empty;
  @override
  UserId get userId => _userId;

  @override
  Future<AccessCredentials?> getCredentials() async => credentials;

  @override
  Future<void> setUserId(UserId userId) async {
    _userId = userId;
    writeLog.add('userId:$userId');
  }

  @override
  Future<void> setCredentials(AccessCredentials? value) async {
    final g = gate;
    if (g != null) {
      gate = null;
      await g.future;
    }
    if (value != null && credentialsWriteDelay > .zero) {
      await Future<void>.delayed(credentialsWriteDelay);
    }
    credentials = value;
    writeLog.add(value == null ? 'clear' : 'set:${value.accessToken.token}');
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthenticationRepository _repo(IAuthenticationApi api, ISettingsRepository settings) =>
    .new(api: api, authHandler: AuthenticationHandler(), settings: settings, metadata: _metadata);

void main() {
  group('AuthenticationRepository.refreshCredentials', () {
    test('restore does not refresh a token that is not expiring soon', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);

      await repo.restore();

      expect(api.refreshCalls, isZero);
    });

    test('concurrent 401s trigger exactly one refresh (single-flight)', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      final results = await Future.wait(List.generate(5, (_) => repo.refreshCredentials('A')));

      expect(api.refreshCalls, equals(1), reason: 'one network refresh for the whole 401 wave');
      expect(results.map((r) => r?.accessToken.token), everyElement('B'));
    });

    test('generation guard: a stale used-token returns the rotated token without another call', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      await repo.refreshCredentials('A'); // rotates A -> B (1 call)
      final again = await repo.refreshCredentials('A'); // 'A' is stale; current is 'B'

      expect(again?.accessToken.token, equals('B'));
      expect(api.refreshCalls, equals(1), reason: 'no second API call when the token already rotated');
    });

    test('a definitive rejection returns null, emits unauthenticated, and ends the session', () async {
      final api = _FakeApi()..reject = true;
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();
      final token = repo.sessionCancelToken;

      final emitted = <AuthUser>[];
      final sub = repo.userChanges.listen(emitted.add);

      final result = await repo.refreshCredentials('A');
      await Future<void>.delayed(.zero);
      await sub.cancel();

      expect(result, isNull, reason: 'definitive rejection is signalled as null');
      expect(emitted.whereType<UnauthenticatedUser>(), isNotEmpty);
      expect(token.isCancelled, isTrue, reason: 'a rejected refresh token ends the session');
    });

    test('a transient (network) reactive failure keeps the session and rethrows', () async {
      final api = _FakeApi()..fail = true;
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();
      final token = repo.sessionCancelToken;

      final emitted = <AuthUser>[];
      final sub = repo.userChanges.listen(emitted.add);

      await expectLater(repo.refreshCredentials('A'), throwsA(isA<Exception>()));
      await Future<void>.delayed(.zero);
      await sub.cancel();

      expect(token.isCancelled, isFalse, reason: 'a network blip must not end the session');
      expect(emitted.whereType<UnauthenticatedUser>(), isEmpty, reason: 'no logout on a transient failure');
      expect(repo.user, isA<AuthenticatedUser>());
    });

    test('a transient proactive failure falls back to the current (still-valid) token', () async {
      final api = _FakeApi()..fail = true;
      final repo = _repo(api, _FakeSettings(_credsExpiring('A')));
      addTearDown(repo.terminate);
      await repo.restore(); // proactive refresh of an expiring token blips → falls back to current
      final token = repo.sessionCancelToken;

      final creds = await repo.getAccessCredentials();

      expect(creds?.accessToken.token, equals('A'), reason: 'fall back to the current token, do not log out');
      expect(token.isCancelled, isFalse);
      expect(repo.user, isA<AuthenticatedUser>());
    });
  });

  group('session provenance (A27)', () {
    test('a request from an ended session throws; the new session is untouched', () async {
      final api = _FakeApi()..authResult = AuthResultSuccess(userId: 'user-2', credentials: _creds('B2'));
      final settings = _FakeSettings(_creds('A'));
      final repo = _repo(api, settings);
      addTearDown(repo.terminate);
      await repo.restore(); // session 1: token 'A' registered

      await repo.signOut();
      await repo.signIn(const SignInData(identifier: 'b@c.d', password: 'pw')); // session 2: 'B2'

      final emitted = <AuthUser>[];
      final sub = repo.userChanges.listen(emitted.add);

      // The stale request's 401 arrives only now: its token was minted in the ended session 1, so it
      // must fail — not be retried under session 2's identity, and not log session 2 out.
      await expectLater(repo.refreshCredentials('A'), throwsA(isA<RequestSessionEndedException>()));
      await Future<void>.delayed(.zero);
      await sub.cancel();

      expect(api.refreshCalls, isZero, reason: 'a foreign token must not trigger a refresh');
      expect(settings.stored?.accessToken.token, equals('B2'), reason: 'the new session survives untouched');
      expect(repo.user, isA<AuthenticatedUser>());
      expect(emitted.whereType<UnauthenticatedUser>(), isEmpty, reason: 'no logout of the new session');
    });

    test('a stale token after logout with no re-login fails fast', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      await repo.signOut();

      await expectLater(repo.refreshCredentials('A'), throwsA(isA<RequestSessionEndedException>()));
      expect(api.refreshCalls, isZero, reason: 'no refresh attempt for a token from an ended session');
    });
  });

  group('session cancellation', () {
    test('signOut cancels the session token, then a fresh one is vended', () async {
      final repo = _repo(_FakeApi(), _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      CancelToken currentSession() => repo.sessionCancelToken;
      final before = repo.sessionCancelToken;
      expect(before.isCancelled, isFalse);

      await repo.signOut();
      expect(before.isCancelled, isTrue, reason: 'logout aborts the session');

      // The getter vends a fresh, uncancelled token for the next session.
      final after = currentSession();
      expect(after.isCancelled, isFalse);
      expect(identical(before, after), isFalse);
    });

    test('logout during an in-flight refresh does not resurrect the session (A2 epoch guard)', () async {
      final gate = Completer<void>();
      final api = _GatedApi(gate);
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      final emitted = <AuthUser>[];
      final sub = repo.userChanges.listen(emitted.add);

      // 1) Start a reactive refresh; it parks inside the mutex awaiting the gated network call.
      final refreshFuture = repo.refreshCredentials('A');
      await Future<void>.delayed(.zero);

      // 2) User logs out while the refresh is in flight (bumps the session epoch synchronously).
      final signOutFuture = repo.signOut();

      // 3) Let the refresh resolve with rotated tokens — they must be discarded by the epoch guard.
      gate.complete();
      await refreshFuture;
      await signOutFuture;
      await Future<void>.delayed(.zero);
      await sub.cancel();

      expect(repo.user, isA<UnauthenticatedUser>(), reason: 'logout wins; rotated tokens must not revive the session');
      expect(emitted.isNotEmpty && emitted.last is UnauthenticatedUser, isTrue);
    });

    test('logout during an in-flight sign-in does not tear or resurrect state', () async {
      final creds = _creds('S');
      final api = _SignInApi(AuthResultSuccess(userId: 'user-42', credentials: creds));
      final settings = _RecordingSettings();
      final repo = _repo(api, settings);
      addTearDown(repo.terminate);

      // Freeze the sign-in inside `_persistSession` (parks on the first setCredentials).
      final gate = Completer<void>();
      settings.gate = gate;

      final signInFuture = repo.signIn(const SignInData(identifier: 'a@b.c', password: 'pw'));
      await Future<void>.delayed(.zero); // let sign-in authenticate and park inside persist

      // A concurrent logout arrives (as the authHandler subscription would deliver it).
      final signOutFuture = repo.signOut();

      gate.complete();
      await signInFuture;
      await signOutFuture;
      await Future<void>.delayed(.zero);

      // Invariant: in-memory state and persisted state agree — no torn / resurrected session.
      // (Pre-fix, the un-serialized sign-in commit could leave `_user` authenticated while the
      // persisted userId/credentials were cleared by the racing logout.)
      if (repo.user case AuthenticatedUser(:final userId)) {
        expect(settings.userId, equals(userId));
        expect(settings.credentials, isNotNull);
      } else {
        expect(settings.userId, equals(UserIdX.empty));
        expect(settings.credentials, isNull);
      }
    });

    test('signOut immediately after a successful refresh leaves storage CLEARED (F1 write-ordering)', () async {
      final settings = _RecordingSettings()..credentials = _creds('A');
      await settings.setUserId('user-1');
      final api = _FakeApi(); // refreshTokens → 'B'
      final repo = _repo(api, settings);
      addTearDown(repo.terminate);
      await repo.restore();
      settings.writeLog.clear();

      // Park the refresh INSIDE its persist (the first setCredentials gates), then fire the logout.
      // Under the mutex the awaited refresh persist must complete BEFORE the queued logout's clears —
      // so storage ends up cleared, not holding 'B'. (The logout must land after the refresh entered
      // the mutex: a logout arriving before it would now fail the stale refresh outright — A27.)
      final gate = Completer<void>();
      settings.gate = gate;
      final refreshFuture = repo.refreshCredentials('A');
      await Future<void>.delayed(.zero); // let the refresh reach the gated setCredentials
      final signOutFuture = repo.signOut();
      gate.complete();
      await Future.wait(<Future<void>>[refreshFuture, signOutFuture]);

      expect(settings.credentials, isNull, reason: 'logout must win: no rotated credentials survive');
      expect(settings.userId, equals(UserIdX.empty));
      expect(repo.user, isA<UnauthenticatedUser>());
      expect(
        settings.writeLog.indexOf('clear'),
        greaterThan(settings.writeLog.indexOf('set:B')),
        reason: 'the refresh persist is ordered before the logout clears',
      );
    });

    test('terminate during an in-flight refresh: no StateError escapes', () async {
      final gate = Completer<void>();
      final api = _GatedApi(gate)..reject = true;
      final repo = _repo(api, _FakeSettings(_creds('A')));
      await repo.restore();

      // Park a reactive refresh inside the mutex on the gated network call (past the A27 guard).
      final refreshFuture = repo.refreshCredentials('A');
      await Future<void>.delayed(.zero);

      // App teardown closes the user stream while the refresh is still in flight.
      await repo.terminate();

      // The definitive rejection now drives `_logOutSession` → an emit against a closed controller:
      // the close-safe `_emit` skips the add, so the caller sees the documented `null` instead of a
      // StateError poisoning an arbitrary request during shutdown.
      gate.complete();
      await expectLater(refreshFuture, completion(isNull));
    });

    test('signOut completes and ends the session even when the storage clears throw', () async {
      final settings = _FakeSettings(_creds('A'));
      final repo = _repo(_FakeApi(), settings);
      addTearDown(repo.terminate);
      await repo.restore();
      final token = repo.sessionCancelToken;

      settings.throwOnClear = true;

      // A storage-layer fault must not fail the logout itself (best-effort clears, mirrors F2).
      await expectLater(repo.signOut(), completes);
      expect(repo.user, isA<UnauthenticatedUser>());
      expect(token.isCancelled, isTrue, reason: 'the session still ends despite the storage fault');
    });

    test('a definitive rejection with failing storage clears still resolves to null', () async {
      final api = _FakeApi()..reject = true;
      final settings = _FakeSettings(_creds('A'))..throwOnClear = true;
      final repo = _repo(api, settings);
      addTearDown(repo.terminate);
      await repo.restore();

      // The definitive-rejection contract (null, session ended) must hold even when the logout's
      // storage clears throw — the fault must not escape _doRefresh as a pseudo-transient error.
      final result = await repo.refreshCredentials('A');

      expect(result, isNull);
      expect(repo.user, isA<UnauthenticatedUser>());
    });

    test('signOut with a failing userId clear still erases the refresh token (no resurrection)', () async {
      final settings = _FakeSettings(_creds('A'));
      final repo = _repo(_FakeApi(), settings);
      addTearDown(repo.terminate);
      await repo.restore();

      settings.throwOnClearUserId = true;
      await expectLater(repo.signOut(), completes);

      expect(settings.stored, isNull, reason: 'credentials clear FIRST: the secret must not survive the fault');

      // A cold start over the half-cleared storage (userId still set, credentials gone) must NOT
      // resurrect the signed-out session.
      final repo2 = _repo(_FakeApi(), settings);
      addTearDown(repo2.terminate);
      final user = await repo2.restore();
      expect(user, isA<UnauthenticatedUser>());
    });

    test('signOut publishes unauthenticated without waiting for an in-flight refresh (logout-availability)', () async {
      final gate = Completer<void>();
      final api = _GatedApi(gate);
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      // Park a reactive refresh inside the mutex on the gated network call.
      final refreshFuture = repo.refreshCredentials('A');
      await Future<void>.delayed(.zero);

      // The logout must be visible synchronously — while the refresh still holds the mutex.
      final signOutFuture = repo.signOut();
      expect(repo.user, isA<UnauthenticatedUser>(), reason: 'logout must not queue behind the network (§11.3)');

      gate.complete();
      await refreshFuture;
      await signOutFuture;
    });

    test('a getAccessCredentials queued behind a refresh resolves null after signOut, not the old token', () async {
      final gate = Completer<void>();
      final api = _GatedApi(gate);
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      // Refresh holds the mutex; a routine token read queues behind it; then the user logs out.
      final refreshFuture = repo.refreshCredentials('A');
      await Future<void>.delayed(.zero);
      final pending = repo.getAccessCredentials();
      final signOutFuture = repo.signOut();

      gate.complete();
      await refreshFuture;

      // Pre-fix the queued read ran while `_user` was still authenticated and handed out the ended
      // session's token; the early logout emit makes it resolve null.
      await expectLater(pending, completion(isNull));
      await signOutFuture;
    });
  });

  group('restore', () {
    test('over a corrupt credentials blob clears it and degrades to logged-out (F2)', () async {
      final settings = _FakeSettings(_creds('A'))..throwOnGetCredentials = true;
      final repo = _repo(_FakeApi(), settings);
      addTearDown(repo.terminate);

      final user = await repo.restore();

      expect(user, isA<UnauthenticatedUser>());
      expect(repo.user, isA<UnauthenticatedUser>());
      expect(settings.stored, isNull, reason: 'the corrupt blob is cleared');
    });

    test('survives a storage that also fails to clear the corrupt blob (F2 recovery guard)', () async {
      final settings = _FakeSettings(_creds('A'))
        ..throwOnGetCredentials = true
        ..throwOnClear = true;
      final repo = _repo(_FakeApi(), settings);
      addTearDown(repo.terminate);

      // Must not rethrow out of restore() (which would fail every cold start).
      await expectLater(repo.restore(), completes);
      expect(repo.user, isA<UnauthenticatedUser>());
    });

    test('completes on the storage read alone; the proactive refresh is detached (§11.1)', () async {
      final gate = Completer<void>();
      final api = _GatedApi(gate);
      final repo = _repo(api, _FakeSettings(_credsExpiring('A'))); // expiring ⇒ proactive refresh runs
      addTearDown(repo.terminate);

      // Pre-fix this await hung on the gated network call — cold start blocked on the network.
      final user = await repo.restore().timeout(const Duration(seconds: 1));
      expect(user, isA<AuthenticatedUser>(), reason: 'the rehydrated session returns without the refresh');

      await Future<void>.delayed(.zero);
      expect(api.refreshCalls, equals(1), reason: 'the detached proactive refresh has started');

      gate.complete();
      await Future<void>.delayed(.zero);
      final refreshed = repo.user;
      expect(refreshed, isA<AuthenticatedUser>());
      expect(
        (refreshed as AuthenticatedUser).credentials?.accessToken.token,
        equals('B'),
        reason: 'the detached refresh corrects the state once it lands',
      );
    });

    test('emits the rehydrated user BEFORE the proactive refresh completes (F6)', () async {
      final gate = Completer<void>();
      final api = _GatedApi(gate);
      final repo = _repo(api, _FakeSettings(_credsExpiring('A'))); // expiring ⇒ proactive refresh runs
      addTearDown(repo.terminate);

      final emitted = <AuthUser>[];
      final sub = repo.userChanges.listen(emitted.add);

      final restoreFuture = repo.restore();
      await Future<void>.delayed(.zero); // let restore rehydrate + emit, then park on the gate

      expect(
        emitted.whereType<AuthenticatedUser>(),
        isNotEmpty,
        reason: 'the session is emitted immediately, before the network refresh resolves',
      );

      gate.complete();
      await restoreFuture;
      await Future<void>.delayed(.zero);
      await sub.cancel();
    });

    test('with a definitive rejection ends the session and clears storage (F6)', () async {
      final api = _FakeApi()..reject = true;
      final settings = _FakeSettings(_credsExpiring('A'));
      final repo = _repo(api, settings);
      addTearDown(repo.terminate);

      final emitted = <AuthUser>[];
      final sub = repo.userChanges.listen(emitted.add);

      await repo.restore();
      await Future<void>.delayed(.zero);
      await sub.cancel();

      final unauthenticated = isA<UnauthenticatedUser>();

      expect(repo.user, unauthenticated);
      expect(emitted.last, unauthenticated, reason: 'the dead session is corrected to logged-out');
      expect(settings.stored, isNull, reason: 'a definitively rejected session is cleared from storage');
    });
  });
}
