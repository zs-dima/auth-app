import 'package:auth_app/_core/api/_core/sentry_tracing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  group('applyTraceHeaders', () {
    // With Sentry uninitialized the hub is disabled, so `startTransaction` returns a NoOp span —
    // enough to exercise the header-injection contract deterministically.
    test('adds the sentry-trace header from the span', () {
      final span = Sentry.startTransaction('t', 'op');
      final headers = <String, String>{};

      applyTraceHeaders(span, headers);

      expect(headers.containsKey('sentry-trace'), isTrue);
    });

    test('does not override an existing inbound sentry-trace header', () {
      final span = Sentry.startTransaction('t', 'op');
      final headers = <String, String>{'sentry-trace': 'inbound'};

      applyTraceHeaders(span, headers);

      expect(headers['sentry-trace'], equals('inbound'));
    });

    test('does not duplicate a differently-cased inbound trace header (case-insensitive)', () {
      final span = Sentry.startTransaction('t', 'op');
      final headers = <String, String>{'Sentry-Trace': 'inbound'};

      applyTraceHeaders(span, headers);

      // The inbound (capitalized) header is respected; no second lowercase key is added.
      expect(headers.keys.where((k) => k.toLowerCase() == 'sentry-trace').length, equals(1));
      expect(headers['Sentry-Trace'], equals('inbound'));
    });

    test('omits baggage when the span has none', () {
      final span = Sentry.startTransaction('t', 'op');
      final headers = <String, String>{};

      applyTraceHeaders(span, headers);

      expect(headers.containsKey('baggage'), isFalse);
    });
  });
}
