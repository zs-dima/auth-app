import 'package:auth_app/_core/router/authentication_guard.dart';
import 'package:auth_app/_core/router/home_guard.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:octopus/octopus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kUserId = 'a7f1c8d2-0000-4000-8000-000000000001';
  const AuthUser kAuthed = AuthenticatedUser(userId: kUserId, credentials: null);
  const kAnon = AuthUser.unauthenticated();

  final authRoutes = <String>{
    Routes.signin.name,
    Routes.signup.name,
    Routes.authRecoveryStart.name,
    Routes.authRecoveryConfirm.name,
    Routes.emailVerified.name,
  };

  OctopusState atProfile() => OctopusState.single(Routes.profile.node());
  OctopusState atSignin() => OctopusState.single(Routes.signin.node());
  List<String> names(OctopusState state) => state.children.map((c) => c.name).toList();

  late AuthUser user;
  late AuthenticationGuard guard;

  setUp(() {
    user = kAuthed;
    guard = AuthenticationGuard(
      getUser: () => user,
      routes: authRoutes,
      signinNavigation: OctopusState.single(Routes.signin.node()),
      homeNavigation: OctopusState.single(Routes.home.node()),
    );
  });

  /// Mirrors the router: guards receive a mutable state, and the delegate re-mutates every result
  /// before handing it to the next guard (`newConfiguration = result.mutate()`).
  Future<OctopusState> run(OctopusState state, {bool withHomeGuard = true}) async {
    final context = <String, Object?>{};
    final afterAuth = await guard(const <OctopusHistoryEntry>[], state.mutate(), context);
    if (!withHomeGuard) return afterAuth;
    final afterHome = await HomeGuard()(const <OctopusHistoryEntry>[], afterAuth.mutate(), context);
    return afterHome;
  }

  group('AuthenticationGuard logout', () {
    test('an authenticated deep link is replaced by the signin navigation once signed out', () async {
      final signedIn = await run(atProfile());
      expect(names(signedIn), contains(Routes.home.name));

      user = kAnon;
      final signedOut = await run(atProfile());

      expect(names(signedOut), equals(<String>[Routes.signin.name]));
    });

    test('signing out then back in does not restore the previous session deep link', () async {
      await run(atProfile());

      user = kAnon;
      await run(atProfile());

      // Back on the sign-in screen, authenticated again: the guard strips the auth route and
      // restores its remembered navigation, which logout must have reset to home.
      user = kAuthed;
      final restored = await run(atSignin());

      expect(names(restored), equals(<String>[Routes.home.name]));
    });

    test('repeated logouts keep returning a well-formed signin navigation', () async {
      for (var i = 0; i < 3; i++) {
        user = kAuthed;
        await run(atProfile());
        user = kAnon;
        // Pins that the shared `signinNavigation` instance is never corrupted by a later guard.
        expect(names(await run(atProfile())), equals(<String>[Routes.signin.name]), reason: 'iteration $i');
      }
    });
  });

  group('AuthenticationGuard remembered navigation', () {
    // What freeze() pins: HomeGuard clears and rewrites the state in place, so storing the live
    // mutable instance let the remembered navigation be rewritten to `[home]` after the fact.
    test('survives a later guard rewriting the state it was captured from', () async {
      final rewritten = await run(atProfile());
      expect(names(rewritten), equals(<String>[Routes.home.name]), reason: 'HomeGuard rewrote the state in place');

      final restored = await run(atSignin(), withHomeGuard: false);

      expect(names(restored), equals(<String>[Routes.profile.name]));
    });

    test('the restored navigation is not aliased to the router state', () async {
      await run(atProfile(), withHomeGuard: false);

      final first = await run(atSignin(), withHomeGuard: false);
      expect(names(first), equals(<String>[Routes.profile.name]));

      // Mutating what the router handed back must not corrupt the guard's memory.
      first.mutate().clear();

      expect(names(await run(atSignin(), withHomeGuard: false)), equals(<String>[Routes.profile.name]));
    });
  });
}
