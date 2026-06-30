import 'package:flutter_test/flutter_test.dart';
import 'package:http_client/http_client.dart';

void main() {
  group('ApiClient.quicHintsForBaseUrl', () {
    test('https host → single hint on the default 443 port', () {
      expect(
        ApiClient.quicHintsForBaseUrl(Uri.parse('https://api.example.com/v1')),
        equals(<(String, int, int)>[('api.example.com', 443, 443)]),
      );
    });

    test('explicit https port is preserved', () {
      expect(
        ApiClient.quicHintsForBaseUrl(Uri.parse('https://api.example.com:8443')),
        equals(<(String, int, int)>[('api.example.com', 8443, 8443)]),
      );
    });

    test('non-https scheme → null (QUIC implies TLS)', () {
      expect(ApiClient.quicHintsForBaseUrl(Uri.parse('http://api.example.com')), isNull);
    });

    test('null uri → null', () {
      expect(ApiClient.quicHintsForBaseUrl(null), isNull);
    });

    test('hostless uri → null', () {
      expect(ApiClient.quicHintsForBaseUrl(Uri.parse('https:///path')), isNull);
    });

    test('IPv6 literal host → null (hints target hostnames; Uri.host drops brackets)', () {
      expect(ApiClient.quicHintsForBaseUrl(Uri.parse('https://[2001:db8::1]:8443/v1')), isNull);
    });

    test('IPv4 literal host is kept (a valid hint host)', () {
      expect(
        ApiClient.quicHintsForBaseUrl(Uri.parse('https://10.0.0.1/v1')),
        equals(<(String, int, int)>[('10.0.0.1', 443, 443)]),
      );
    });

    test('scheme is matched case-insensitively (Uri normalizes to lowercase)', () {
      expect(
        ApiClient.quicHintsForBaseUrl(Uri.parse('HTTPS://api.example.com')),
        equals(<(String, int, int)>[('api.example.com', 443, 443)]),
      );
    });
  });
}
