// Shared redaction for telemetry (Sentry) across transports (HTTP + gRPC), so credential-bearing
// header/metadata values and sensitive query params never reach the error backend — and the two
// transports can't drift out of sync.

/// Header/metadata names whose values carry credentials and must never be sent to Sentry.
/// Lowercase; matched case-insensitively (see [redactSensitiveHeaders]).
const kRedactedHeaders = <String>{'authorization', 'x-csrf-token', 'cookie', 'set-cookie', 'proxy-authorization'};

/// Query-parameter names whose values carry credentials/PII and must never be sent to Sentry.
/// Lowercase; matched case-insensitively (see [redactSensitiveQuery]).
const kRedactedQueryParams = <String>{
  'token',
  'access_token',
  'refresh_token',
  'id_token',
  'code',
  'api_key',
  'apikey',
  'key',
  'secret',
  'password',
  'sig',
  'signature',
};

/// Returns a copy of [headers] (HTTP headers or gRPC metadata) with credential-bearing values
/// (see [kRedactedHeaders]) replaced by `<redacted>`.
Map<String, String> redactSensitiveHeaders(Map<String, String> headers) => <String, String>{
  for (final MapEntry(:key, :value) in headers.entries)
    key: kRedactedHeaders.any((h) => h.toLowerCase() == key.toLowerCase()) ? '<redacted>' : value,
};

/// Returns a copy of [query] (use `Uri.queryParametersAll` to preserve multi-value params) with
/// values for sensitive-named keys (see [kRedactedQueryParams]) replaced by `['<redacted>']`.
Map<String, List<String>> redactSensitiveQuery(Map<String, List<String>> query) => <String, List<String>>{
  for (final MapEntry(:key, :value) in query.entries)
    key: kRedactedQueryParams.any((k) => k.toLowerCase() == key.toLowerCase()) ? const ['<redacted>'] : value,
};
