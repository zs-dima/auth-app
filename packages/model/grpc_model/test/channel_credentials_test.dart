@TestOn('vm')
library;

import 'package:grpc_model/src/client/channel_io.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('channelCredentialsForAddress (A24 — TLS by scheme)', () {
    test('secure for https/wss', () {
      expect(channelCredentialsForAddress(Uri.parse('https://api.example.com')).isSecure, isTrue);
      expect(channelCredentialsForAddress(Uri.parse('wss://api.example.com')).isSecure, isTrue);
    });

    test('insecure for http/ws', () {
      expect(channelCredentialsForAddress(Uri.parse('http://localhost:8080')).isSecure, isFalse);
      expect(channelCredentialsForAddress(Uri.parse('ws://localhost:8080')).isSecure, isFalse);
    });
  });
}
