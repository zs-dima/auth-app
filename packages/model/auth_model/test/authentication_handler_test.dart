import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthenticationHandler (A26 — single auth-state bus)', () {
    test('delivers authenticated then unauthenticated events to a listener', () async {
      final handler = AuthenticationHandler();
      addTearDown(handler.close);

      final events = <AuthenticationState>[];
      final sub = handler.listen(events.add);

      handler.handleAuthenticated();
      handler.handleAuthenticationError();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, <AuthenticationState>[AuthenticationState.authenticated, AuthenticationState.unauthenticated]);
    });

    test('distinct(): consecutive duplicate events are collapsed', () async {
      final handler = AuthenticationHandler();
      addTearDown(handler.close);

      final events = <AuthenticationState>[];
      final sub = handler.listen(events.add);

      handler
        ..handleAuthenticationError()
        ..handleAuthenticationError();
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(events, <AuthenticationState>[AuthenticationState.unauthenticated]);
    });

    test('emitting after close() is a safe no-op', () async {
      final handler = AuthenticationHandler();
      await handler.close();
      expect(handler.handleAuthenticationError, returnsNormally);
    });
  });
}
