@TestOn('vm')
library;

import 'package:connect_model/src/client/http_client_io.dart';
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

    test('the pinned context builds (the bundled Let\'s Encrypt PEM parses)', () {
      // setTrustedCertificatesBytes throws on malformed PEM — building the context validates it.
      expect(rpcSecurityContext, returnsNormally);
    });
  });

  group('defaultAcceptCompressions (grpc-era CodecRegistry parity)', () {
    test('IO advertises + decodes gzip responses', () {
      expect(defaultAcceptCompressions.map((c) => c.name), contains('gzip'));
    });
  });
}
