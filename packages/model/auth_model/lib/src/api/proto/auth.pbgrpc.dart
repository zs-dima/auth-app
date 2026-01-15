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
import 'core.pb.dart' as $2;

export 'auth.pb.dart';

/// =============================================================================
/// Auth Service - Modern Authentication API
/// =============================================================================
/// Design principles: SIMPLE, RELIABLE, EXPANDABLE
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
/// - WebAuthn/Passkeys: Add MFA_METHOD_PASSKEY
/// - Magic links: Add RequestMagicLink RPC
/// - Trusted devices: Skip MFA on known devices
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
  $grpc.ResponseFuture<$0.AuthResult> authenticate(
    $0.AuthenticateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$authenticate, request, options: options);
  }

  /// Refresh access token using refresh token
  $grpc.ResponseFuture<$0.RefreshTokenReply> refreshTokens(
    $0.RefreshTokenRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$refreshTokens, request, options: options);
  }

  /// Validate current session/credentials
  $grpc.ResponseFuture<$2.ResultReply> validateCredentials(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$validateCredentials, request, options: options);
  }

  /// Sign out and invalidate current session
  $grpc.ResponseFuture<$2.ResultReply> signOut(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$signOut, request, options: options);
  }

  /// Register a new account
  /// Returns AUTH_STATUS_SUCCESS with tokens, or AUTH_STATUS_PENDING if verification required
  $grpc.ResponseFuture<$0.AuthResult> signUp(
    $0.SignUpRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$signUp, request, options: options);
  }

  /// Complete MFA verification (when Authenticate returns MFA_REQUIRED)
  $grpc.ResponseFuture<$0.AuthResult> verifyMfa(
    $0.VerifyMfaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$verifyMfa, request, options: options);
  }

  /// Get OAuth authorization URL with PKCE state
  $grpc.ResponseFuture<$0.OAuthUrlReply> getOAuthUrl(
    $0.GetOAuthUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getOAuthUrl, request, options: options);
  }

  /// Exchange OAuth callback code for tokens (login or register)
  $grpc.ResponseFuture<$0.AuthResult> exchangeOAuthCode(
    $0.ExchangeOAuthCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exchangeOAuthCode, request, options: options);
  }

  /// Link OAuth provider to existing authenticated account
  $grpc.ResponseFuture<$2.ResultReply> linkOAuthProvider(
    $0.LinkOAuthProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$linkOAuthProvider, request, options: options);
  }

  /// Unlink OAuth provider from account
  $grpc.ResponseFuture<$2.ResultReply> unlinkOAuthProvider(
    $0.UnlinkOAuthProviderRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$unlinkOAuthProvider, request, options: options);
  }

  /// List linked OAuth providers for current user
  $grpc.ResponseFuture<$0.LinkedProvidersReply> listLinkedProviders(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listLinkedProviders, request, options: options);
  }

  /// Start password recovery (always returns success to prevent enumeration)
  /// Also used by OAuth-only users to add a password to their account
  $grpc.ResponseFuture<$2.ResultReply> recoveryStart(
    $0.RecoveryStartRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recoveryStart, request, options: options);
  }

  /// Confirm recovery with token and set new password
  $grpc.ResponseFuture<$2.ResultReply> recoveryConfirm(
    $0.RecoveryConfirmRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$recoveryConfirm, request, options: options);
  }

  /// Change password (requires current password - OWASP requirement)
  /// Use RecoveryStart/Confirm if user forgot password or has no password
  $grpc.ResponseFuture<$2.ResultReply> changePassword(
    $0.ChangePasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$changePassword, request, options: options);
  }

  /// Set password (admin only - bypasses current password requirement)
  $grpc.ResponseFuture<$2.ResultReply> setPassword(
    $0.SetPasswordRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPassword, request, options: options);
  }

  /// Request verification code for email or phone
  $grpc.ResponseFuture<$2.ResultReply> requestVerification(
    $0.RequestVerificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$requestVerification, request, options: options);
  }

  /// Confirm verification with code
  $grpc.ResponseFuture<$2.ResultReply> confirmVerification(
    $0.ConfirmVerificationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmVerification, request, options: options);
  }

  /// Get current MFA status for user
  $grpc.ResponseFuture<$0.MfaStatusReply> getMfaStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMfaStatus, request, options: options);
  }

  /// Begin MFA setup (returns secret/challenge based on method)
  $grpc.ResponseFuture<$0.SetupMfaReply> setupMfa(
    $0.SetupMfaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setupMfa, request, options: options);
  }

  /// Confirm MFA setup with verification code
  $grpc.ResponseFuture<$0.MfaSetupResult> confirmMfaSetup(
    $0.ConfirmMfaSetupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmMfaSetup, request, options: options);
  }

  /// Disable MFA (requires password verification)
  $grpc.ResponseFuture<$2.ResultReply> disableMfa(
    $0.DisableMfaRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disableMfa, request, options: options);
  }

  /// List all active sessions for current user
  $grpc.ResponseFuture<$0.ListSessionsReply> listSessions(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$listSessions, request, options: options);
  }

  /// Revoke a specific session by device_id
  $grpc.ResponseFuture<$2.ResultReply> revokeSession(
    $0.RevokeSessionRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeSession, request, options: options);
  }

  /// Revoke all sessions except current
  $grpc.ResponseFuture<$0.RevokeSessionsReply> revokeOtherSessions(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$revokeOtherSessions, request, options: options);
  }

  /// Load user info (streaming)
  $grpc.ResponseStream<$0.UserInfo> loadUsersInfo(
    $0.LoadUsersInfoRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$loadUsersInfo, $async.Stream.fromIterable([request]), options: options);
  }

  /// Load users (streaming)
  $grpc.ResponseStream<$0.User> loadUsers(
    $0.UserId request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(_$loadUsers, $async.Stream.fromIterable([request]), options: options);
  }

  /// Create a new user
  $grpc.ResponseFuture<$2.ResultReply> createUser(
    $0.CreateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$createUser, request, options: options);
  }

  /// Update user
  $grpc.ResponseFuture<$2.ResultReply> updateUser(
    $0.UpdateUserRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateUser, request, options: options);
  }

  /// Get presigned URL for avatar upload
  $grpc.ResponseFuture<$0.AvatarUploadUrl> getAvatarUploadUrl(
    $0.GetAvatarUploadUrlRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAvatarUploadUrl, request, options: options);
  }

  /// Confirm avatar upload completed
  $grpc.ResponseFuture<$2.ResultReply> confirmAvatarUpload(
    $0.ConfirmAvatarUploadRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$confirmAvatarUpload, request, options: options);
  }

  /// Delete user avatar
  $grpc.ResponseFuture<$2.ResultReply> deleteUserAvatar(
    $0.UserId request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$deleteUserAvatar, request, options: options);
  }

  // method descriptors

  static final _$authenticate = $grpc.ClientMethod<$0.AuthenticateRequest, $0.AuthResult>(
      '/auth.AuthService/Authenticate',
      ($0.AuthenticateRequest value) => value.writeToBuffer(),
      $0.AuthResult.fromBuffer);
  static final _$refreshTokens = $grpc.ClientMethod<$0.RefreshTokenRequest, $0.RefreshTokenReply>(
      '/auth.AuthService/RefreshTokens',
      ($0.RefreshTokenRequest value) => value.writeToBuffer(),
      $0.RefreshTokenReply.fromBuffer);
  static final _$validateCredentials = $grpc.ClientMethod<$1.Empty, $2.ResultReply>(
      '/auth.AuthService/ValidateCredentials', ($1.Empty value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$signOut = $grpc.ClientMethod<$1.Empty, $2.ResultReply>(
      '/auth.AuthService/SignOut', ($1.Empty value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$signUp = $grpc.ClientMethod<$0.SignUpRequest, $0.AuthResult>(
      '/auth.AuthService/SignUp', ($0.SignUpRequest value) => value.writeToBuffer(), $0.AuthResult.fromBuffer);
  static final _$verifyMfa = $grpc.ClientMethod<$0.VerifyMfaRequest, $0.AuthResult>(
      '/auth.AuthService/VerifyMfa', ($0.VerifyMfaRequest value) => value.writeToBuffer(), $0.AuthResult.fromBuffer);
  static final _$getOAuthUrl = $grpc.ClientMethod<$0.GetOAuthUrlRequest, $0.OAuthUrlReply>(
      '/auth.AuthService/GetOAuthUrl',
      ($0.GetOAuthUrlRequest value) => value.writeToBuffer(),
      $0.OAuthUrlReply.fromBuffer);
  static final _$exchangeOAuthCode = $grpc.ClientMethod<$0.ExchangeOAuthCodeRequest, $0.AuthResult>(
      '/auth.AuthService/ExchangeOAuthCode',
      ($0.ExchangeOAuthCodeRequest value) => value.writeToBuffer(),
      $0.AuthResult.fromBuffer);
  static final _$linkOAuthProvider = $grpc.ClientMethod<$0.LinkOAuthProviderRequest, $2.ResultReply>(
      '/auth.AuthService/LinkOAuthProvider',
      ($0.LinkOAuthProviderRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$unlinkOAuthProvider = $grpc.ClientMethod<$0.UnlinkOAuthProviderRequest, $2.ResultReply>(
      '/auth.AuthService/UnlinkOAuthProvider',
      ($0.UnlinkOAuthProviderRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$listLinkedProviders = $grpc.ClientMethod<$1.Empty, $0.LinkedProvidersReply>(
      '/auth.AuthService/ListLinkedProviders',
      ($1.Empty value) => value.writeToBuffer(),
      $0.LinkedProvidersReply.fromBuffer);
  static final _$recoveryStart = $grpc.ClientMethod<$0.RecoveryStartRequest, $2.ResultReply>(
      '/auth.AuthService/RecoveryStart',
      ($0.RecoveryStartRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$recoveryConfirm = $grpc.ClientMethod<$0.RecoveryConfirmRequest, $2.ResultReply>(
      '/auth.AuthService/RecoveryConfirm',
      ($0.RecoveryConfirmRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$changePassword = $grpc.ClientMethod<$0.ChangePasswordRequest, $2.ResultReply>(
      '/auth.AuthService/ChangePassword',
      ($0.ChangePasswordRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$setPassword = $grpc.ClientMethod<$0.SetPasswordRequest, $2.ResultReply>(
      '/auth.AuthService/SetPassword',
      ($0.SetPasswordRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$requestVerification = $grpc.ClientMethod<$0.RequestVerificationRequest, $2.ResultReply>(
      '/auth.AuthService/RequestVerification',
      ($0.RequestVerificationRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$confirmVerification = $grpc.ClientMethod<$0.ConfirmVerificationRequest, $2.ResultReply>(
      '/auth.AuthService/ConfirmVerification',
      ($0.ConfirmVerificationRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$getMfaStatus = $grpc.ClientMethod<$1.Empty, $0.MfaStatusReply>(
      '/auth.AuthService/GetMfaStatus', ($1.Empty value) => value.writeToBuffer(), $0.MfaStatusReply.fromBuffer);
  static final _$setupMfa = $grpc.ClientMethod<$0.SetupMfaRequest, $0.SetupMfaReply>(
      '/auth.AuthService/SetupMfa', ($0.SetupMfaRequest value) => value.writeToBuffer(), $0.SetupMfaReply.fromBuffer);
  static final _$confirmMfaSetup = $grpc.ClientMethod<$0.ConfirmMfaSetupRequest, $0.MfaSetupResult>(
      '/auth.AuthService/ConfirmMfaSetup',
      ($0.ConfirmMfaSetupRequest value) => value.writeToBuffer(),
      $0.MfaSetupResult.fromBuffer);
  static final _$disableMfa = $grpc.ClientMethod<$0.DisableMfaRequest, $2.ResultReply>(
      '/auth.AuthService/DisableMfa', ($0.DisableMfaRequest value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$listSessions = $grpc.ClientMethod<$1.Empty, $0.ListSessionsReply>(
      '/auth.AuthService/ListSessions', ($1.Empty value) => value.writeToBuffer(), $0.ListSessionsReply.fromBuffer);
  static final _$revokeSession = $grpc.ClientMethod<$0.RevokeSessionRequest, $2.ResultReply>(
      '/auth.AuthService/RevokeSession',
      ($0.RevokeSessionRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$revokeOtherSessions = $grpc.ClientMethod<$1.Empty, $0.RevokeSessionsReply>(
      '/auth.AuthService/RevokeOtherSessions',
      ($1.Empty value) => value.writeToBuffer(),
      $0.RevokeSessionsReply.fromBuffer);
  static final _$loadUsersInfo = $grpc.ClientMethod<$0.LoadUsersInfoRequest, $0.UserInfo>(
      '/auth.AuthService/LoadUsersInfo',
      ($0.LoadUsersInfoRequest value) => value.writeToBuffer(),
      $0.UserInfo.fromBuffer);
  static final _$loadUsers = $grpc.ClientMethod<$0.UserId, $0.User>(
      '/auth.AuthService/LoadUsers', ($0.UserId value) => value.writeToBuffer(), $0.User.fromBuffer);
  static final _$createUser = $grpc.ClientMethod<$0.CreateUserRequest, $2.ResultReply>(
      '/auth.AuthService/CreateUser', ($0.CreateUserRequest value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$updateUser = $grpc.ClientMethod<$0.UpdateUserRequest, $2.ResultReply>(
      '/auth.AuthService/UpdateUser', ($0.UpdateUserRequest value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
  static final _$getAvatarUploadUrl = $grpc.ClientMethod<$0.GetAvatarUploadUrlRequest, $0.AvatarUploadUrl>(
      '/auth.AuthService/GetAvatarUploadUrl',
      ($0.GetAvatarUploadUrlRequest value) => value.writeToBuffer(),
      $0.AvatarUploadUrl.fromBuffer);
  static final _$confirmAvatarUpload = $grpc.ClientMethod<$0.ConfirmAvatarUploadRequest, $2.ResultReply>(
      '/auth.AuthService/ConfirmAvatarUpload',
      ($0.ConfirmAvatarUploadRequest value) => value.writeToBuffer(),
      $2.ResultReply.fromBuffer);
  static final _$deleteUserAvatar = $grpc.ClientMethod<$0.UserId, $2.ResultReply>(
      '/auth.AuthService/DeleteUserAvatar', ($0.UserId value) => value.writeToBuffer(), $2.ResultReply.fromBuffer);
}

@$pb.GrpcServiceName('auth.AuthService')
abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'auth.AuthService';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.AuthenticateRequest, $0.AuthResult>(
        'Authenticate',
        authenticate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.AuthenticateRequest.fromBuffer(value),
        ($0.AuthResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RefreshTokenRequest, $0.RefreshTokenReply>(
        'RefreshTokens',
        refreshTokens_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RefreshTokenRequest.fromBuffer(value),
        ($0.RefreshTokenReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.ResultReply>(
        'ValidateCredentials',
        validateCredentials_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $2.ResultReply>('SignOut', signOut_Pre, false, false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value), ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SignUpRequest, $0.AuthResult>(
        'SignUp',
        signUp_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SignUpRequest.fromBuffer(value),
        ($0.AuthResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VerifyMfaRequest, $0.AuthResult>(
        'VerifyMfa',
        verifyMfa_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.VerifyMfaRequest.fromBuffer(value),
        ($0.AuthResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetOAuthUrlRequest, $0.OAuthUrlReply>(
        'GetOAuthUrl',
        getOAuthUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetOAuthUrlRequest.fromBuffer(value),
        ($0.OAuthUrlReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExchangeOAuthCodeRequest, $0.AuthResult>(
        'ExchangeOAuthCode',
        exchangeOAuthCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExchangeOAuthCodeRequest.fromBuffer(value),
        ($0.AuthResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LinkOAuthProviderRequest, $2.ResultReply>(
        'LinkOAuthProvider',
        linkOAuthProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.LinkOAuthProviderRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnlinkOAuthProviderRequest, $2.ResultReply>(
        'UnlinkOAuthProvider',
        unlinkOAuthProvider_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnlinkOAuthProviderRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.LinkedProvidersReply>(
        'ListLinkedProviders',
        listLinkedProviders_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.LinkedProvidersReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecoveryStartRequest, $2.ResultReply>(
        'RecoveryStart',
        recoveryStart_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RecoveryStartRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RecoveryConfirmRequest, $2.ResultReply>(
        'RecoveryConfirm',
        recoveryConfirm_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RecoveryConfirmRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ChangePasswordRequest, $2.ResultReply>(
        'ChangePassword',
        changePassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChangePasswordRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetPasswordRequest, $2.ResultReply>(
        'SetPassword',
        setPassword_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetPasswordRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RequestVerificationRequest, $2.ResultReply>(
        'RequestVerification',
        requestVerification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RequestVerificationRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmVerificationRequest, $2.ResultReply>(
        'ConfirmVerification',
        confirmVerification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmVerificationRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.MfaStatusReply>(
        'GetMfaStatus',
        getMfaStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.MfaStatusReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetupMfaRequest, $0.SetupMfaReply>(
        'SetupMfa',
        setupMfa_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetupMfaRequest.fromBuffer(value),
        ($0.SetupMfaReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmMfaSetupRequest, $0.MfaSetupResult>(
        'ConfirmMfaSetup',
        confirmMfaSetup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmMfaSetupRequest.fromBuffer(value),
        ($0.MfaSetupResult value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DisableMfaRequest, $2.ResultReply>(
        'DisableMfa',
        disableMfa_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DisableMfaRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ListSessionsReply>(
        'ListSessions',
        listSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ListSessionsReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.RevokeSessionRequest, $2.ResultReply>(
        'RevokeSession',
        revokeSession_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.RevokeSessionRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.RevokeSessionsReply>(
        'RevokeOtherSessions',
        revokeOtherSessions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.RevokeSessionsReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoadUsersInfoRequest, $0.UserInfo>(
        'LoadUsersInfo',
        loadUsersInfo_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.LoadUsersInfoRequest.fromBuffer(value),
        ($0.UserInfo value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserId, $0.User>('LoadUsers', loadUsers_Pre, false, true,
        ($core.List<$core.int> value) => $0.UserId.fromBuffer(value), ($0.User value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateUserRequest, $2.ResultReply>(
        'CreateUser',
        createUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.CreateUserRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateUserRequest, $2.ResultReply>(
        'UpdateUser',
        updateUser_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UpdateUserRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAvatarUploadUrlRequest, $0.AvatarUploadUrl>(
        'GetAvatarUploadUrl',
        getAvatarUploadUrl_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetAvatarUploadUrlRequest.fromBuffer(value),
        ($0.AvatarUploadUrl value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ConfirmAvatarUploadRequest, $2.ResultReply>(
        'ConfirmAvatarUpload',
        confirmAvatarUpload_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ConfirmAvatarUploadRequest.fromBuffer(value),
        ($2.ResultReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UserId, $2.ResultReply>('DeleteUserAvatar', deleteUserAvatar_Pre, false, false,
        ($core.List<$core.int> value) => $0.UserId.fromBuffer(value), ($2.ResultReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.AuthResult> authenticate_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.AuthenticateRequest> $request) async {
    return authenticate($call, await $request);
  }

  $async.Future<$0.AuthResult> authenticate($grpc.ServiceCall call, $0.AuthenticateRequest request);

  $async.Future<$0.RefreshTokenReply> refreshTokens_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RefreshTokenRequest> $request) async {
    return refreshTokens($call, await $request);
  }

  $async.Future<$0.RefreshTokenReply> refreshTokens($grpc.ServiceCall call, $0.RefreshTokenRequest request);

  $async.Future<$2.ResultReply> validateCredentials_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return validateCredentials($call, await $request);
  }

  $async.Future<$2.ResultReply> validateCredentials($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$2.ResultReply> signOut_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return signOut($call, await $request);
  }

  $async.Future<$2.ResultReply> signOut($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.AuthResult> signUp_Pre($grpc.ServiceCall $call, $async.Future<$0.SignUpRequest> $request) async {
    return signUp($call, await $request);
  }

  $async.Future<$0.AuthResult> signUp($grpc.ServiceCall call, $0.SignUpRequest request);

  $async.Future<$0.AuthResult> verifyMfa_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.VerifyMfaRequest> $request) async {
    return verifyMfa($call, await $request);
  }

  $async.Future<$0.AuthResult> verifyMfa($grpc.ServiceCall call, $0.VerifyMfaRequest request);

  $async.Future<$0.OAuthUrlReply> getOAuthUrl_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GetOAuthUrlRequest> $request) async {
    return getOAuthUrl($call, await $request);
  }

  $async.Future<$0.OAuthUrlReply> getOAuthUrl($grpc.ServiceCall call, $0.GetOAuthUrlRequest request);

  $async.Future<$0.AuthResult> exchangeOAuthCode_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ExchangeOAuthCodeRequest> $request) async {
    return exchangeOAuthCode($call, await $request);
  }

  $async.Future<$0.AuthResult> exchangeOAuthCode($grpc.ServiceCall call, $0.ExchangeOAuthCodeRequest request);

  $async.Future<$2.ResultReply> linkOAuthProvider_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LinkOAuthProviderRequest> $request) async {
    return linkOAuthProvider($call, await $request);
  }

  $async.Future<$2.ResultReply> linkOAuthProvider($grpc.ServiceCall call, $0.LinkOAuthProviderRequest request);

  $async.Future<$2.ResultReply> unlinkOAuthProvider_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UnlinkOAuthProviderRequest> $request) async {
    return unlinkOAuthProvider($call, await $request);
  }

  $async.Future<$2.ResultReply> unlinkOAuthProvider($grpc.ServiceCall call, $0.UnlinkOAuthProviderRequest request);

  $async.Future<$0.LinkedProvidersReply> listLinkedProviders_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listLinkedProviders($call, await $request);
  }

  $async.Future<$0.LinkedProvidersReply> listLinkedProviders($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$2.ResultReply> recoveryStart_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RecoveryStartRequest> $request) async {
    return recoveryStart($call, await $request);
  }

  $async.Future<$2.ResultReply> recoveryStart($grpc.ServiceCall call, $0.RecoveryStartRequest request);

  $async.Future<$2.ResultReply> recoveryConfirm_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RecoveryConfirmRequest> $request) async {
    return recoveryConfirm($call, await $request);
  }

  $async.Future<$2.ResultReply> recoveryConfirm($grpc.ServiceCall call, $0.RecoveryConfirmRequest request);

  $async.Future<$2.ResultReply> changePassword_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ChangePasswordRequest> $request) async {
    return changePassword($call, await $request);
  }

  $async.Future<$2.ResultReply> changePassword($grpc.ServiceCall call, $0.ChangePasswordRequest request);

  $async.Future<$2.ResultReply> setPassword_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetPasswordRequest> $request) async {
    return setPassword($call, await $request);
  }

  $async.Future<$2.ResultReply> setPassword($grpc.ServiceCall call, $0.SetPasswordRequest request);

  $async.Future<$2.ResultReply> requestVerification_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RequestVerificationRequest> $request) async {
    return requestVerification($call, await $request);
  }

  $async.Future<$2.ResultReply> requestVerification($grpc.ServiceCall call, $0.RequestVerificationRequest request);

  $async.Future<$2.ResultReply> confirmVerification_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmVerificationRequest> $request) async {
    return confirmVerification($call, await $request);
  }

  $async.Future<$2.ResultReply> confirmVerification($grpc.ServiceCall call, $0.ConfirmVerificationRequest request);

  $async.Future<$0.MfaStatusReply> getMfaStatus_Pre($grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getMfaStatus($call, await $request);
  }

  $async.Future<$0.MfaStatusReply> getMfaStatus($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.SetupMfaReply> setupMfa_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetupMfaRequest> $request) async {
    return setupMfa($call, await $request);
  }

  $async.Future<$0.SetupMfaReply> setupMfa($grpc.ServiceCall call, $0.SetupMfaRequest request);

  $async.Future<$0.MfaSetupResult> confirmMfaSetup_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmMfaSetupRequest> $request) async {
    return confirmMfaSetup($call, await $request);
  }

  $async.Future<$0.MfaSetupResult> confirmMfaSetup($grpc.ServiceCall call, $0.ConfirmMfaSetupRequest request);

  $async.Future<$2.ResultReply> disableMfa_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.DisableMfaRequest> $request) async {
    return disableMfa($call, await $request);
  }

  $async.Future<$2.ResultReply> disableMfa($grpc.ServiceCall call, $0.DisableMfaRequest request);

  $async.Future<$0.ListSessionsReply> listSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return listSessions($call, await $request);
  }

  $async.Future<$0.ListSessionsReply> listSessions($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$2.ResultReply> revokeSession_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.RevokeSessionRequest> $request) async {
    return revokeSession($call, await $request);
  }

  $async.Future<$2.ResultReply> revokeSession($grpc.ServiceCall call, $0.RevokeSessionRequest request);

  $async.Future<$0.RevokeSessionsReply> revokeOtherSessions_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return revokeOtherSessions($call, await $request);
  }

  $async.Future<$0.RevokeSessionsReply> revokeOtherSessions($grpc.ServiceCall call, $1.Empty request);

  $async.Stream<$0.UserInfo> loadUsersInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.LoadUsersInfoRequest> $request) async* {
    yield* loadUsersInfo($call, await $request);
  }

  $async.Stream<$0.UserInfo> loadUsersInfo($grpc.ServiceCall call, $0.LoadUsersInfoRequest request);

  $async.Stream<$0.User> loadUsers_Pre($grpc.ServiceCall $call, $async.Future<$0.UserId> $request) async* {
    yield* loadUsers($call, await $request);
  }

  $async.Stream<$0.User> loadUsers($grpc.ServiceCall call, $0.UserId request);

  $async.Future<$2.ResultReply> createUser_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.CreateUserRequest> $request) async {
    return createUser($call, await $request);
  }

  $async.Future<$2.ResultReply> createUser($grpc.ServiceCall call, $0.CreateUserRequest request);

  $async.Future<$2.ResultReply> updateUser_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UpdateUserRequest> $request) async {
    return updateUser($call, await $request);
  }

  $async.Future<$2.ResultReply> updateUser($grpc.ServiceCall call, $0.UpdateUserRequest request);

  $async.Future<$0.AvatarUploadUrl> getAvatarUploadUrl_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.GetAvatarUploadUrlRequest> $request) async {
    return getAvatarUploadUrl($call, await $request);
  }

  $async.Future<$0.AvatarUploadUrl> getAvatarUploadUrl($grpc.ServiceCall call, $0.GetAvatarUploadUrlRequest request);

  $async.Future<$2.ResultReply> confirmAvatarUpload_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.ConfirmAvatarUploadRequest> $request) async {
    return confirmAvatarUpload($call, await $request);
  }

  $async.Future<$2.ResultReply> confirmAvatarUpload($grpc.ServiceCall call, $0.ConfirmAvatarUploadRequest request);

  $async.Future<$2.ResultReply> deleteUserAvatar_Pre($grpc.ServiceCall $call, $async.Future<$0.UserId> $request) async {
    return deleteUserAvatar($call, await $request);
  }

  $async.Future<$2.ResultReply> deleteUserAvatar($grpc.ServiceCall call, $0.UserId request);
}
