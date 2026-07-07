import 'dart:async';

import 'package:auth_model/src/api/auth_exceptions.dart';
import 'package:auth_model/src/api/i_authentication_api.dart';
import 'package:auth_model/src/api/rpc_exceptions.dart';
import 'package:auth_model/src/connect/authentication_converter.dart';
import 'package:auth_model/src/connect/authorization.dart';
import 'package:auth_model/src/connect/call_guard.dart';
import 'package:auth_model/src/model/credentials/access_credentials.dart';
import 'package:auth_model/src/model/credentials/access_token.dart';
import 'package:auth_model/src/model/credentials/auth_result.dart';
import 'package:auth_model/src/model/credentials/refresh_token.dart';
import 'package:auth_model/src/model/credentials/sign_in_data.dart';
import 'package:auth_model/src/proto/auth/v1/auth.connect.client.dart' as rpc;
import 'package:auth_model/src/proto/auth/v1/auth.pb.dart' as rpc;
import 'package:connect_model/connect_model.dart';
import 'package:connectrpc/connect.dart';
import 'package:core_model/core_model.dart';
import 'package:meta/meta.dart';

/// Connect RPC client for the authentication service.
class ConnectAuthenticationClient extends ConnectClient implements IAuthenticationApi {
  const ConnectAuthenticationClient(super.transport);

  /// Generated Connect client — an extension type over [transport]; construction is free.
  rpc.AuthServiceClient get client => rpc.AuthServiceClient(transport);

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

    final result = await guardRpcCall((signal) => client.authenticate(request, signal: signal));
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

    final result = await guardRpcCall((signal) => client.signUp(request, signal: signal));
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

    final result = await guardRpcCall((signal) => client.verifyMfa(request, signal: signal));
    return result.toAuthResult();
  }

  @override
  Future<void> signOut(AccessToken token) async {
    try {
      // SignOut is a public path (no auto token attach) — the bearer is attached manually here.
      await guardRpcCall(
        (signal) => client.signOut(
          rpc.SignOutRequest(),
          headers: Headers()..[kAuthorizationHeader] = token.authorizationHeaderValue,
          signal: signal,
        ),
      );
    } on Exception {
      // Best-effort server revocation: client logout must never fail on a network/token error.
    }
  }

  @override
  Future<AccessCredentials> refreshTokens(String accessToken, RefreshToken refreshToken) async {
    try {
      final result = await client.refreshTokens(
        rpc.RefreshTokensRequest()..refreshToken = refreshToken.value,
        signal: TimeoutSignal(ConnectClient.defaultCallTimeout),
      );
      return mapRefreshResponse(result, refreshToken);
    } on ConnectException catch (e, st) {
      // Definitive rejection (invalid/expired/revoked refresh token) ⇒ the session is dead.
      if (e.code == Code.unauthenticated || e.code == Code.permissionDenied || e.code == Code.invalidArgument) {
        Error.throwWithStackTrace(
          CredentialsRejectedException(e.message.isNotEmpty ? e.message : 'Refresh token rejected'),
          st,
        );
      }
      // Transient codes → domain transient error (mapped, never a raw ConnectException — A8).
      Error.throwWithStackTrace(RpcException.from(e), st);
    } on FormatException catch (e, st) {
      // A12: a malformed JWT in the refresh response is definitive — it must never loop as transient.
      Error.throwWithStackTrace(
        CredentialsRejectedException('Invalid token in refresh response: ${e.message}'),
        st,
      );
    }
  }

  /// Maps a `RefreshTokens` response, reusing [previousRefreshToken] when the server omits a
  /// rotated one (RFC 6749 §6) — storing `""` would poison the next refresh into a spurious logout.
  /// The access token is always rotated; its JWT `exp` drives proactive refresh (A12).
  @visibleForTesting
  static AccessCredentials mapRefreshResponse(rpc.TokenPair result, RefreshToken previousRefreshToken) =>
      AccessCredentials(
        accessToken: AccessToken.fromJwtToken(result.accessToken),
        refreshToken: result.refreshToken.isEmpty ? previousRefreshToken : RefreshToken(result.refreshToken),
      );

  @override
  Future<bool> validateCredentials() async {
    final result = await guardRpcCall(
      (signal) => client.validateCredentials(rpc.ValidateCredentialsRequest(), signal: signal),
    );
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
      await guardRpcCall(
        (signal) => client.recoveryStart(
          rpc.RecoveryStartRequest()
            ..identifier = identifier
            ..identifierType = identifierType.toProto(),
          signal: signal,
        ),
      );
      return true;
    } on Exception {
      return true; // OWASP: always return success to prevent account enumeration.
    }
  }

  @override
  Future<bool> recoveryConfirm({required String token, required String newPassword}) async {
    // Throws a domain [RpcException] on failure (A4) instead of collapsing everything to `false`.
    await guardRpcCall(
      (signal) => client.recoveryConfirm(
        rpc.RecoveryConfirmRequest()
          ..token = token
          ..newPassword = newPassword,
        signal: signal,
      ),
    );
    return true;
  }

  @override
  Future<bool> changePassword({required String currentPassword, required String newPassword}) async {
    await guardRpcCall(
      (signal) => client.changePassword(
        rpc.ChangePasswordRequest()
          ..currentPassword = currentPassword
          ..newPassword = newPassword,
        signal: signal,
      ),
    );
    return true;
  }

  // ===========================================================================
  // VERIFICATION
  // ===========================================================================

  @override
  Future<bool> requestVerification(VerificationType type) async {
    await guardRpcCall(
      (signal) => client.requestVerification(rpc.RequestVerificationRequest()..type = type.toProto(), signal: signal),
    );
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

    final result = await guardRpcCall((signal) => client.confirmVerification(request, signal: signal));
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

    final result = await guardRpcCall((signal) => client.getOAuthUrl(request, signal: signal));
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

    final result = await guardRpcCall((signal) => client.exchangeOAuthCode(request, signal: signal));
    return result.toAuthResult();
  }

  @override
  Future<bool> linkOAuthProvider({required String code, required String state}) async {
    await guardRpcCall(
      (signal) => client.linkOAuthProvider(
        rpc.LinkOAuthProviderRequest()
          ..code = code
          ..state = state,
        signal: signal,
      ),
    );
    return true;
  }

  @override
  Future<bool> unlinkOAuthProvider(OAuthProvider provider) async {
    await guardRpcCall(
      (signal) =>
          client.unlinkOAuthProvider(rpc.UnlinkOAuthProviderRequest()..provider = provider.toProto(), signal: signal),
    );
    return true;
  }

  @override
  Future<List<LinkedProvider>> listLinkedProviders() async {
    final result = await guardRpcCall(
      (signal) => client.listLinkedProviders(rpc.ListLinkedProvidersRequest(), signal: signal),
    );
    return result.providers.map((p) => p.toLinkedProvider()).toList();
  }

  // ===========================================================================
  // MFA MANAGEMENT
  // ===========================================================================

  @override
  Future<MfaStatus> getMfaStatus() async {
    final result = await guardRpcCall((signal) => client.getMfaStatus(rpc.GetMfaStatusRequest(), signal: signal));
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

    final result = await guardRpcCall((signal) => client.setupMfa(request, signal: signal));
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
    final result = await guardRpcCall(
      (signal) => client.confirmMfaSetup(
        rpc.ConfirmMfaSetupRequest()
          ..setupToken = setupToken
          ..code = code,
        signal: signal,
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
    await guardRpcCall(
      (signal) => client.disableMfa(
        rpc.DisableMfaRequest()
          ..method = method.toProto()
          ..password = password,
        signal: signal,
      ),
    );
    return true;
  }

  // ===========================================================================
  // SESSION MANAGEMENT
  // ===========================================================================

  @override
  Future<List<SessionInfo>> listSessions() async {
    final result = await guardRpcCall((signal) => client.listSessions(rpc.ListSessionsRequest(), signal: signal));
    return result.sessions.map((s) => s.toSessionInfo()).toList();
  }

  @override
  Future<bool> revokeSession(String deviceId) async {
    await guardRpcCall(
      (signal) => client.revokeSession(rpc.RevokeSessionRequest()..deviceId = deviceId, signal: signal),
    );
    return true;
  }

  @override
  Future<int> revokeOtherSessions() async {
    final result = await guardRpcCall(
      (signal) => client.revokeOtherSessions(rpc.RevokeOtherSessionsRequest(), signal: signal),
    );
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
