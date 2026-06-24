/// Thrown when the authorization server **definitively rejects** the refresh token —
/// it is invalid, expired, revoked, or reused (`invalid_grant`; gRPC `UNAUTHENTICATED` /
/// `PERMISSION_DENIED` / `INVALID_ARGUMENT` on the refresh RPC).
///
/// This signals the session is genuinely dead and the user must re-authenticate.
/// Transient failures (no connectivity, timeout, `UNAVAILABLE`, 5xx) are **not** mapped to
/// this — they propagate as their original error so callers can keep the session and retry.
class CredentialsRejectedException implements Exception {
  const CredentialsRejectedException([this.message = 'Refresh token rejected by the server']);

  final String message;

  @override
  String toString() => 'CredentialsRejectedException: $message';
}
