import 'package:auth_model/auth_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('kAuthServicePublicPaths (A19)', () {
    test('includes the no-access-token flows that must skip token-attach', () {
      // These were missing before A19, so the middleware attached a (nonexistent) token and forced a
      // spurious logout, breaking the MFA-completion and email-verification flows.
      expect(kAuthServicePublicPaths, contains('/auth.v2.AuthService/VerifyMfa'));
      expect(kAuthServicePublicPaths, contains('/auth.v2.AuthService/ConfirmVerification'));
      // Plus the original public set.
      expect(kAuthServicePublicPaths, contains('/auth.v2.AuthService/Authenticate'));
      expect(kAuthServicePublicPaths, contains('/auth.v2.AuthService/RefreshTokens'));
    });

    test('every entry is a well-formed auth.v2.AuthService method path', () {
      for (final path in kAuthServicePublicPaths) {
        expect(path, startsWith('/auth.v2.AuthService/'), reason: '$path is not an AuthService path');
      }
    });
  });
}
