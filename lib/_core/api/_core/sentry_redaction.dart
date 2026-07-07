// Shared redaction for telemetry (Sentry) across transports (HTTP + Connect RPC), so
// credential-bearing header/metadata values and sensitive query params never reach the error
// backend — and the two transports can't drift out of sync.

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
  // AWS SigV4 presigned-URL material: signature = bearer capability, security token = STS secret.
  'x-amz-signature',
  'x-amz-credential',
  'x-amz-security-token',
};

/// Returns a copy of [headers] (HTTP headers or RPC metadata) with credential-bearing values
/// (see [kRedactedHeaders]) replaced by `<redacted>`. Names are matched case-insensitively against
/// the (lowercase) [kRedactedHeaders] set — an O(1) lookup.
Map<String, String> redactSensitiveHeaders(Map<String, String> headers) => <String, String>{
  for (final MapEntry(:key, :value) in headers.entries)
    key: kRedactedHeaders.contains(key.toLowerCase()) ? '<redacted>' : value,
};

/// Returns a copy of [query] (use `Uri.queryParametersAll` to preserve multi-value params) with
/// values for sensitive-named keys (see [kRedactedQueryParams]) replaced by `['<redacted>']`.
Map<String, List<String>> redactSensitiveQuery(Map<String, List<String>> query) => <String, List<String>>{
  for (final MapEntry(:key, :value) in query.entries)
    key: kRedactedQueryParams.contains(key.toLowerCase()) ? const ['<redacted>'] : value,
};

/// Renders [url] with sensitive query values (see [kRedactedQueryParams]) replaced by `<redacted>`.
/// For TELEMETRY (span data / hints / log lines) only — never send the returned URL anywhere: a
/// redacted presigned URL is intentionally broken. A URL without a query is returned unchanged.
String redactSensitiveUrl(Uri url) {
  if (url.query.isEmpty) return url.toString();
  return url.replace(queryParameters: redactSensitiveQuery(url.queryParametersAll)).toString();
}
