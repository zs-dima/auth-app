/// The authorization server **definitively rejected** the refresh token (invalid / expired /
/// revoked / reused; RPC `UNAUTHENTICATED` / `PERMISSION_DENIED` / `INVALID_ARGUMENT` on the
/// refresh RPC): the session is dead. Transient failures are never mapped to this.
class CredentialsRejectedException implements Exception {
  const CredentialsRejectedException([this.message = 'Refresh token rejected by the server']);

  final String message;

  @override
  String toString() => 'CredentialsRejectedException: $message';
}

/// The rejected access token was not minted in the CURRENT session — the request outlived a
/// sign-out/sign-in (A27). Transient-shaped for the auth middlewares (no `onAuthError`): the
/// stale request fails, the current session is untouched. Expected teardown for telemetry;
/// carries no token material.
class RequestSessionEndedException implements Exception {
  const RequestSessionEndedException();

  @override
  String toString() => 'RequestSessionEndedException: the originating session has ended';
}
