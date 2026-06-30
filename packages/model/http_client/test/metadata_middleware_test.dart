import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_client/http_client.dart';

void main() {
  group('MetadataMiddleware', () {
    test('injects the provided headers into every request', () async {
      Map<String, String>? seen;
      final mock = MockClient((request) async {
        seen = Map<String, String>.of(request.headers);
        return http.Response('ok', 200);
      });
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          MetadataMiddleware(headers: const {'X-App-Version': '1.2.3', 'X-Environment': 'staging'}).call,
        ],
      );

      await api.get('/data');

      expect(seen, isNotNull);
      expect(seen!['X-App-Version'], equals('1.2.3'));
      expect(seen!['X-Environment'], equals('staging'));
    });

    test('preserves request-specific headers alongside the metadata', () async {
      Map<String, String>? seen;
      final mock = MockClient((request) async {
        seen = Map<String, String>.of(request.headers);
        return http.Response('ok', 200);
      });
      final api = ApiClient(
        baseUrl: () => Uri.parse('https://api.test'),
        client: mock,
        middlewares: <ApiClientMiddleware>[
          MetadataMiddleware(headers: const {'X-App-Name': 'Auth app'}).call,
        ],
      );

      await api.get('/data', headers: {'X-Request-Id': 'abc'});

      expect(seen!['X-App-Name'], equals('Auth app'));
      expect(seen!['X-Request-Id'], equals('abc'));
    });
  });
}
