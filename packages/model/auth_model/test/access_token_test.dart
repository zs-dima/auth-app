import 'dart:convert';

import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds an unsigned JWT (header.payload.signature) with the given payload — enough for the
/// client-side `exp` decode (no signature verification, see AccessToken).
String _jwt(Map<String, Object?> payload) {
  String seg(Object o) => base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${seg(<String, Object?>{'alg': 'none'})}.${seg(payload)}.sig';
}

void main() {
  group('AccessToken.fromJwtToken (A12)', () {
    test('parses the exp claim into a UTC expiry', () {
      final exp = DateTime.now().toUtc().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000;
      final token = AccessToken.fromJwtToken(_jwt(<String, Object?>{'exp': exp}));
      expect(token.expiry.isUtc, isTrue);
      expect(token.hasExpired, isFalse);
    });

    test('throws a typed FormatException (never a bare Exception) on a non-3-segment token', () {
      expect(() => AccessToken.fromJwtToken('only.two'), throwsFormatException);
      expect(() => AccessToken.fromJwtToken('not-a-jwt'), throwsFormatException);
    });

    test('throws FormatException when exp is missing or not an int', () {
      expect(() => AccessToken.fromJwtToken(_jwt(<String, Object?>{'sub': 'x'})), throwsFormatException);
      expect(() => AccessToken.fromJwtToken(_jwt(<String, Object?>{'exp': 'soon'})), throwsFormatException);
    });

    test('throws FormatException when the payload is not base64url JSON', () {
      expect(() => AccessToken.fromJwtToken('aaa.%%%.bbb'), throwsFormatException);
    });
  });

  test('value equality (used by the setCredentials dedup guard)', () {
    final expiry = DateTime.utc(2030);
    expect(AccessToken(token: 'x', expiry: expiry), equals(AccessToken(token: 'x', expiry: expiry)));
    expect(
      AccessToken(token: 'x', expiry: expiry).hashCode,
      AccessToken(token: 'x', expiry: expiry).hashCode,
    );
    expect(AccessToken(token: 'x', expiry: expiry), isNot(equals(AccessToken(token: 'y', expiry: expiry))));
  });
}
