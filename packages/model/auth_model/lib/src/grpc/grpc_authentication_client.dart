import 'dart:async';

import 'package:auth_model/src/api/auth_exceptions.dart';
import 'package:auth_model/src/api/i_authentication_api.dart';
import 'package:auth_model/src/grpc/grpc_authentication_converter.dart';
import 'package:auth_model/src/grpc/grpc_authorization.dart';
import 'package:auth_model/src/grpc/grpc_call_guard.dart';
import 'package:auth_model/src/grpc/grpc_exceptions.dart';
import 'package:auth_model/src/grpc/proto/auth/v2/auth.pbgrpc.dart' as rpc;
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
      ..identifierType = signInData.identifierType.toProto()
      ..password = signInData.password
      ..clientInfo = _buildClientInfo(device)
      ..installationId = device.installationId.toUUID();

    final result = await guardGrpcCall(() => client.authenticate(request));
    return result.toAuthResult();
  }

  @override
  Future<AuthResult> signUp(SignUpData data, IDeviceInfo device) async {
    final request = rpc.SignUpRequest()
      ..identifier = data.identifier
      ..identifierType = data.identifierType.toProto()
      ..password = data.password
      ..displayName = data.displayName
      ..installationId = device.installationId.toUUID()
      ..clientInfo = _buildClientInfo(device);

    if (data.locale != null) request.locale = data.locale!;
    if (data.timezone != null) request.timezone = data.timezone!;

    final result = await guardGrpcCall(() => client.signUp(request));
    return result.toAuthResult();
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
      ..method = method.toProto()
      ..code = code
      ..clientInfo = _buildClientInfo(deviceInfo);

    final result = await guardGrpcCall(() => client.verifyMfa(request));
    return result.toAuthResult();
  }

  @override
  Future<void> signOut(AccessToken token) async {
    try {
      await client.signOut(
        rpc.SignOutRequest(),
        options: CallOptions(metadata: {kGrpcAuthorizationKey: token.authorizationHeaderValue}),
      );
    } on Exception {
      // Ignore - logout always succeeds on the client side (best-effort server revocation). An
      // expired/invalid token here is irrelevant: the server rejects, we swallow it, the user still
      // signs out (the repository ends the session regardless — see AuthenticationRepository.signOut).
    }
  }

  @override
  Future<AccessCredentials> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    try {
      final result = await client.refreshTokens(
        rpc.RefreshTokensRequest()..refreshToken = refreshToken.value,
      );
      return AccessCredentials(
        accessToken: AccessToken.fromJwtToken(result.accessToken),
        refreshToken: RefreshToken(result.refreshToken),
      );
    } on GrpcError catch (e, st) {
      // Definitive rejection (invalid/expired/revoked refresh token) ⇒ the session is dead.
      if (e.code == StatusCode.unauthenticated ||
          e.code == StatusCode.permissionDenied ||
          e.code == StatusCode.invalidArgument) {
        Error.throwWithStackTrace(CredentialsRejectedException(e.message ?? 'Refresh token rejected'), st);
      }
      // Transient codes (unavailable/deadlineExceeded/internal/…) → domain transient error so the
      // repository keeps the session and retries later (mapped, never a raw GrpcError — A8).
      Error.throwWithStackTrace(GrpcException.from(e), st);
    } on FormatException catch (e, st) {
      // A12: a malformed/unsigned JWT in the refresh response is a definitive, unrecoverable state —
      // map to a definitive rejection so the repository logs out cleanly instead of looping forever
      // treating a structurally-dead session as a transient failure.
      Error.throwWithStackTrace(
        CredentialsRejectedException('Invalid token in refresh response: ${e.message}'),
        st,
      );
    }
  }

  @override
  Future<bool> validateCredentials() async {
    final result = await guardGrpcCall(() => client.validateCredentials(rpc.ValidateCredentialsRequest()));
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
          ..identifierType = identifierType.toProto(),
      );
      return true;
    } on Exception {
      return true; // OWASP: always return success to prevent account enumeration.
    }
  }

  @override
  Future<bool> recoveryConfirm({required String token, required String newPassword}) async {
    // Throws a domain [GrpcException] on a transport/server error (A4) instead of collapsing every
    // failure — including cancellation/network — into an indistinguishable `false`.
    await guardGrpcCall(
      () => client.recoveryConfirm(
        rpc.RecoveryConfirmRequest()
          ..token = token
          ..newPassword = newPassword,
      ),
    );
    return true;
  }

  @override
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    await guardGrpcCall(
      () => client.changePassword(
        rpc.ChangePasswordRequest()
          ..currentPassword = currentPassword
          ..newPassword = newPassword,
      ),
    );
    return true;
  }

  // ===========================================================================
  // VERIFICATION
  // ===========================================================================

  @override
  Future<bool> requestVerification(VerificationType type) async {
    await guardGrpcCall(() => client.requestVerification(rpc.RequestVerificationRequest()..type = type.toProto()));
    return true;
  }

  @override
  Future<AuthResult> confirmVerification({
    required String token,
    required VerificationType type,
    required IDeviceInfo deviceInfo,
  }) async {
    final request = rpc.ConfirmVerificationRequest()
      ..token = token
      ..type = type.toProto()
      ..installationId = deviceInfo.installationId.toUUID()
      ..clientInfo = _buildClientInfo(deviceInfo);

    final result = await guardGrpcCall(() => client.confirmVerification(request));
    return result.toAuthResult();
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
    final request = rpc.GetOAuthUrlRequest()..provider = provider.toProto();
    if (redirectUri != null) request.redirectUri = redirectUri;
    if (scopes != null) request.scopes.addAll(scopes);

    final result = await guardGrpcCall(() => client.getOAuthUrl(request));
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

    final result = await guardGrpcCall(() => client.exchangeOAuthCode(request));
    return result.toAuthResult();
  }

  @override
  Future<bool> linkOAuthProvider({required String code, required String state}) async {
    await guardGrpcCall(
      () => client.linkOAuthProvider(
        rpc.LinkOAuthProviderRequest()
          ..code = code
          ..state = state,
      ),
    );
    return true;
  }

  @override
  Future<bool> unlinkOAuthProvider(OAuthProvider provider) async {
    await guardGrpcCall(() => client.unlinkOAuthProvider(rpc.UnlinkOAuthProviderRequest()..provider = provider.toProto()));
    return true;
  }

  @override
  Future<List<LinkedProvider>> listLinkedProviders() async {
    final result = await guardGrpcCall(() => client.listLinkedProviders(rpc.ListLinkedProvidersRequest()));
    return result.providers.map((p) => p.toLinkedProvider()).toList();
  }

  // ===========================================================================
  // MFA MANAGEMENT
  // ===========================================================================

  @override
  Future<MfaStatus> getMfaStatus() async {
    final result = await guardGrpcCall(() => client.getMfaStatus(rpc.GetMfaStatusRequest()));
    return MfaStatus(
      enabled: result.enabled,
      recoveryCodesRemaining: result.recoveryCodesRemaining,
      methods: result.methods.map((s) => s.toMfaMethodStatus()).toList(),
    );
  }

  @override
  Future<MfaSetup> setupMfa({required MfaMethod method, String? identifier}) async {
    final request = rpc.SetupMfaRequest()..method = method.toProto();
    if (identifier != null) request.identifier = identifier;

    final result = await guardGrpcCall(() => client.setupMfa(request));
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
    final result = await guardGrpcCall(
      () => client.confirmMfaSetup(
        rpc.ConfirmMfaSetupRequest()
          ..setupToken = setupToken
          ..code = code,
      ),
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
    await guardGrpcCall(
      () => client.disableMfa(
        rpc.DisableMfaRequest()
          ..method = method.toProto()
          ..password = password,
      ),
    );
    return true;
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  @override
  Future<List<SessionInfo>> listSessions(String refreshToken) async {
    final result = await guardGrpcCall(() => client.listSessions(rpc.ListSessionsRequest()..refreshToken = refreshToken));
    return result.sessions.map((s) => s.toSessionInfo()).toList();
  }

  @override
  Future<bool> revokeSession(String deviceId) async {
    await guardGrpcCall(() => client.revokeSession(rpc.RevokeSessionRequest()..deviceId = deviceId));
    return true;
  }

  @override
  Future<int> revokeOtherSessions() async {
    final result = await guardGrpcCall(() => client.revokeOtherSessions(rpc.RevokeOtherSessionsRequest()));
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
}
