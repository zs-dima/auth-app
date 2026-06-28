import 'package:auth_model/src/grpc/proto/auth/v2/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/grpc/proto/users/v2/users.pb.dart' as users;
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/auth_result.dart';
import 'package:auth_model/src/model/role/role.dart';
import 'package:auth_model/src/model/user/i_user_info.dart';
import 'package:auth_model/src/model/user/user.dart';
import 'package:auth_model/src/model/user/user_info.dart';
import 'package:grpc_model/grpc_model.dart' as core;

// =============================================================================
// USER ROLE MAPPING
// =============================================================================

/// Maps app UserRole to proto UserRole.
extension AppUserRoleX on UserRole {
  core.UserRole toProtoRole() => switch (this) {
    .admin => core.UserRole.USER_ROLE_ADMIN,
    .user => core.UserRole.USER_ROLE_USER,
    .guest => core.UserRole.USER_ROLE_GUEST,
  };
}

/// Maps proto UserRole to app UserRole.
extension ProtoUserRoleX on core.UserRole {
  UserRole toRole() => switch (this) {
    core.UserRole.USER_ROLE_ADMIN => .admin,
    core.UserRole.USER_ROLE_USER => .user,
    core.UserRole.USER_ROLE_GUEST => .guest,
    _ => .guest,
  };
}

// =============================================================================
// USER STATUS MAPPING
// =============================================================================

/// Maps app UserStatus to proto UserStatus.
extension AppUserStatusX on UserStatus {
  core.UserStatus toProtoStatus() => switch (this) {
    .unspecified => core.UserStatus.USER_STATUS_UNSPECIFIED,
    .active => core.UserStatus.USER_STATUS_ACTIVE,
    .pending => core.UserStatus.USER_STATUS_PENDING,
    .suspended => core.UserStatus.USER_STATUS_SUSPENDED,
    .deleted => core.UserStatus.USER_STATUS_DELETED,
  };
}

/// Maps proto UserStatus to app UserStatus.
extension ProtoUserStatusX on core.UserStatus {
  UserStatus toStatus() => switch (this) {
    core.UserStatus.USER_STATUS_ACTIVE => .active,
    core.UserStatus.USER_STATUS_PENDING => .pending,
    core.UserStatus.USER_STATUS_SUSPENDED => .suspended,
    core.UserStatus.USER_STATUS_DELETED => .deleted,
    _ => .unspecified,
  };
}

// =============================================================================
// USER SNAPSHOT (from auth.proto)
// =============================================================================

/// Converts proto UserSnapshot to IUserInfo.
extension UserSnapshotX on rpc.UserSnapshot {
  IUserInfo toUserInfo() => UserInfo(
    id: userId.toId(),
    name: displayName,
    email: email,
    phone: phone.isNotEmpty ? phone : null,
    role: role.toRole(),
    status: status.toStatus(),
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
  );
}

// =============================================================================
// USER INFO (from users.proto)
// =============================================================================

/// Converts proto UserInfo to app IUserInfo.
extension ProtoUserInfoX on users.UserInfo {
  IUserInfo toUserInfo() => UserInfo(
    id: id.toId(),
    name: name,
    email: email,
    phone: phone.isNotEmpty ? phone : null,
    role: role.toRole(),
    status: status.toStatus(),
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    locale: locale.isNotEmpty ? locale : null,
    timezone: timezone.isNotEmpty ? timezone : null,
  );
}

// =============================================================================
// USER (from users.proto)
// =============================================================================

/// Converts proto User to app User.
extension ProtoUserX on users.User {
  User toUser() => .new(
    id: id.toId(),
    name: name,
    email: email,
    phone: phone.isNotEmpty ? phone : null,
    role: role.toRole(),
    status: status.toStatus(),
    emailVerified: emailVerified,
    phoneVerified: phoneVerified,
    mfaEnabled: mfaEnabled,
    hasPassword: hasPassword,
    avatarUrl: avatarUrl.isNotEmpty ? avatarUrl : null,
    locale: locale.isNotEmpty ? locale : null,
    timezone: timezone.isNotEmpty ? timezone : null,
    createdAt: hasCreatedAt() ? createdAt.toDateTime() : null,
    updatedAt: hasUpdatedAt() ? updatedAt.toDateTime() : null,
  );
}

/// Converts app User to proto User.
extension AppUserX on User {
  users.User toProtoUser() {
    // Plain cascade + conditional sets — no `also` (a Kotlin idiom); the Dart way (AGENTS.md #4).
    final proto = users.User()
      ..id = id.toUUID()
      ..name = name
      ..email = email
      ..role = role.toProtoRole()
      ..status = status.toProtoStatus()
      ..emailVerified = emailVerified
      ..phoneVerified = phoneVerified
      ..mfaEnabled = mfaEnabled
      ..hasPassword = hasPassword;
    if (phone != null) proto.phone = phone!;
    if (avatarUrl != null) proto.avatarUrl = avatarUrl!;
    if (locale != null) proto.locale = locale!;
    if (timezone != null) proto.timezone = timezone!;
    return proto;
  }
}

// =============================================================================
// AUTHENTICATION (auth.proto) ↔ domain
// =============================================================================

/// Maps app IdentifierType to proto.
extension AppIdentifierTypeX on IdentifierType {
  rpc.IdentifierType toProto() => switch (this) {
    .email => rpc.IdentifierType.IDENTIFIER_TYPE_EMAIL,
    .phone => rpc.IdentifierType.IDENTIFIER_TYPE_PHONE,
  };
}

/// Maps app VerificationType to proto.
extension AppVerificationTypeX on VerificationType {
  rpc.VerificationType toProto() => switch (this) {
    .email => rpc.VerificationType.VERIFICATION_TYPE_EMAIL,
    .phone => rpc.VerificationType.VERIFICATION_TYPE_PHONE,
  };
}

/// Maps proto MfaMethod to app MfaMethod.
extension ProtoMfaMethodX on rpc.MfaMethod {
  MfaMethod toMfaMethod() => switch (this) {
    rpc.MfaMethod.MFA_METHOD_TOTP => .totp,
    rpc.MfaMethod.MFA_METHOD_SMS => .sms,
    rpc.MfaMethod.MFA_METHOD_EMAIL => .email,
    rpc.MfaMethod.MFA_METHOD_RECOVERY_CODE => .recoveryCode,
    _ => .totp,
  };
}

/// Maps app MfaMethod to proto.
extension AppMfaMethodX on MfaMethod {
  rpc.MfaMethod toProto() => switch (this) {
    .totp => rpc.MfaMethod.MFA_METHOD_TOTP,
    .sms => rpc.MfaMethod.MFA_METHOD_SMS,
    .email => rpc.MfaMethod.MFA_METHOD_EMAIL,
    .recoveryCode => rpc.MfaMethod.MFA_METHOD_RECOVERY_CODE,
  };
}

/// Maps proto OAuthProvider to app OAuthProvider.
extension ProtoOAuthProviderX on rpc.OAuthProvider {
  OAuthProvider toOAuthProvider() => switch (this) {
    rpc.OAuthProvider.OAUTH_PROVIDER_GOOGLE => .google,
    rpc.OAuthProvider.OAUTH_PROVIDER_GITHUB => .github,
    rpc.OAuthProvider.OAUTH_PROVIDER_MICROSOFT => .microsoft,
    rpc.OAuthProvider.OAUTH_PROVIDER_APPLE => .apple,
    rpc.OAuthProvider.OAUTH_PROVIDER_FACEBOOK => .facebook,
    _ => .google,
  };
}

/// Maps app OAuthProvider to proto.
extension AppOAuthProviderX on OAuthProvider {
  rpc.OAuthProvider toProto() => switch (this) {
    .google => rpc.OAuthProvider.OAUTH_PROVIDER_GOOGLE,
    .github => rpc.OAuthProvider.OAUTH_PROVIDER_GITHUB,
    .microsoft => rpc.OAuthProvider.OAUTH_PROVIDER_MICROSOFT,
    .apple => rpc.OAuthProvider.OAUTH_PROVIDER_APPLE,
    .facebook => rpc.OAuthProvider.OAUTH_PROVIDER_FACEBOOK,
  };
}

/// Maps proto LinkedProvider to app LinkedProvider.
extension ProtoLinkedProviderX on rpc.LinkedProvider {
  LinkedProvider toLinkedProvider() => LinkedProvider(
    provider: provider.toOAuthProvider(),
    providerUserId: providerUserId,
    email: email.isNotEmpty ? email : null,
    linkedAt: linkedAt.toDateTime().millisecondsSinceEpoch,
  );
}

/// Maps proto MfaMethodStatus to app MfaMethodStatus.
extension ProtoMfaMethodStatusX on rpc.MfaMethodStatus {
  MfaMethodStatus toMfaMethodStatus() => MfaMethodStatus(
    method: method.toMfaMethod(),
    enabled: enabled,
    hint: hint.isNotEmpty ? hint : null,
    configuredAt: configuredAt.toDateTime().millisecondsSinceEpoch,
  );
}

/// Maps proto SessionInfo to app SessionInfo.
extension ProtoSessionInfoX on rpc.SessionInfo {
  SessionInfo toSessionInfo() => SessionInfo(
    deviceId: deviceId,
    deviceName: deviceName,
    deviceType: deviceType,
    clientVersion: clientVersion.isNotEmpty ? clientVersion : null,
    ipAddress: ipAddress.isNotEmpty ? ipAddress : null,
    ipCountry: ipCountry.isNotEmpty ? ipCountry : null,
    ipCreatedBy: ipCreatedBy.isNotEmpty ? ipCreatedBy : null,
    createdAt: createdAt.toDateTime().millisecondsSinceEpoch,
    lastSeenAt: lastSeenAt.toDateTime().millisecondsSinceEpoch,
    expiresAt: hasExpiresAt() ? expiresAt.toDateTime().millisecondsSinceEpoch : null,
    isCurrent: isCurrent,
    activityCount: activityCount > 0 ? activityCount : null,
    metadata: metadata.isNotEmpty ? Map.fromEntries(metadata.entries) : null,
  );
}

/// Maps a proto AuthResponse to the domain [AuthResult] family.
extension ProtoAuthResponseX on rpc.AuthResponse {
  AuthResult toAuthResult() {
    try {
      return switch (status) {
        rpc.AuthStatus.AUTH_STATUS_SUCCESS => AuthResultSuccess(
          userId: user.userId.toId(),
          credentials: AccessCredentials(
            accessToken: AccessToken.fromJwtToken(tokens.accessToken),
            refreshToken: tokens.refreshToken,
          ),
        ),
        rpc.AuthStatus.AUTH_STATUS_MFA_REQUIRED => AuthResultMfaRequired(
          mfaChallenge: MfaChallenge(
            challengeToken: mfaChallenge.challengeToken,
            expiresAt: mfaChallenge.expiresAt.toDateTime().millisecondsSinceEpoch,
            availableMethods: mfaChallenge.availableMethods
                .map((m) => MfaMethodInfo(method: m.method.toMfaMethod(), hint: m.hint, isDefault: m.isDefault))
                .toList(),
          ),
        ),
        rpc.AuthStatus.AUTH_STATUS_LOCKED => AuthResultLocked(
          message: message.isNotEmpty ? message : null,
          lockoutInfo: LockoutInfo(
            // Guard the well-known Duration: an unset `retryAfter` must not read as a real "0s".
            retryAfterSeconds: lockoutInfo.hasRetryAfter() ? lockoutInfo.retryAfter.seconds.toInt() : 0,
            failedAttempts: lockoutInfo.failedAttempts,
            maxAttempts: lockoutInfo.maxAttempts,
            lockedUntil: lockoutInfo.hasLockedUntil()
                ? lockoutInfo.lockedUntil.toDateTime().millisecondsSinceEpoch
                : null,
          ),
        ),
        rpc.AuthStatus.AUTH_STATUS_SUSPENDED => AuthResultSuspended(message: message.isNotEmpty ? message : null),
        rpc.AuthStatus.AUTH_STATUS_PENDING => AuthResultPending(message: message.isNotEmpty ? message : null),
        _ => AuthResultFailed(message: message.isNotEmpty ? message : null),
      };
    } on FormatException {
      // A12: AUTH_STATUS_SUCCESS carried a malformed/unsigned access token — surface a failed result
      // instead of throwing an opaque error out of the sign-in/verify path.
      return const AuthResultFailed(message: 'Received an invalid authentication token from the server.');
    }
  }
}
