import 'package:sentry_flutter/sentry_flutter.dart';

/// Injects Sentry distributed-tracing headers (`sentry-trace` + `baggage`) from [span] into
/// [headers] (HTTP headers or gRPC metadata) so the backend continues the same trace — giving
/// end-to-end traces across the client and the backend microservices.
///
/// Idempotent: an already-present trace header is never overridden. The "already present" check is
/// case-insensitive (HTTP header names are case-insensitive), so a differently-cased inbound
/// `Sentry-Trace`/`Baggage` is respected rather than duplicated. Sentry's header `.name`s are
/// lowercase, as is gRPC metadata.
///
/// Call this only for first-party services. For third-party hosts (e.g. an S3 presigned upload)
/// trace propagation must be skipped so `sentry-trace`/`baggage` aren't leaked off-domain — the
/// HTTP `HttpSentryMiddleware` gates this via its `propagateTrace` flag (the external client sets it
/// to `false`).
void applyTraceHeaders(ISentrySpan span, Map<String, String> headers) {
  final present = headers.keys.map((k) => k.toLowerCase()).toSet();
  final trace = span.toSentryTrace();
  if (!present.contains(trace.name)) headers[trace.name] = trace.value;
  final baggage = span.toBaggageHeader();
  if (baggage != null && baggage.value.isNotEmpty && !present.contains(baggage.name)) {
    headers[baggage.name] = baggage.value;
  }
}
