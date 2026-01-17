import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/user/user_id.dart';
import 'package:meta/meta.dart';

/// Type of identifier for authentication (email or phone).
enum IdentifierType {
  /// Email address.
  email,

  /// Phone number in E.164 format (+1234567890).
  phone,
}

/// OAuth provider for social login.
enum OAuthProvider {
  google,
  github,
  microsoft,
  apple,
  facebook,
}

/// Verification type for email/phone confirmation.
enum VerificationType {
  email,
  phone,
}

/// Authentication status representing the outcome of an authentication attempt.
enum AuthStatus {
  /// Authentication successful, tokens provided.
  success,

  /// First factor passed, MFA verification required.
  mfaRequired,

  /// Invalid credentials (generic message per OWASP).
  failed,

  /// Account temporarily locked due to failed attempts.
  locked,

  /// Account suspended by admin.
  suspended,

  /// Account pending email/phone verification.
  pending,
}

/// MFA method types available for second factor authentication.
enum MfaMethod {
  /// Time-based OTP (authenticator apps).
  totp,

  /// SMS OTP.
  sms,

  /// Email OTP.
  email,

  /// One-time recovery codes.
  recoveryCode,
}

/// Information about an available MFA method.
@immutable
final class MfaMethodInfo {
  const MfaMethodInfo({
    required this.method,
    required this.hint,
    this.isDefault = false,
  });

  /// The MFA method type.
  final MfaMethod method;

  /// Masked hint (e.g., "***-***-1234" for SMS).
  final String hint;

  /// Whether this is the user's preferred method.
  final bool isDefault;
}

/// MFA challenge returned when second factor is required.
@immutable
final class MfaChallenge {
  const MfaChallenge({
    required this.challengeToken,
    required this.availableMethods,
    required this.expiresAt,
  });

  /// Token to correlate MFA verification with original auth attempt.
  final String challengeToken;

  /// Available MFA methods for this user.
  final List<MfaMethodInfo> availableMethods;

  /// Challenge expiration timestamp (Unix millis).
  final int expiresAt;

  /// Whether the challenge has expired.
  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiresAt;
}

/// Account lockout information.
@immutable
final class LockoutInfo {
  const LockoutInfo({
    required this.retryAfterSeconds,
    required this.failedAttempts,
    required this.maxAttempts,
    this.lockedUntil,
  });

  /// Seconds until account is unlocked.
  final int retryAfterSeconds;

  /// Number of failed attempts.
  final int failedAttempts;

  /// Maximum attempts before lockout.
  final int maxAttempts;

  /// Lockout timestamp (Unix millis), null if not locked.
  final int? lockedUntil;

  /// Whether the account is currently locked.
  bool get isLocked => lockedUntil != null && DateTime.now().millisecondsSinceEpoch < lockedUntil!;
}

/// Result of an authentication attempt.
///
/// This sealed class properly models all possible authentication outcomes
/// following OWASP best practices:
/// - Generic error messages to prevent user enumeration
/// - MFA support for defense in depth
/// - Account lockout information for brute-force protection
@immutable
sealed class AuthResult {
  const AuthResult();

  /// Authentication status.
  AuthStatus get status;
}

/// Successful authentication result.
@immutable
final class AuthResultSuccess extends AuthResult {
  const AuthResultSuccess({
    required this.userId,
    required this.credentials,
  });

  /// Authenticated user ID.
  final UserId userId;

  /// Access credentials (tokens).
  final AccessCredentials credentials;

  @override
  AuthStatus get status => .success;
}

/// MFA required - first factor passed, second factor needed.
@immutable
final class AuthResultMfaRequired extends AuthResult {
  const AuthResultMfaRequired({required this.mfaChallenge});

  /// MFA challenge details.
  final MfaChallenge mfaChallenge;

  @override
  AuthStatus get status => .mfaRequired;
}

/// Authentication failed.
@immutable
final class AuthResultFailed extends AuthResult {
  const AuthResultFailed({this.message});

  /// Generic error message (OWASP: prevent user enumeration).
  final String? message;

  @override
  AuthStatus get status => .failed;
}

/// Account locked due to failed attempts.
@immutable
final class AuthResultLocked extends AuthResult {
  const AuthResultLocked({required this.lockoutInfo, this.message});

  /// Lockout details.
  final LockoutInfo lockoutInfo;

  /// Optional message.
  final String? message;

  @override
  AuthStatus get status => .locked;
}

/// Account suspended by admin.
@immutable
final class AuthResultSuspended extends AuthResult {
  const AuthResultSuspended({this.message});

  /// Optional message.
  final String? message;

  @override
  AuthStatus get status => .suspended;
}

/// Account pending verification.
@immutable
final class AuthResultPending extends AuthResult {
  const AuthResultPending({this.message});

  /// Optional message.
  final String? message;

  @override
  AuthStatus get status => .pending;
}

// =============================================================================
// SESSION MANAGEMENT
// =============================================================================

/// Information about an active session.
@immutable
final class SessionInfo {
  const SessionInfo({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.createdAt,
    required this.lastSeenAt,
    required this.isCurrent,
    this.clientVersion,
    this.ipAddress,
    this.ipCountry,
    this.ipCreatedBy,
    this.expiresAt,
    this.activityCount,
    this.metadata,
  });

  /// Unique device identifier.
  final String deviceId;

  /// Human-readable device name.
  final String deviceName;

  /// Device type: 'mobile', 'tablet', 'desktop', 'web'.
  final String deviceType;

  /// App version.
  final String? clientVersion;

  /// Last seen IP address (may be masked for privacy).
  final String? ipAddress;

  /// ISO 3166-1 alpha-2 country code.
  final String? ipCountry;

  /// IP address that created the session.
  final String? ipCreatedBy;

  /// Session creation timestamp (Unix millis).
  final int createdAt;

  /// Last activity timestamp (Unix millis).
  final int lastSeenAt;

  /// Session expiration timestamp (Unix millis).
  final int? expiresAt;

  /// True if this is the current session.
  final bool isCurrent;

  /// Number of activities in this session.
  final int? activityCount;

  /// Additional session metadata.
  final Map<String, String>? metadata;
}

// =============================================================================
// OAUTH
// =============================================================================

/// Linked OAuth provider information.
@immutable
final class LinkedProvider {
  const LinkedProvider({
    required this.provider,
    required this.providerUserId,
    required this.linkedAt,
    this.email,
  });

  /// OAuth provider.
  final OAuthProvider provider;

  /// Provider's user ID.
  final String providerUserId;

  /// Email from provider (if available).
  final String? email;

  /// Link timestamp (Unix millis).
  final int linkedAt;
}

/// OAuth authorization URL response.
@immutable
final class OAuthUrl {
  const OAuthUrl({
    required this.authorizationUrl,
    required this.state,
  });

  /// Authorization URL to redirect user.
  final String authorizationUrl;

  /// State parameter (for CSRF protection).
  final String state;
}

// =============================================================================
// MFA MANAGEMENT
// =============================================================================

/// Status of a configured MFA method.
@immutable
final class MfaMethodStatus {
  const MfaMethodStatus({
    required this.method,
    required this.enabled,
    required this.configuredAt,
    this.hint,
  });

  /// MFA method.
  final MfaMethod method;

  /// Whether this method is enabled.
  final bool enabled;

  /// Masked hint for this method.
  final String? hint;

  /// When this method was configured (Unix millis).
  final int configuredAt;
}

/// MFA status for current user.
@immutable
final class MfaStatus {
  const MfaStatus({
    required this.enabled,
    required this.methods,
    required this.recoveryCodesRemaining,
  });

  /// Whether MFA is enabled.
  final bool enabled;

  /// Configured MFA methods.
  final List<MfaMethodStatus> methods;

  /// Number of unused recovery codes remaining.
  final int recoveryCodesRemaining;
}

/// MFA setup response.
@immutable
final class MfaSetup {
  const MfaSetup({
    required this.setupToken,
    required this.expiresAt,
    this.secret,
    this.provisioningUri,
    this.maskedDestination,
  });

  /// For TOTP: base32-encoded secret.
  final String? secret;

  /// For TOTP: otpauth:// URI for QR code generation.
  final String? provisioningUri;

  /// For SMS/Email: masked destination where code was sent.
  final String? maskedDestination;

  /// Setup token to correlate with confirmation.
  final String setupToken;

  /// Setup expires at (Unix millis).
  final int expiresAt;
}

/// MFA setup result.
@immutable
final class MfaSetupResult {
  const MfaSetupResult({
    required this.success,
    this.recoveryCodes,
    this.errorMessage,
  });

  /// Whether setup succeeded.
  final bool success;

  /// Recovery codes (only returned on first MFA enrollment).
  final List<String>? recoveryCodes;

  /// Error message if failed.
  final String? errorMessage;
}
