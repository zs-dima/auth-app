import 'dart:async';

import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/auth_result.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:core_model/core_model.dart';

/// Authentication API interface.
///
/// Follows OWASP Authentication Cheat Sheet best practices:
/// - Multi-identifier support (email, phone)
/// - Multi-factor authentication support
/// - Account lockout for brute-force protection
/// - Generic error messages to prevent user enumeration
/// - Password change requires current password
abstract interface class IAuthenticationApi {
  // ===========================================================================
  // PRIMARY AUTHENTICATION
  // ===========================================================================

  /// Authenticate with identifier (email or phone) and password.
  ///
  /// Returns [AuthResult] which can be:
  /// - [AuthResultSuccess] - authentication complete, tokens provided
  /// - [AuthResultMfaRequired] - first factor passed, MFA verification needed
  /// - [AuthResultFailed] - invalid credentials
  /// - [AuthResultLocked] - account locked due to failed attempts
  /// - [AuthResultSuspended] - account suspended by admin
  /// - [AuthResultPending] - account pending verification
  Future<AuthResult> authenticate(ISignInData data, IDeviceInfo deviceInfo);

  /// Register a new account.
  ///
  /// Returns [AuthResultSuccess] with tokens, or [AuthResultPending] if verification required.
  Future<AuthResult> signUp(SignUpData data, IDeviceInfo deviceInfo);

  /// Complete MFA verification after receiving [AuthResultMfaRequired].
  Future<AuthResult> verifyMfa({
    required String challengeToken,
    required MfaMethod method,
    required String code,
    required IDeviceInfo deviceInfo,
  });

  /// Sign out and invalidate current session.
  Future<void> signOut(String token);

  /// Refresh access token using refresh token.
  Future<AccessCredentials?> refreshTokens(String accessToken, RefreshToken refreshToken);

  /// Validate current session/credentials.
  Future<bool> validateCredentials();

  // ===========================================================================
  // PASSWORD MANAGEMENT
  // ===========================================================================

  /// Start password recovery (sends reset email/SMS).
  /// Always returns true to prevent user enumeration (OWASP).
  /// Also used by OAuth-only users to add a password.
  Future<bool> recoveryStart({
    required String identifier,
    IdentifierType identifierType = .email,
  });

  /// Confirm recovery with token and set new password.
  Future<bool> recoveryConfirm({required String token, required String newPassword});

  /// Change password (requires current password - OWASP requirement).
  /// Use [recoveryStart]/[recoveryConfirm] if user forgot password.
  Future<bool> changePassword({required String currentPassword, required String newPassword});

  // ===========================================================================
  // VERIFICATION
  // ===========================================================================

  /// Request verification code for email or phone.
  Future<bool> requestVerification(VerificationType type);

  /// Confirm verification with code.
  ///
  /// Returns [AuthResult] for seamless login after verification.
  Future<AuthResult> confirmVerification({
    required String token,
    required VerificationType type,
    required IDeviceInfo deviceInfo,
  });

  // ===========================================================================
  // OAUTH
  // ===========================================================================

  /// Get OAuth authorization URL with PKCE state.
  Future<OAuthUrl> getOAuthUrl({
    required OAuthProvider provider,
    String? redirectUri,
    List<String>? scopes,
  });

  /// Exchange OAuth callback code for tokens.
  Future<AuthResult> exchangeOAuthCode({
    required String code,
    required String state,
    required IDeviceInfo deviceInfo,
  });

  /// Link OAuth provider to existing authenticated account.
  Future<bool> linkOAuthProvider({required String code, required String state});

  /// Unlink OAuth provider from account.
  Future<bool> unlinkOAuthProvider(OAuthProvider provider);

  /// List linked OAuth providers for current user.
  Future<List<LinkedProvider>> listLinkedProviders();

  // ===========================================================================
  // MFA MANAGEMENT
  // ===========================================================================

  /// Get current MFA status for user.
  Future<MfaStatus> getMfaStatus();

  /// Begin MFA setup (returns secret/challenge based on method).
  Future<MfaSetup> setupMfa({required MfaMethod method, String? identifier});

  /// Confirm MFA setup with verification code.
  Future<MfaSetupResult> confirmMfaSetup({required String setupToken, required String code});

  /// Disable MFA (requires password verification).
  Future<bool> disableMfa({required MfaMethod method, required String password});

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  /// List all active sessions for current user.
  Future<List<SessionInfo>> listSessions();

  /// Revoke a specific session by device_id.
  Future<bool> revokeSession(String deviceId);

  /// Revoke all sessions except current.
  Future<int> revokeOtherSessions();
}
