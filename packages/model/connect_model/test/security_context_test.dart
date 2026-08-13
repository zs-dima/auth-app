@TestOn('vm')
library;

import 'package:connect_model/src/client/http_client_io.dart';
import 'package:connect_model/src/client/root_certificates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('securityContextForAddress (A24 — TLS by scheme)', () {
    test('pinned SecurityContext for https/wss', () {
      expect(securityContextForAddress(Uri.parse('https://api.example.com')), isNotNull);
      expect(securityContextForAddress(Uri.parse('wss://api.example.com')), isNotNull);
    });

    test('null (h2c, insecure) for http/ws', () {
      expect(securityContextForAddress(Uri.parse('http://localhost:8080')), isNull);
      expect(securityContextForAddress(Uri.parse('ws://localhost:8080')), isNull);
    });

    test('the pinned context builds (every bundled root PEM parses)', () {
      // setTrustedCertificatesBytes throws on malformed PEM — building the context validates it.
      expect(rpcSecurityContext, returnsNormally);
    });
  });

  group('RootCertificates.trustedRoots (pinned trust set)', () {
    test('covers Let\'s Encrypt (X1 + X2) and Google Trust Services (R1-R4)', () {
      const roots = RootCertificates.trustedRoots;
      // The pinned set REPLACES the platform trust store: every CA the backends can serve must be
      // present — LE RSA (X1), LE ECDSA (X2, no cross-sign dependence), GTS for the *.run.app
      // backup host.
      expect('-----BEGIN CERTIFICATE-----'.allMatches(roots).length, 6);
      for (final pem in const [
        RootCertificates.letsEncrypt,
        RootCertificates.letsEncryptEcdsa,
        RootCertificates.gtsRootR1,
        RootCertificates.gtsRootR2,
        RootCertificates.gtsRootR3,
        RootCertificates.gtsRootR4,
      ]) {
        expect(roots, contains(pem));
        expect(pem, endsWith('-----END CERTIFICATE-----'));
      }
    });
  });

  group('defaultAcceptCompressions (grpc-era CodecRegistry parity)', () {
    test('IO advertises + decodes gzip responses', () {
      expect(defaultAcceptCompressions.map((c) => c.name), contains('gzip'));
    });
  });
}
