// Shared one-line log format for the gRPC + HTTP logger middlewares, so the format can't drift
// between transports (the same DRY rationale as sentry_redaction.dart / sentry_tracing.dart).

/// Formats a transport log line: `🌍 <subject> -> <outcome> | <ms>ms`.
///
/// [subject] is the gRPC method path (e.g. `/auth.v2.AuthService/Authenticate`) or the HTTP
/// `[METHOD] path`; [outcome] is `'success'` or the transport's error code (e.g. a gRPC
/// `StatusCode` or an `ApiClientException` code).
String formatTransportLog({required String subject, required String outcome, required int elapsedMs}) =>
    '🌍 $subject -> $outcome | ${elapsedMs}ms';
