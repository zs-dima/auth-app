import 'package:auth_model/auth_model.dart';
import 'package:auth_model/src/proto/auth/v1/auth.connect.spec.dart';
import 'package:connect_kit/connect_kit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kAuthServicePublicPaths (A19)', () {
    test('includes the no-access-token flows that must skip token-attach', () {
      // These were missing before A19, so the middleware attached a (nonexistent) token and forced a
      // spurious logout, breaking the MFA-completion and email-verification flows.
      expect(kAuthServicePublicPaths, contains('/auth.v1.AuthService/VerifyMfa'));
      expect(kAuthServicePublicPaths, contains('/auth.v1.AuthService/ConfirmVerification'));
      // Plus the original public set.
      expect(kAuthServicePublicPaths, contains('/auth.v1.AuthService/Authenticate'));
      expect(kAuthServicePublicPaths, contains('/auth.v1.AuthService/RefreshTokens'));
    });

    test('every entry is a well-formed auth.v1.AuthService method path', () {
      for (final path in kAuthServicePublicPaths) {
        expect(path, startsWith('/auth.v1.AuthService/'), reason: '$path is not an AuthService path');
      }
    });

    test('matches the GENERATED spec procedures after normalization (A19 for real)', () {
      // The middleware dispatches on ConnectMiddleware.normalizePath(spec.procedure); every public
      // constant must match its generated spec exactly, or token-attach/session-ending logic
      // silently breaks (R3). Pins the codegen's slash convention too.
      final publicSpecs = [
        AuthService.authenticate,
        AuthService.signUp,
        AuthService.signOut,
        AuthService.verifyMfa,
        AuthService.recoveryStart,
        AuthService.recoveryConfirm,
        AuthService.refreshTokens,
        AuthService.confirmVerification,
        AuthService.getOAuthUrl,
        AuthService.exchangeOAuthCode,
      ];

      final normalized = publicSpecs.map((s) => ConnectMiddleware.normalizePath(s.procedure)).toSet();
      expect(normalized, equals(kAuthServicePublicPaths));
      expect(
        ConnectMiddleware.normalizePath(AuthService.refreshTokens.procedure),
        equals(kAuthServiceRefreshTokensPath),
      );
    });
  });
}
