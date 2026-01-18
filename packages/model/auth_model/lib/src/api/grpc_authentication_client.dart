import 'dart:async';

import 'package:auth_model/src/api/i_authentication_api.dart';
import 'package:auth_model/src/api/proto/auth.pbgrpc.dart' as rpc;
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/auth_result.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:core_model/core_model.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc_model/grpc_model.dart' as grpc;

/// gRPC client for authentication service.
class GrpcAuthenticationClient extends grpc.GrpcClient<rpc.AuthServiceClient> implements IAuthenticationApi {
  GrpcAuthenticationClient(super.options) : super(factory: rpc.AuthServiceClient.new);

  // ===========================================================================
  // PRIMARY AUTHENTICATION
  // ===========================================================================

  @override
  Future<AuthResult> authenticate(ISignInData signInData, IDeviceInfo device) async {
    final request = rpc.AuthenticateRequest()
      ..identifier = signInData.identifier
      ..identifierType = _mapIdentifierTypeToProto(signInData.identifierType)
      ..password = signInData.password
      ..clientInfo = _buildClientInfo(device)
      ..installationId = device.installationId.toUUID();

    final result = await client.authenticate(request);
    return _mapAuthResult(result);
  }

  @override
  Future<AuthResult> signUp(SignUpData data, IDeviceInfo device) async {
    final request = rpc.SignUpRequest()
      ..identifier = data.identifier
      ..identifierType = _mapIdentifierTypeToProto(data.identifierType)
      ..password = data.password
      ..displayName = data.displayName
      ..installationId = device.installationId.toUUID()
      ..clientInfo = _buildClientInfo(device);

    if (data.locale != null) request.locale = data.locale!;
    if (data.timezone != null) request.timezone = data.timezone!;

    final result = await client.signUp(request);
    return _mapAuthResult(result);
  }

  @override
  Future<AuthResult> verifyMfa({
    required String challengeToken,
    required MfaMethod method,
    required String code,
    required IDeviceInfo deviceInfo,
  }) async {
    final request = rpc.VerifyMfaRequest()
      ..challengeToken = challengeToken
      ..method = _mapMfaMethodToProto(method)
      ..code = code
      ..clientInfo = _buildClientInfo(deviceInfo);

    final result = await client.verifyMfa(request);
    return _mapAuthResult(result);
  }

  @override
  Future<void> signOut(String token) async {
    try {
      await client.signOut(
        rpc.SignOutRequest(),
        options: CallOptions(metadata: {'authorization': 'Bearer $token'}),
      );
    } on Exception {
      // Ignore - always succeed on client side
    }
  }

  @override
  Future<AccessCredentials> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    final result = await client.refreshTokens(
      rpc.RefreshTokensRequest()..refreshToken = refreshToken,
    );
    return AccessCredentials(
      accessToken: AccessToken.fromJwtToken(result.accessToken),
      refreshToken: result.refreshToken,
    );
  }

  @override
  Future<bool> validateCredentials() async {
    final result = await client.validateCredentials(rpc.ValidateCredentialsRequest());
    return result.valid;
  }

  // ===========================================================================
  // PASSWORD MANAGEMENT
  // ===========================================================================

  @override
  Future<bool> recoveryStart({
    required String identifier,
    IdentifierType identifierType = .email,
  }) async {
    try {
      await client.recoveryStart(
        rpc.RecoveryStartRequest()
          ..identifier = identifier
          ..identifierType = _mapIdentifierTypeToProto(identifierType),
      );
      return true;
    } on Exception {
      return true; // OWASP: always return success to prevent enumeration
    }
  }

  @override
  Future<bool> recoveryConfirm({required String token, required String newPassword}) async {
    try {
      await client.recoveryConfirm(
        rpc.RecoveryConfirmRequest()
          ..token = token
          ..newPassword = newPassword,
      );
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await client.changePassword(
        rpc.ChangePasswordRequest()
          ..currentPassword = currentPassword
          ..newPassword = newPassword,
      );
      return true;
    } on Exception {
      return false;
    }
  }

  // ===========================================================================
  // VERIFICATION
  // ===========================================================================

  @override
  Future<bool> requestVerification(VerificationType type) async {
    try {
      await client.requestVerification(
        rpc.RequestVerificationRequest()..type = _mapVerificationTypeToProto(type),
      );
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<AuthResult> confirmVerification({
    required String token,
    required VerificationType type,
    required IDeviceInfo deviceInfo,
  }) async {
    final request = rpc.ConfirmVerificationRequest()
      ..token = token
      ..type = _mapVerificationTypeToProto(type)
      ..installationId = deviceInfo.installationId.toUUID()
      ..clientInfo = _buildClientInfo(deviceInfo);

    final result = await client.confirmVerification(request);
    return _mapAuthResult(result);
  }

  // ===========================================================================
  // OAUTH
  // ===========================================================================

  @override
  Future<OAuthUrl> getOAuthUrl({
    required OAuthProvider provider,
    String? redirectUri,
    List<String>? scopes,
  }) async {
    final request = rpc.GetOAuthUrlRequest()..provider = _mapOAuthProviderToProto(provider);
    if (redirectUri != null) request.redirectUri = redirectUri;
    if (scopes != null) request.scopes.addAll(scopes);

    final result = await client.getOAuthUrl(request);
    return OAuthUrl(authorizationUrl: result.authorizationUrl, state: result.state);
  }

  @override
  Future<AuthResult> exchangeOAuthCode({
    required String code,
    required String state,
    required IDeviceInfo deviceInfo,
  }) async {
    final request = rpc.ExchangeOAuthCodeRequest()
      ..code = code
      ..state = state
      ..installationId = deviceInfo.installationId.toUUID()
      ..clientInfo = _buildClientInfo(deviceInfo);

    final result = await client.exchangeOAuthCode(request);
    return _mapAuthResult(result);
  }

  @override
  Future<bool> linkOAuthProvider({required String code, required String state}) async {
    try {
      await client.linkOAuthProvider(
        rpc.LinkOAuthProviderRequest()
          ..code = code
          ..state = state,
      );
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<bool> unlinkOAuthProvider(OAuthProvider provider) async {
    try {
      await client.unlinkOAuthProvider(
        rpc.UnlinkOAuthProviderRequest()..provider = _mapOAuthProviderToProto(provider),
      );
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<List<LinkedProvider>> listLinkedProviders() async {
    final result = await client.listLinkedProviders(rpc.ListLinkedProvidersRequest());
    return result.providers.map(_mapLinkedProvider).toList();
  }

  // ===========================================================================
  // MFA MANAGEMENT
  // ===========================================================================

  @override
  Future<MfaStatus> getMfaStatus() async {
    final result = await client.getMfaStatus(rpc.GetMfaStatusRequest());
    return MfaStatus(
      enabled: result.enabled,
      recoveryCodesRemaining: result.recoveryCodesRemaining,
      methods: result.methods.map(_mapMfaMethodStatus).toList(),
    );
  }

  @override
  Future<MfaSetup> setupMfa({required MfaMethod method, String? identifier}) async {
    final request = rpc.SetupMfaRequest()..method = _mapMfaMethodToProto(method);
    if (identifier != null) request.identifier = identifier;

    final result = await client.setupMfa(request);
    return MfaSetup(
      setupToken: result.setupToken,
      expiresAt: result.expiresAt.toDateTime().millisecondsSinceEpoch,
      secret: result.secret.isNotEmpty ? result.secret : null,
      provisioningUri: result.provisioningUri.isNotEmpty ? result.provisioningUri : null,
      maskedDestination: result.maskedDestination.isNotEmpty ? result.maskedDestination : null,
    );
  }

  @override
  Future<MfaSetupResult> confirmMfaSetup({required String setupToken, required String code}) async {
    final result = await client.confirmMfaSetup(
      rpc.ConfirmMfaSetupRequest()
        ..setupToken = setupToken
        ..code = code,
    );
    return switch (result.whichResult()) {
      rpc.ConfirmMfaSetupResponse_Result.success => MfaSetupResult(
        success: true,
        recoveryCodes: result.success.recoveryCodes.isNotEmpty ? result.success.recoveryCodes.toList() : null,
      ),
      rpc.ConfirmMfaSetupResponse_Result.error => MfaSetupResult(
        success: false,
        errorMessage: result.error.message.isNotEmpty ? result.error.message : null,
      ),
      _ => const MfaSetupResult(success: false),
    };
  }

  @override
  Future<bool> disableMfa({required MfaMethod method, required String password}) async {
    try {
      await client.disableMfa(
        rpc.DisableMfaRequest()
          ..method = _mapMfaMethodToProto(method)
          ..password = password,
      );
      return true;
    } on Exception {
      return false;
    }
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  @override
  Future<List<SessionInfo>> listSessions() async {
    final result = await client.listSessions(rpc.ListSessionsRequest());
    return result.sessions.map(_mapSessionInfo).toList();
  }

  @override
  Future<bool> revokeSession(String deviceId) async {
    try {
      await client.revokeSession(rpc.RevokeSessionRequest()..deviceId = deviceId);
      return true;
    } on Exception {
      return false;
    }
  }

  @override
  Future<int> revokeOtherSessions() async {
    final result = await client.revokeOtherSessions(rpc.RevokeOtherSessionsRequest());
    return result.revokedCount;
  }

  // ===========================================================================
  // PRIVATE HELPERS
  // ===========================================================================

  rpc.ClientInfo _buildClientInfo(IDeviceInfo device) => rpc.ClientInfo()
    ..deviceId = device.deviceId
    ..deviceName = device.deviceName
    ..deviceType = '${device.deviceModel} on ${device.deviceOs}'
    ..clientVersion = device.appVersion
    ..metadata.addEntries([
      MapEntry('os', device.deviceOs),
      MapEntry('os_version', device.deviceOsVersion),
      MapEntry('device_model', device.deviceModel),
    ]);

  // ---------------------------------------------------------------------------
  // AuthResult mapping
  // ---------------------------------------------------------------------------

  AuthResult _mapAuthResult(rpc.AuthResponse result) => switch (result.status) {
    rpc.AuthStatus.AUTH_STATUS_SUCCESS => AuthResultSuccess(
      userId: result.user.userId.toId(),
      credentials: AccessCredentials(
        accessToken: AccessToken.fromJwtToken(result.tokens.accessToken),
        refreshToken: result.tokens.refreshToken,
      ),
    ),
    rpc.AuthStatus.AUTH_STATUS_MFA_REQUIRED => AuthResultMfaRequired(
      mfaChallenge: MfaChallenge(
        challengeToken: result.mfaChallenge.challengeToken,
        expiresAt: result.mfaChallenge.expiresAt.toDateTime().millisecondsSinceEpoch,
        availableMethods: result.mfaChallenge.availableMethods
            .map((m) => MfaMethodInfo(method: _mapMfaMethod(m.method), hint: m.hint, isDefault: m.isDefault))
            .toList(),
      ),
    ),
    rpc.AuthStatus.AUTH_STATUS_LOCKED => AuthResultLocked(
      message: result.message.isNotEmpty ? result.message : null,
      lockoutInfo: LockoutInfo(
        retryAfterSeconds: result.lockoutInfo.retryAfter.seconds.toInt(),
        failedAttempts: result.lockoutInfo.failedAttempts,
        maxAttempts: result.lockoutInfo.maxAttempts,
        lockedUntil: result.lockoutInfo.hasLockedUntil()
            ? result.lockoutInfo.lockedUntil.toDateTime().millisecondsSinceEpoch
            : null,
      ),
    ),
    rpc.AuthStatus.AUTH_STATUS_SUSPENDED => AuthResultSuspended(
      message: result.message.isNotEmpty ? result.message : null,
    ),
    rpc.AuthStatus.AUTH_STATUS_PENDING => AuthResultPending(
      message: result.message.isNotEmpty ? result.message : null,
    ),
    _ => AuthResultFailed(message: result.message.isNotEmpty ? result.message : null),
  };

  // ---------------------------------------------------------------------------
  // Enum mappings
  // ---------------------------------------------------------------------------

  rpc.IdentifierType _mapIdentifierTypeToProto(IdentifierType type) => switch (type) {
    .email => rpc.IdentifierType.IDENTIFIER_TYPE_EMAIL,
    .phone => rpc.IdentifierType.IDENTIFIER_TYPE_PHONE,
  };

  rpc.VerificationType _mapVerificationTypeToProto(VerificationType type) => switch (type) {
    .email => rpc.VerificationType.VERIFICATION_TYPE_EMAIL,
    .phone => rpc.VerificationType.VERIFICATION_TYPE_PHONE,
  };

  MfaMethod _mapMfaMethod(rpc.MfaMethod method) => switch (method) {
    rpc.MfaMethod.MFA_METHOD_TOTP => .totp,
    rpc.MfaMethod.MFA_METHOD_SMS => .sms,
    rpc.MfaMethod.MFA_METHOD_EMAIL => .email,
    rpc.MfaMethod.MFA_METHOD_RECOVERY_CODE => .recoveryCode,
    _ => .totp,
  };

  rpc.MfaMethod _mapMfaMethodToProto(MfaMethod method) => switch (method) {
    .totp => rpc.MfaMethod.MFA_METHOD_TOTP,
    .sms => rpc.MfaMethod.MFA_METHOD_SMS,
    .email => rpc.MfaMethod.MFA_METHOD_EMAIL,
    .recoveryCode => rpc.MfaMethod.MFA_METHOD_RECOVERY_CODE,
  };

  OAuthProvider _mapOAuthProvider(rpc.OAuthProvider provider) => switch (provider) {
    rpc.OAuthProvider.OAUTH_PROVIDER_GOOGLE => .google,
    rpc.OAuthProvider.OAUTH_PROVIDER_GITHUB => .github,
    rpc.OAuthProvider.OAUTH_PROVIDER_MICROSOFT => .microsoft,
    rpc.OAuthProvider.OAUTH_PROVIDER_APPLE => .apple,
    rpc.OAuthProvider.OAUTH_PROVIDER_FACEBOOK => .facebook,
    _ => .google,
  };

  rpc.OAuthProvider _mapOAuthProviderToProto(OAuthProvider provider) => switch (provider) {
    .google => rpc.OAuthProvider.OAUTH_PROVIDER_GOOGLE,
    .github => rpc.OAuthProvider.OAUTH_PROVIDER_GITHUB,
    .microsoft => rpc.OAuthProvider.OAUTH_PROVIDER_MICROSOFT,
    .apple => rpc.OAuthProvider.OAUTH_PROVIDER_APPLE,
    .facebook => rpc.OAuthProvider.OAUTH_PROVIDER_FACEBOOK,
  };

  LinkedProvider _mapLinkedProvider(rpc.LinkedProvider p) => .new(
    provider: _mapOAuthProvider(p.provider),
    providerUserId: p.providerUserId,
    email: p.email.isNotEmpty ? p.email : null,
    linkedAt: p.linkedAt.toDateTime().millisecondsSinceEpoch,
  );

  MfaMethodStatus _mapMfaMethodStatus(rpc.MfaMethodStatus s) => .new(
    method: _mapMfaMethod(s.method),
    enabled: s.enabled,
    hint: s.hint.isNotEmpty ? s.hint : null,
    configuredAt: s.configuredAt.toDateTime().millisecondsSinceEpoch,
  );

  SessionInfo _mapSessionInfo(rpc.SessionInfo s) => .new(
    deviceId: s.deviceId,
    deviceName: s.deviceName,
    deviceType: s.deviceType,
    clientVersion: s.clientVersion.isNotEmpty ? s.clientVersion : null,
    ipAddress: s.ipAddress.isNotEmpty ? s.ipAddress : null,
    ipCountry: s.ipCountry.isNotEmpty ? s.ipCountry : null,
    ipCreatedBy: s.ipCreatedBy.isNotEmpty ? s.ipCreatedBy : null,
    createdAt: s.createdAt.toDateTime().millisecondsSinceEpoch,
    lastSeenAt: s.lastSeenAt.toDateTime().millisecondsSinceEpoch,
    expiresAt: s.hasExpiresAt() ? s.expiresAt.toDateTime().millisecondsSinceEpoch : null,
    isCurrent: s.isCurrent,
    activityCount: s.activityCount > 0 ? s.activityCount : null,
    metadata: s.metadata.isNotEmpty ? Map.fromEntries(s.metadata.entries) : null,
  );
}
