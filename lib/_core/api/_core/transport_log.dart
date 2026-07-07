// Shared one-line log format for the Connect + HTTP logger middlewares, so the format can't drift
// between transports (the same DRY rationale as sentry_redaction.dart / sentry_tracing.dart).

/// Formats a transport log line: `🌍 <subject> -> <outcome> | <ms>ms`.
///
/// [subject] is the RPC method path (e.g. `/auth.v1.AuthService/Authenticate`) or the HTTP
/// `[METHOD] path`; [outcome] is `'success'` or the transport's error code (e.g. a Connect
/// `Code` name or an `ApiClientException` code).
String formatTransportLog({required String subject, required String outcome, required int elapsedMs}) =>
    '🌍 $subject -> $outcome | ${elapsedMs}ms';
