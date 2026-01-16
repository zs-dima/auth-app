// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'auth.pb.dart' as $0;

export 'auth.pb.dart';

/// =============================================================================
/// Auth Service - Authentication, MFA, OAuth, Sessions
/// =============================================================================
///
/// OWASP Authentication Cheat Sheet compliance:
/// - Multi-identifier (email, phone)
/// - MFA support (blocks 99.9% of automated attacks)
/// - OAuth 2.0 with PKCE
/// - Account lockout (brute-force protection)
/// - Generic error messages (prevent enumeration)
/// - Password change requires current password
///
/// Core flows:
///   Registration: SignUp → (optional) ConfirmVerification → Active account
///   Login:        Authenticate → (if MFA) VerifyMfa → Tokens issued
///   Password:     ChangePassword (has password) | RecoveryStart/Confirm (forgot/none)
///
/// Expansion points:
/// - Passkeys/WebAuthn: Add MFA_METHOD_PASSKEY
/// - Magic links: Add RequestMagicLink, VerifyMagicLink
/// - Trusted devices: TrustDevice, Skip MFA on known devices
/// - Audit logging: Add audit metadata fields
/// - Rate limiting hints: Return retry-after in responses
/// =============================================================================
@$pb.GrpcServiceName('auth.AuthService')
class AuthServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  AuthServiceClient(super.channel, {super.options, super.interceptors});

  /// Authenticate with identifier (email or phone) and password
  /// Returns AuthResult with tokens on success, or error status with lockout info
  $grpc.ResponseFuture<$0.AuthResponse> authenticate(
    $0.AuthenticateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$authenticate, request, options: options);
  }

  /// Refresh access token using refresh token
  $grpc.ResponseFuture<$0.TokenPair> refreshTokens(
    $0.RefreshTokensRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshTokens, request, options: options);
  }

  /// Validate current session/credentials
  $grpc.ResponseFuture<$0.ValidateCredentialsResponse> validateCredentials(
    $0.ValidateCredentialsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validateCredentials, request, options: options);
  }

  /// Sign out and invalidate current session
  $grpc.ResponseFuture<$1.Empty> signOut(
    $0.SignOutRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$signOut, request, options: options);
  }

  /// Register a new account
  /// Returns AUTH_STATUS_SUCCESS with tokens, or AUTH_STATUS_PENDING if verification required
  $grpc.ResponseFuture<$0.AuthResponse> signUp(
    $0.SignUpRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$signUp, request, options: options);
  }

  /// Complete MFA verification (when Authenticate returns MFA_REQUIRED)
  $grpc.ResponseFuture<$0.AuthResponse> verifyMfa(
    $0.VerifyMfaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$verifyMfa, request, options: options);
  }

  /// Get OAuth authorization URL with PKCE state
  $grpc.ResponseFuture<$0.GetOAuthUrlResponse> getOAuthUrl(
    $0.GetOAuthUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getOAuthUrl, request, options: options);
  }

  /// Exchange OAuth callback code for tokens (login or register)
  $grpc.ResponseFuture<$0.AuthResponse> exchangeOAuthCode(
    $0.ExchangeOAuthCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exchangeOAuthCode, request, options: options);
  }

  /// Link OAuth provider to existing authenticated account
  $grpc.ResponseFuture<$1.Empty> linkOAuthProvider(
    $0.LinkOAuthProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$linkOAuthProvider, request, options: options);
  }

  /// Unlink OAuth provider from account
  $grpc.ResponseFuture<$1.Empty> unlinkOAuthProvider(
    $0.UnlinkOAuthProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlinkOAuthProvider, request, options: options);
  }

  /// List linked OAuth providers for current user
  $grpc.ResponseFuture<$0.ListLinkedProvidersResponse> listLinkedProviders(
    $0.ListLinkedProvidersRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listLinkedProviders, request, options: options);
  }

  /// Start password recovery (always returns success to prevent enumeration)
  /// Also used by OAuth-only users to add a password to their account
  $grpc.ResponseFuture<$1.Empty> recoveryStart(
    $0.RecoveryStartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recoveryStart, request, options: options);
  }

  /// Confirm recovery with token and set new password
  $grpc.ResponseFuture<$1.Empty> recoveryConfirm(
    $0.RecoveryConfirmRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recoveryConfirm, request, options: options);
  }

  /// Change password (requires current password - OWASP requirement)
  /// Use RecoveryStart/Confirm if user forgot password or has no password
  $grpc.ResponseFuture<$1.Empty> changePassword(
    $0.ChangePasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$changePassword, request, options: options);
  }

  /// Request verification code for email or phone
  $grpc.ResponseFuture<$1.Empty> requestVerification(
    $0.RequestVerificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$requestVerification, request, options: options);
  }

  /// Confirm verification with code
  $grpc.ResponseFuture<$1.Empty> confirmVerification(
    $0.ConfirmVerificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmVerification, request, options: options);
  }

  /// Get current MFA status for user
  $grpc.ResponseFuture<$0.GetMfaStatusResponse> getMfaStatus(
    $0.GetMfaStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMfaStatus, request, options: options);
  }

  /// Begin MFA setup (returns secret/challenge based on method)
  $grpc.ResponseFuture<$0.SetupMfaResponse> setupMfa(
    $0.SetupMfaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setupMfa, request, options: options);
  }

  /// Confirm MFA setup with verification code
  $grpc.ResponseFuture<$0.ConfirmMfaSetupResponse> confirmMfaSetup(
    $0.ConfirmMfaSetupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmMfaSetup, request, options: options);
  }

  /// Disable MFA (requires password verification)
  $grpc.ResponseFuture<$1.Empty> disableMfa(
    $0.DisableMfaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disableMfa, request, options: options);
  }

  /// List all active sessions for current user
  $grpc.ResponseFuture<$0.ListSessionsResponse> listSessions(
    $0.ListSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSessions, request, options: options);
  }

  /// Revoke a specific session by device_id
  $grpc.ResponseFuture<$1.Empty> revokeSession(
    $0.RevokeSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeSession, request, options: options);
  }

  /// Revoke all sessions except current
  $grpc.ResponseFuture<$0.RevokeSessionsResponse> revokeOtherSessions(
    $0.RevokeOtherSessionsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeOtherSessions, request, options: options);
  }

  // method descriptors

  static final _$authenticate = $grpc.ClientMethod<$0.AuthenticateRequest, $0.AuthResponse>(
      '/auth.AuthService/Authenticate',
      ($0.AuthenticateRequest value) => value.writeToBuffer(),
      $0.AuthResponse.fromBuffer);
  static final _$refreshTokens = $grpc.ClientMethod<$0.RefreshTokensRequest, $0.TokenPair>(
      '/auth.AuthService/RefreshTokens',
      ($0.RefreshTokensRequest value) => value.writeToBuffer(),
      $0.TokenPair.fromBuffer);
  static final _$validateCredentials =
      $grpc.ClientMethod<$0.ValidateCredentialsRequest, $0.ValidateCredentialsResponse>(
          '/auth.AuthService/ValidateCredentials',
          ($0.ValidateCredentialsRequest value) => value.writeToBuffer(),
          $0.ValidateCredentialsResponse.fromBuffer);
  static final _$signOut = $grpc.ClientMethod<$0.SignOutRequest, $1.Empty>(
      '/auth.AuthService/SignOut', ($0.SignOutRequest value) => value.writeToBuffer(), $1.Empty.fromBuffer);
  static final _$signUp = $grpc.ClientMethod<$0.SignUpRequest, $0.AuthResponse>(
      '/auth.AuthService/SignUp', ($0.SignUpRequest value) => value.writeToBuffer(), $0.AuthResponse.fromBuffer);
  static final _$verifyMfa = $grpc.ClientMethod<$0.VerifyMfaRequest, $0.AuthResponse>(
      '/auth.AuthService/VerifyMfa', ($0.VerifyMfaRequest value) => value.writeToBuffer(), $0.AuthResponse.fromBuffer);
  static final _$getOAuthUrl = $grpc.ClientMethod<$0.GetOAuthUrlRequest, $0.GetOAuthUrlResponse>(
      '/auth.AuthService/GetOAuthUrl',
      ($0.GetOAuthUrlRequest value) => value.writeToBuffer(),
      $0.GetOAuthUrlResponse.fromBuffer);
  static final _$exchangeOAuthCode = $grpc.ClientMethod<$0.ExchangeOAuthCodeRequest, $0.AuthResponse>(
      '/auth.AuthService/ExchangeOAuthCode',
      ($0.ExchangeOAuthCodeRequest value) => value.writeToBuffer(),
      $0.AuthResponse.fromBuffer);
  static final _$linkOAuthProvider = $grpc.ClientMethod<$0.LinkOAuthProviderRequest, $1.Empty>(
      '/auth.AuthService/LinkOAuthProvider',
      ($0.LinkOAuthProviderRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$unlinkOAuthProvider = $grpc.ClientMethod<$0.UnlinkOAuthProviderRequest, $1.Empty>(
      '/auth.AuthService/UnlinkOAuthProvider',
      ($0.UnlinkOAuthProviderRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$listLinkedProviders =
      $grpc.ClientMethod<$0.ListLinkedProvidersRequest, $0.ListLinkedProvidersResponse>(
          '/auth.AuthService/ListLinkedProviders',
          ($0.ListLinkedProvidersRequest value) => value.writeToBuffer(),
          $0.ListLinkedProvidersResponse.fromBuffer);
  static final _$recoveryStart = $grpc.ClientMethod<$0.RecoveryStartRequest, $1.Empty>(
      '/auth.AuthService/RecoveryStart', ($0.RecoveryStartRequest value) => value.writeToBuffer(), $1.Empty.fromBuffer);
  static final _$recoveryConfirm = $grpc.ClientMethod<$0.RecoveryConfirmRequest, $1.Empty>(
      '/auth.AuthService/RecoveryConfirm',
      ($0.RecoveryConfirmRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$changePassword = $grpc.ClientMethod<$0.ChangePasswordRequest, $1.Empty>(
      '/auth.AuthService/ChangePassword',
      ($0.ChangePasswordRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$requestVerification = $grpc.ClientMethod<$0.RequestVerificationRequest, $1.Empty>(
      '/auth.AuthService/RequestVerification',
      ($0.RequestVerificationRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$confirmVerification = $grpc.ClientMethod<$0.ConfirmVerificationRequest, $1.Empty>(
      '/auth.AuthService/ConfirmVerification',
      ($0.ConfirmVerificationRequest value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getMfaStatus = $grpc.ClientMethod<$0.GetMfaStatusRequest, $0.GetMfaStatusResponse>(
      '/auth.AuthService/GetMfaStatus',
      ($0.GetMfaStatusRequest value) => value.writeToBuffer(),
      $0.GetMfaStatusResponse.fromBuffer);
  static final _$setupMfa = $grpc.ClientMethod<$0.SetupMfaRequest, $0.SetupMfaResponse>('/auth.AuthService/SetupMfa',
      ($0.SetupMfaRequest value) => value.writeToBuffer(), $0.SetupMfaResponse.fromBuffer);
  static final _$confirmMfaSetup = $grpc.ClientMethod<$0.ConfirmMfaSetupRequest, $0.ConfirmMfaSetupResponse>(
      '/auth.AuthService/ConfirmMfaSetup',
      ($0.ConfirmMfaSetupRequest value) => value.writeToBuffer(),
      $0.ConfirmMfaSetupResponse.fromBuffer);
  static final _$disableMfa = $grpc.ClientMethod<$0.DisableMfaRequest, $1.Empty>(
      '/auth.AuthService/DisableMfa', ($0.DisableMfaRequest value) => value.writeToBuffer(), $1.Empty.fromBuffer);
  static final _$listSessions = $grpc.ClientMethod<$0.ListSessionsRequest, $0.ListSessionsResponse>(
      '/auth.AuthService/ListSessions',
      ($0.ListSessionsRequest value) => value.writeToBuffer(),
      $0.ListSessionsResponse.fromBuffer);
  static final _$revokeSession = $grpc.ClientMethod<$0.RevokeSessionRequest, $1.Empty>(
      '/auth.AuthService/RevokeSession', ($0.RevokeSessionRequest value) => value.writeToBuffer(), $1.Empty.fromBuffer);
  static final _$revokeOtherSessions = $grpc.ClientMethod<$0.RevokeOtherSessionsRequest, $0.RevokeSessionsResponse>(
      '/auth.AuthService/RevokeOtherSessions',
      ($0.RevokeOtherSessionsRequest value) => value.writeToBuffer(),
      $0.RevokeSessionsResponse.fromBuffer);
}

@$pb.GrpcServiceName('auth.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'auth.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuthenticateRequest, $0.AuthResponse>(
        'Authenticate',
        authenticate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthenticateRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshTokensRequest, $0.TokenPair>(
        'RefreshTokens',
        refreshTokens_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshTokensRequest.fromBuffer(value),
        ($0.TokenPair value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ValidateCredentialsRequest, $0.ValidateCredentialsResponse>(
        'ValidateCredentials',
        validateCredentials_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ValidateCredentialsRequest.fromBuffer(value),
        ($0.ValidateCredentialsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SignOutRequest, $1.Empty>(
        'SignOut',
        signOut_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SignOutRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SignUpRequest, $0.AuthResponse>(
        'SignUp',
        signUp_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SignUpRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VerifyMfaRequest, $0.AuthResponse>(
        'VerifyMfa',
        verifyMfa_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.VerifyMfaRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetOAuthUrlRequest, $0.GetOAuthUrlResponse>(
        'GetOAuthUrl',
        getOAuthUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetOAuthUrlRequest.fromBuffer(value),
        ($0.GetOAuthUrlResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExchangeOAuthCodeRequest, $0.AuthResponse>(
        'ExchangeOAuthCode',
        exchangeOAuthCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExchangeOAuthCodeRequest.fromBuffer(value),
        ($0.AuthResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LinkOAuthProviderRequest, $1.Empty>(
        'LinkOAuthProvider',
        linkOAuthProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LinkOAuthProviderRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnlinkOAuthProviderRequest, $1.Empty>(
        'UnlinkOAuthProvider',
        unlinkOAuthProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnlinkOAuthProviderRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListLinkedProvidersRequest, $0.ListLinkedProvidersResponse>(
        'ListLinkedProviders',
        listLinkedProviders_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListLinkedProvidersRequest.fromBuffer(value),
        ($0.ListLinkedProvidersResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecoveryStartRequest, $1.Empty>(
        'RecoveryStart',
        recoveryStart_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RecoveryStartRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecoveryConfirmRequest, $1.Empty>(
        'RecoveryConfirm',
        recoveryConfirm_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RecoveryConfirmRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePasswordRequest, $1.Empty>(
        'ChangePassword',
        changePassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangePasswordRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RequestVerificationRequest, $1.Empty>(
        'RequestVerification',
        requestVerification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RequestVerificationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmVerificationRequest, $1.Empty>(
        'ConfirmVerification',
        confirmVerification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmVerificationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetMfaStatusRequest, $0.GetMfaStatusResponse>(
        'GetMfaStatus',
        getMfaStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetMfaStatusRequest.fromBuffer(value),
        ($0.GetMfaStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetupMfaRequest, $0.SetupMfaResponse>(
        'SetupMfa',
        setupMfa_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetupMfaRequest.fromBuffer(value),
        ($0.SetupMfaResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmMfaSetupRequest, $0.ConfirmMfaSetupResponse>(
        'ConfirmMfaSetup',
        confirmMfaSetup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmMfaSetupRequest.fromBuffer(value),
        ($0.ConfirmMfaSetupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DisableMfaRequest, $1.Empty>(
        'DisableMfa',
        disableMfa_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DisableMfaRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListSessionsRequest, $0.ListSessionsResponse>(
        'ListSessions',
        listSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListSessionsRequest.fromBuffer(value),
        ($0.ListSessionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeSessionRequest, $1.Empty>(
        'RevokeSession',
        revokeSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RevokeSessionRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeOtherSessionsRequest, $0.RevokeSessionsResponse>(
        'RevokeOtherSessions',
        revokeOtherSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RevokeOtherSessionsRequest.fromBuffer(value),
        ($0.RevokeSessionsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthResponse> authenticate_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.AuthenticateRequest> $request) async {
    return authenticate($call, await $request);
  }

  $async.Future<$0.AuthResponse> authenticate($grpc.ServiceCall call, $0.AuthenticateRequest request);

  $async.Future<$0.TokenPair> refreshTokens_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RefreshTokensRequest> $request) async {
    return refreshTokens($call, await $request);
  }

  $async.Future<$0.TokenPair> refreshTokens($grpc.ServiceCall call, $0.RefreshTokensRequest request);

  $async.Future<$0.ValidateCredentialsResponse> validateCredentials_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ValidateCredentialsRequest> $request) async {
    return validateCredentials($call, await $request);
  }

  $async.Future<$0.ValidateCredentialsResponse> validateCredentials(
      $grpc.ServiceCall call, $0.ValidateCredentialsRequest request);

  $async.Future<$1.Empty> signOut_Pre($grpc.ServiceCall $call, $async.Future<$0.SignOutRequest> $request) async {
    return signOut($call, await $request);
  }

  $async.Future<$1.Empty> signOut($grpc.ServiceCall call, $0.SignOutRequest request);

  $async.Future<$0.AuthResponse> signUp_Pre($grpc.ServiceCall $call, $async.Future<$0.SignUpRequest> $request) async {
    return signUp($call, await $request);
  }

  $async.Future<$0.AuthResponse> signUp($grpc.ServiceCall call, $0.SignUpRequest request);

  $async.Future<$0.AuthResponse> verifyMfa_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.VerifyMfaRequest> $request) async {
    return verifyMfa($call, await $request);
  }

  $async.Future<$0.AuthResponse> verifyMfa($grpc.ServiceCall call, $0.VerifyMfaRequest request);

  $async.Future<$0.GetOAuthUrlResponse> getOAuthUrl_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GetOAuthUrlRequest> $request) async {
    return getOAuthUrl($call, await $request);
  }

  $async.Future<$0.GetOAuthUrlResponse> getOAuthUrl($grpc.ServiceCall call, $0.GetOAuthUrlRequest request);

  $async.Future<$0.AuthResponse> exchangeOAuthCode_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ExchangeOAuthCodeRequest> $request) async {
    return exchangeOAuthCode($call, await $request);
  }

  $async.Future<$0.AuthResponse> exchangeOAuthCode($grpc.ServiceCall call, $0.ExchangeOAuthCodeRequest request);

  $async.Future<$1.Empty> linkOAuthProvider_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LinkOAuthProviderRequest> $request) async {
    return linkOAuthProvider($call, await $request);
  }

  $async.Future<$1.Empty> linkOAuthProvider($grpc.ServiceCall call, $0.LinkOAuthProviderRequest request);

  $async.Future<$1.Empty> unlinkOAuthProvider_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UnlinkOAuthProviderRequest> $request) async {
    return unlinkOAuthProvider($call, await $request);
  }

  $async.Future<$1.Empty> unlinkOAuthProvider($grpc.ServiceCall call, $0.UnlinkOAuthProviderRequest request);

  $async.Future<$0.ListLinkedProvidersResponse> listLinkedProviders_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ListLinkedProvidersRequest> $request) async {
    return listLinkedProviders($call, await $request);
  }

  $async.Future<$0.ListLinkedProvidersResponse> listLinkedProviders(
      $grpc.ServiceCall call, $0.ListLinkedProvidersRequest request);

  $async.Future<$1.Empty> recoveryStart_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RecoveryStartRequest> $request) async {
    return recoveryStart($call, await $request);
  }

  $async.Future<$1.Empty> recoveryStart($grpc.ServiceCall call, $0.RecoveryStartRequest request);

  $async.Future<$1.Empty> recoveryConfirm_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RecoveryConfirmRequest> $request) async {
    return recoveryConfirm($call, await $request);
  }

  $async.Future<$1.Empty> recoveryConfirm($grpc.ServiceCall call, $0.RecoveryConfirmRequest request);

  $async.Future<$1.Empty> changePassword_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ChangePasswordRequest> $request) async {
    return changePassword($call, await $request);
  }

  $async.Future<$1.Empty> changePassword($grpc.ServiceCall call, $0.ChangePasswordRequest request);

  $async.Future<$1.Empty> requestVerification_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RequestVerificationRequest> $request) async {
    return requestVerification($call, await $request);
  }

  $async.Future<$1.Empty> requestVerification($grpc.ServiceCall call, $0.RequestVerificationRequest request);

  $async.Future<$1.Empty> confirmVerification_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmVerificationRequest> $request) async {
    return confirmVerification($call, await $request);
  }

  $async.Future<$1.Empty> confirmVerification($grpc.ServiceCall call, $0.ConfirmVerificationRequest request);

  $async.Future<$0.GetMfaStatusResponse> getMfaStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GetMfaStatusRequest> $request) async {
    return getMfaStatus($call, await $request);
  }

  $async.Future<$0.GetMfaStatusResponse> getMfaStatus($grpc.ServiceCall call, $0.GetMfaStatusRequest request);

  $async.Future<$0.SetupMfaResponse> setupMfa_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetupMfaRequest> $request) async {
    return setupMfa($call, await $request);
  }

  $async.Future<$0.SetupMfaResponse> setupMfa($grpc.ServiceCall call, $0.SetupMfaRequest request);

  $async.Future<$0.ConfirmMfaSetupResponse> confirmMfaSetup_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmMfaSetupRequest> $request) async {
    return confirmMfaSetup($call, await $request);
  }

  $async.Future<$0.ConfirmMfaSetupResponse> confirmMfaSetup($grpc.ServiceCall call, $0.ConfirmMfaSetupRequest request);

  $async.Future<$1.Empty> disableMfa_Pre($grpc.ServiceCall $call, $async.Future<$0.DisableMfaRequest> $request) async {
    return disableMfa($call, await $request);
  }

  $async.Future<$1.Empty> disableMfa($grpc.ServiceCall call, $0.DisableMfaRequest request);

  $async.Future<$0.ListSessionsResponse> listSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ListSessionsRequest> $request) async {
    return listSessions($call, await $request);
  }

  $async.Future<$0.ListSessionsResponse> listSessions($grpc.ServiceCall call, $0.ListSessionsRequest request);

  $async.Future<$1.Empty> revokeSession_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RevokeSessionRequest> $request) async {
    return revokeSession($call, await $request);
  }

  $async.Future<$1.Empty> revokeSession($grpc.ServiceCall call, $0.RevokeSessionRequest request);

  $async.Future<$0.RevokeSessionsResponse> revokeOtherSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RevokeOtherSessionsRequest> $request) async {
    return revokeOtherSessions($call, await $request);
  }

  $async.Future<$0.RevokeSessionsResponse> revokeOtherSessions(
      $grpc.ServiceCall call, $0.RevokeOtherSessionsRequest request);
}
