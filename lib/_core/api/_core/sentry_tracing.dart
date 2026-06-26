import 'package:sentry_flutter/sentry_flutter.dart';

/// Injects Sentry distributed-tracing headers (`sentry-trace` + `baggage`) from [span] into
/// [headers] (HTTP headers or gRPC metadata) so the backend continues the same trace — giving
/// end-to-end traces across the client and the backend microservices.
///
/// Uses [Map.putIfAbsent] so an inbound trace header is never overridden. Appropriate here because
/// these clients only call first-party services; if a third-party host were ever added, scope
/// propagation via Sentry's `tracePropagationTargets` so `baggage` isn't leaked off-domain.
void applyTraceHeaders(ISentrySpan span, Map<String, String> headers) {
  final trace = span.toSentryTrace();
  headers.putIfAbsent(trace.name, () => trace.value);
  final baggage = span.toBaggageHeader();
  if (baggage != null && baggage.value.isNotEmpty) {
    headers.putIfAbsent(baggage.name, () => baggage.value);
  }
}
