import 'dart:math' as math;

import 'package:auth_app/_core/api/http/middlewares/sentry_middleware.dart';
import 'package:core_model/core_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rest_client/rest_client.dart';

/// Mirrors the behavioural middleware of `Dependencies.externalHttpClient` (see
/// `initialize_dependencies.dart`): Retry + Timeout, and deliberately NO auth / app-metadata.
/// Logger + Sentry are observational and are exercised by their own package/integration tests.
ApiClient _externalClient(http.Client client) => ApiClient(
  baseUrl: () => Uri.parse('https://s3.example.test'),
  client: client,
  middlewares: <ApiClientMiddleware>[
    RetryMiddleware(
      backoff: const RetryBackoff(
        maxRetries: 2,
        baseDelay: Duration(milliseconds: 1),
        maxDelay: Duration(milliseconds: 1),
      ),
      random: math.Random(1),
    ).call,
    const TimeoutMiddleware().call,
  ],
);

bool _hasHeader(Map<String, String> headers, String name) =>
    headers.keys.any((k) => k.toLowerCase() == name.toLowerCase());

void main() {
  group('external HTTP client (S3 presigned upload)', () {
    test('PUT to an absolute presigned URL bypasses baseUrl and sends only caller headers', () async {
      Uri? seenUrl;
      late Map<String, String> seenHeaders;
      final mock = MockClient((request) async {
        seenUrl = request.url;
        seenHeaders = request.headers;
        return http.Response('', 200);
      });
      final api = _externalClient(mock);

      const presigned = 'https://bucket.s3.amazonaws.test/users/u1/avatar.webp?X-Amz-Signature=abc';
      await api.put(presigned, headers: {'Content-Type': 'image/webp'}, body: <int>[1, 2, 3]).toBytes();

      expect(seenUrl?.toString(), presigned, reason: 'absolute presigned URL used verbatim, baseUrl ignored');
      // Only what the caller set rides along — no first-party concerns leak to a third party.
      expect(_hasHeader(seenHeaders, 'authorization'), isFalse, reason: 'no bearer token to S3');
      expect(
        seenHeaders.keys.any((k) => k.toLowerCase().startsWith('x-app') || k.toLowerCase() == 'x-environment'),
        isFalse,
        reason: 'no app X-* metadata to S3',
      );
    });

    test('retries a transient 503 on the idempotent PUT', () async {
      var attempts = 0;
      final mock = MockClient((_) async {
        attempts++;
        return attempts == 1 ? http.Response('slow down', 503) : http.Response('', 200);
      });
      final api = _externalClient(mock);

      await api.put('https://bucket.s3.test/x', headers: {'Content-Type': 'image/webp'}, body: <int>[1]).toBytes();
      expect(attempts, 2, reason: 'PUT is idempotent → a transient 503 is retried');
    });
  });

  group('HttpSentryMiddleware trace propagation (S1)', () {
    // Builds a client whose only middleware is HttpSentryMiddleware, so we can observe exactly which
    // headers it injects. Sentry isn't initialised here → a no-op span, but a no-op span still
    // yields a `sentry-trace` header, so the propagateTrace gate is observable either way.
    ApiClient sentryClient(http.Client client, {required bool propagateTrace}) => ApiClient(
      baseUrl: () => Uri.parse('https://s3.example.test'),
      client: client,
      middlewares: <ApiClientMiddleware>[HttpSentryMiddleware(propagateTrace: propagateTrace).call],
    );

    test('propagateTrace: false → no sentry-trace / baggage on the outgoing (S3) request', () async {
      late Map<String, String> seenHeaders;
      final mock = MockClient((request) async {
        seenHeaders = request.headers;
        return http.Response('', 200);
      });

      await sentryClient(mock, propagateTrace: false)
          .put('https://bucket.s3.test/x', headers: {'Content-Type': 'image/webp'}, body: <int>[1])
          .toBytes();

      expect(_hasHeader(seenHeaders, 'sentry-trace'), isFalse, reason: 'no trace header leaks to S3');
      expect(_hasHeader(seenHeaders, 'baggage'), isFalse, reason: 'no baggage leaks to S3');
    });

    test('propagateTrace: true → sentry-trace is injected (the gate actually gates)', () async {
      late Map<String, String> seenHeaders;
      final mock = MockClient((request) async {
        seenHeaders = request.headers;
        return http.Response('', 200);
      });

      await sentryClient(mock, propagateTrace: true)
          .get('https://api.first-party.test/x')
          .toBytes();

      expect(_hasHeader(seenHeaders, 'sentry-trace'), isTrue, reason: 'first-party path propagates the trace');
    });
  });
}
