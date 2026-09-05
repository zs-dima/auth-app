//
//  Generated code. Do not modify.
//  source: auth/v1/auth.proto
//

import "package:connectrpc/connect.dart" as connect;

import "auth.pb.dart" as authv1auth;
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
abstract final class AuthService {
  /// Fully-qualified name of the AuthService service.
  static const name = 'auth.v1.AuthService';

  /// Authenticate with identifier (email or phone) and password
  /// Returns AuthResult with tokens on success, or error status with lockout
  /// info
  /// Public endpoint — no authentication required.
  static const authenticate = connect.Spec(
    '/$name/Authenticate',
    connect.StreamType.unary,
    authv1auth.AuthenticateRequest.new,
    authv1auth.AuthResponse.new,
  );

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
  static const refreshTokens = connect.Spec(
    '/$name/RefreshTokens',
    connect.StreamType.unary,
    authv1auth.RefreshTokensRequest.new,
    authv1auth.TokenPair.new,
  );

  /// Validate current session/credentials
  static const validateCredentials = connect.Spec(
    '/$name/ValidateCredentials',
    connect.StreamType.unary,
    authv1auth.ValidateCredentialsRequest.new,
    authv1auth.ValidateCredentialsResponse.new,
  );

  /// Sign out and invalidate current session
  static const signOut = connect.Spec(
    '/$name/SignOut',
    connect.StreamType.unary,
    authv1auth.SignOutRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Register a new account
  /// Returns AUTH_STATUS_SUCCESS with tokens, or AUTH_STATUS_PENDING if
  /// verification required
  /// Public endpoint — no authentication required.
  static const signUp = connect.Spec(
    '/$name/SignUp',
    connect.StreamType.unary,
    authv1auth.SignUpRequest.new,
    authv1auth.AuthResponse.new,
  );

  /// Complete MFA verification (when Authenticate returns MFA_REQUIRED)
  /// Public endpoint — no authentication required.
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const verifyMfa = connect.Spec(
    '/$name/VerifyMfa',
    connect.StreamType.unary,
    authv1auth.VerifyMfaRequest.new,
    authv1auth.AuthResponse.new,
  );

  /// Get OAuth authorization URL with PKCE state
  /// Public endpoint — no authentication required.
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const getOAuthUrl = connect.Spec(
    '/$name/GetOAuthUrl',
    connect.StreamType.unary,
    authv1auth.GetOAuthUrlRequest.new,
    authv1auth.GetOAuthUrlResponse.new,
  );

  /// Exchange OAuth callback code for tokens (login or register)
  /// Public endpoint — no authentication required.
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const exchangeOAuthCode = connect.Spec(
    '/$name/ExchangeOAuthCode',
    connect.StreamType.unary,
    authv1auth.ExchangeOAuthCodeRequest.new,
    authv1auth.AuthResponse.new,
  );

  /// Link OAuth provider to existing authenticated account
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const linkOAuthProvider = connect.Spec(
    '/$name/LinkOAuthProvider',
    connect.StreamType.unary,
    authv1auth.LinkOAuthProviderRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Unlink OAuth provider from account
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const unlinkOAuthProvider = connect.Spec(
    '/$name/UnlinkOAuthProvider',
    connect.StreamType.unary,
    authv1auth.UnlinkOAuthProviderRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// List linked OAuth providers for current user
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const listLinkedProviders = connect.Spec(
    '/$name/ListLinkedProviders',
    connect.StreamType.unary,
    authv1auth.ListLinkedProvidersRequest.new,
    authv1auth.ListLinkedProvidersResponse.new,
  );

  /// Start password recovery (always returns success to prevent enumeration)
  /// Also used by OAuth-only users to add a password to their account
  /// Public endpoint — no authentication required.
  static const recoveryStart = connect.Spec(
    '/$name/RecoveryStart',
    connect.StreamType.unary,
    authv1auth.RecoveryStartRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Confirm recovery with token and set new password
  /// Public endpoint — no authentication required.
  static const recoveryConfirm = connect.Spec(
    '/$name/RecoveryConfirm',
    connect.StreamType.unary,
    authv1auth.RecoveryConfirmRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Change password (requires current password - OWASP requirement)
  /// Use RecoveryStart/Confirm if user forgot password or has no password
  /// For admin password reset without verification, use UserService.SetPassword
  static const changePassword = connect.Spec(
    '/$name/ChangePassword',
    connect.StreamType.unary,
    authv1auth.ChangePasswordRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Request verification code for email or phone (resend)
  static const requestVerification = connect.Spec(
    '/$name/RequestVerification',
    connect.StreamType.unary,
    authv1auth.RequestVerificationRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Confirm verification with token - returns auth tokens for seamless login
  /// Public endpoint — no authentication required.
  static const confirmVerification = connect.Spec(
    '/$name/ConfirmVerification',
    connect.StreamType.unary,
    authv1auth.ConfirmVerificationRequest.new,
    authv1auth.AuthResponse.new,
  );

  /// Get current MFA status for user
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const getMfaStatus = connect.Spec(
    '/$name/GetMfaStatus',
    connect.StreamType.unary,
    authv1auth.GetMfaStatusRequest.new,
    authv1auth.GetMfaStatusResponse.new,
  );

  /// Begin MFA setup (returns secret/challenge based on method)
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const setupMfa = connect.Spec(
    '/$name/SetupMfa',
    connect.StreamType.unary,
    authv1auth.SetupMfaRequest.new,
    authv1auth.SetupMfaResponse.new,
  );

  /// Confirm MFA setup with verification code
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const confirmMfaSetup = connect.Spec(
    '/$name/ConfirmMfaSetup',
    connect.StreamType.unary,
    authv1auth.ConfirmMfaSetupRequest.new,
    authv1auth.ConfirmMfaSetupResponse.new,
  );

  /// Disable MFA (requires password verification)
  /// Status: NOT IMPLEMENTED — the server currently returns UNIMPLEMENTED.
  static const disableMfa = connect.Spec(
    '/$name/DisableMfa',
    connect.StreamType.unary,
    authv1auth.DisableMfaRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// List all active sessions for the current user.
  /// The current session is identified by the access token's `sid` claim
  /// (OIDC session identifier) — no request payload is needed.
  static const listSessions = connect.Spec(
    '/$name/ListSessions',
    connect.StreamType.unary,
    authv1auth.ListSessionsRequest.new,
    authv1auth.ListSessionsResponse.new,
  );

  /// Revoke a specific session by device_id
  static const revokeSession = connect.Spec(
    '/$name/RevokeSession',
    connect.StreamType.unary,
    authv1auth.RevokeSessionRequest.new,
    googleprotobufempty.Empty.new,
  );

  /// Revoke all sessions except current
  static const revokeOtherSessions = connect.Spec(
    '/$name/RevokeOtherSessions',
    connect.StreamType.unary,
    authv1auth.RevokeOtherSessionsRequest.new,
    authv1auth.RevokeSessionsResponse.new,
  );
}
