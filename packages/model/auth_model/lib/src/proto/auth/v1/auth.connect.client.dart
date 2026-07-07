//
//  Generated code. Do not modify.
//  source: auth/v1/auth.proto
//

import "package:connectrpc/connect.dart" as connect;
import "auth.pb.dart" as authv1auth;
import "auth.connect.spec.dart" as specs;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;

/// =============================================================================
/// Auth Service - Authentication, MFA, OAuth, Sessions
/// =============================================================================
/// OWASP Authentication Cheat Sheet compliance:
/// - Multi-identifier (email, phone)
/// - MFA support (blocks 99.9% of automated attacks)
/// - OAuth 2.0 with PKCE
/// - Account lockout (brute-force protection)
/// - Generic error messages (prevent enumeration)
/// - Password change requires current password
/// Core flows:
///   Registration: SignUp → (optional) ConfirmVerification → Active account
///   Login:        Authenticate → (if MFA) VerifyMfa → Tokens issued
///   Password:     ChangePassword (has password) | RecoveryStart/Confirm
///   (forgot/none)
/// Expansion points:
/// - Passkeys/WebAuthn: Add MFA_METHOD_PASSKEY
/// - Magic links: Add RequestMagicLink, VerifyMagicLink
/// - Trusted devices: TrustDevice, Skip MFA on known devices
/// - Audit logging: Add audit metadata fields
/// - Rate limiting hints: Return retry-after in responses
/// =============================================================================
/// =========================================================================
/// Authentication
/// =========================================================================
extension type AuthServiceClient(connect.Transport _transport) {
  /// Authenticate with identifier (email or phone) and password
  /// Returns AuthResult with tokens on success, or error status with lockout
  /// info
  /// Public endpoint — no authentication required.
  Future<authv1auth.AuthResponse> authenticate(
    authv1auth.AuthenticateRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.authenticate,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Exchange a refresh token for a new token pair (public endpoint — the
  /// refresh token itself is the credential; no Bearer JWT is required).
  /// Server contract (mirrors the client spec refresh_token.md §12.2):
  /// - The refresh token is rotated on EVERY success; the response always
  ///   carries the new refresh token, which the client MUST persist.
  /// - A grace window (REFRESH_ROTATE_GRACE_SECONDS, default 60s) accepts the
  ///   immediately-previous token to absorb lost responses and retries; each
  ///   grace replay returns a fresh token and never extends the window.
  /// - Presenting any older (already-rotated) token is treated as token theft:
  ///   the whole session is revoked and UNAUTHENTICATED is returned.
  /// - Definitive rejections (UNAUTHENTICATED / PERMISSION_DENIED /
  ///   INVALID_ARGUMENT) mean the session is dead — the client must sign out.
  ///   Transient faults are reported as UNAVAILABLE / INTERNAL — safe to retry.
  /// - Session lifetime: sliding idle TTL (REFRESH_TOKEN_TTL_DAYS) capped by an
  ///   absolute limit (SESSION_ABSOLUTE_TTL_DAYS) since last re-authentication.
  /// Public endpoint — no authentication required.
  Future<authv1auth.TokenPair> refreshTokens(
    authv1auth.RefreshTokensRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.refreshTokens,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Validate current session/credentials
  Future<authv1auth.ValidateCredentialsResponse> validateCredentials(
    authv1auth.ValidateCredentialsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.validateCredentials,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Sign out and invalidate current session
  Future<googleprotobufempty.Empty> signOut(
    authv1auth.SignOutRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.signOut,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Register a new account
  /// Returns AUTH_STATUS_SUCCESS with tokens, or AUTH_STATUS_PENDING if
  /// verification required
  /// Public endpoint — no authentication required.
  Future<authv1auth.AuthResponse> signUp(
    authv1auth.SignUpRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.signUp,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Complete MFA verification (when Authenticate returns MFA_REQUIRED)
  /// Public endpoint — no authentication required.
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.AuthResponse> verifyMfa(
    authv1auth.VerifyMfaRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.verifyMfa,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get OAuth authorization URL with PKCE state
  /// Public endpoint — no authentication required.
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.GetOAuthUrlResponse> getOAuthUrl(
    authv1auth.GetOAuthUrlRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.getOAuthUrl,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Exchange OAuth callback code for tokens (login or register)
  /// Public endpoint — no authentication required.
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.AuthResponse> exchangeOAuthCode(
    authv1auth.ExchangeOAuthCodeRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.exchangeOAuthCode,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Link OAuth provider to existing authenticated account
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<googleprotobufempty.Empty> linkOAuthProvider(
    authv1auth.LinkOAuthProviderRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.linkOAuthProvider,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Unlink OAuth provider from account
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<googleprotobufempty.Empty> unlinkOAuthProvider(
    authv1auth.UnlinkOAuthProviderRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.unlinkOAuthProvider,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List linked OAuth providers for current user
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.ListLinkedProvidersResponse> listLinkedProviders(
    authv1auth.ListLinkedProvidersRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.listLinkedProviders,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Start password recovery (always returns success to prevent enumeration)
  /// Also used by OAuth-only users to add a password to their account
  /// Public endpoint — no authentication required.
  Future<googleprotobufempty.Empty> recoveryStart(
    authv1auth.RecoveryStartRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.recoveryStart,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Confirm recovery with token and set new password
  /// Public endpoint — no authentication required.
  Future<googleprotobufempty.Empty> recoveryConfirm(
    authv1auth.RecoveryConfirmRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.recoveryConfirm,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Change password (requires current password - OWASP requirement)
  /// Use RecoveryStart/Confirm if user forgot password or has no password
  /// For admin password reset without verification, use UserService.SetPassword
  Future<googleprotobufempty.Empty> changePassword(
    authv1auth.ChangePasswordRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.changePassword,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Request verification code for email or phone (resend)
  Future<googleprotobufempty.Empty> requestVerification(
    authv1auth.RequestVerificationRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.requestVerification,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Confirm verification with token - returns auth tokens for seamless login
  /// Public endpoint — no authentication required.
  Future<authv1auth.AuthResponse> confirmVerification(
    authv1auth.ConfirmVerificationRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.confirmVerification,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get current MFA status for user
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.GetMfaStatusResponse> getMfaStatus(
    authv1auth.GetMfaStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.getMfaStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Begin MFA setup (returns secret/challenge based on method)
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.SetupMfaResponse> setupMfa(
    authv1auth.SetupMfaRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.setupMfa,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Confirm MFA setup with verification code
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<authv1auth.ConfirmMfaSetupResponse> confirmMfaSetup(
    authv1auth.ConfirmMfaSetupRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.confirmMfaSetup,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Disable MFA (requires password verification)
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  Future<googleprotobufempty.Empty> disableMfa(
    authv1auth.DisableMfaRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.disableMfa,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// List all active sessions for the current user.
  /// The current session is identified by the access token's `sid` claim
  /// (OIDC session identifier) — no request payload is needed.
  Future<authv1auth.ListSessionsResponse> listSessions(
    authv1auth.ListSessionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.listSessions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Revoke a specific session by device_id
  Future<googleprotobufempty.Empty> revokeSession(
    authv1auth.RevokeSessionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.revokeSession,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Revoke all sessions except current
  Future<authv1auth.RevokeSessionsResponse> revokeOtherSessions(
    authv1auth.RevokeOtherSessionsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.AuthService.revokeOtherSessions,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
