import 'dart:async';

import 'package:auth_app/_core/model/app_metadata.dart';
import 'package:auth_app/authentication/data/authentication_repository.dart';
import 'package:auth_app/settings/data/settings_repository.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';

AccessCredentials _creds(String token) => AccessCredentials(
  accessToken: AccessToken(token: token, expiry: DateTime.now().toUtc().add(const Duration(hours: 1))),
  refreshToken: RefreshToken('r-$token'),
);

/// Credentials whose access token is valid but within the `expiresSoon` window, so the
/// proactive path attempts a refresh.
AccessCredentials _credsExpiring(String token) => AccessCredentials(
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

  @override
  Future<AccessCredentials?> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    refreshCalls++;
    await gate.future;
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

  @override
  String get installationId => 'test-install';

  @override
  UserId get userId => 'user-1';

  @override
  Future<AccessCredentials?> getCredentials() async => stored;

  @override
  Future<void> setUserId(UserId userId) async {}

  @override
  Future<void> setCredentials(AccessCredentials? value) async => stored = value;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AuthenticationRepository _repo(IAuthenticationApi api, _FakeSettings settings) =>
    AuthenticationRepository(api: api, authHandler: AuthenticationHandler(), settings: settings, metadata: _metadata);

void main() {
  group('AuthenticationRepository.refreshCredentials', () {
    test('restore does not refresh a token that is not expiring soon', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);

      await repo.restore();

      expect(api.refreshCalls, 0);
    });

    test('concurrent 401s trigger exactly one refresh (single-flight)', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      final results = await Future.wait(List.generate(5, (_) => repo.refreshCredentials('A')));

      expect(api.refreshCalls, 1, reason: 'one network refresh for the whole 401 wave');
      expect(results.map((r) => r?.accessToken.token), everyElement('B'));
    });

    test('generation guard: a stale used-token returns the rotated token without another call', () async {
      final api = _FakeApi();
      final repo = _repo(api, _FakeSettings(_creds('A')));
      addTearDown(repo.terminate);
      await repo.restore();

      await repo.refreshCredentials('A'); // rotates A -> B (1 call)
      final again = await repo.refreshCredentials('A'); // 'A' is stale; current is 'B'

      expect(again?.accessToken.token, 'B');
      expect(api.refreshCalls, 1, reason: 'no second API call when the token already rotated');
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
      await Future<void>.delayed(Duration.zero);
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
      await Future<void>.delayed(Duration.zero);
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

      expect(creds?.accessToken.token, 'A', reason: 'fall back to the current token, do not log out');
      expect(token.isCancelled, isFalse);
      expect(repo.user, isA<AuthenticatedUser>());
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
      await Future<void>.delayed(Duration.zero);

      // 2) User logs out while the refresh is in flight (bumps the session epoch synchronously).
      final signOutFuture = repo.signOut();

      // 3) Let the refresh resolve with rotated tokens — they must be discarded by the epoch guard.
      gate.complete();
      await refreshFuture;
      await signOutFuture;
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(repo.user, isA<UnauthenticatedUser>(), reason: 'logout wins; rotated tokens must not revive the session');
      expect(emitted.isNotEmpty && emitted.last is UnauthenticatedUser, isTrue);
    });
  });
}
