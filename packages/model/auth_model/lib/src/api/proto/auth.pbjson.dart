// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use identifierTypeDescriptor instead')
const IdentifierType$json = {
  '1': 'IdentifierType',
  '2': [
    {'1': 'IDENTIFIER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'IDENTIFIER_TYPE_EMAIL', '2': 1},
    {'1': 'IDENTIFIER_TYPE_PHONE', '2': 2},
  ],
};

/// Descriptor for `IdentifierType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List identifierTypeDescriptor =
    $convert.base64Decode('Cg5JZGVudGlmaWVyVHlwZRIfChtJREVOVElGSUVSX1RZUEVfVU5TUEVDSUZJRUQQABIZChVJRE'
        'VOVElGSUVSX1RZUEVfRU1BSUwQARIZChVJREVOVElGSUVSX1RZUEVfUEhPTkUQAg==');

@$core.Deprecated('Use oAuthProviderDescriptor instead')
const OAuthProvider$json = {
  '1': 'OAuthProvider',
  '2': [
    {'1': 'OAUTH_PROVIDER_UNSPECIFIED', '2': 0},
    {'1': 'OAUTH_PROVIDER_GOOGLE', '2': 1},
    {'1': 'OAUTH_PROVIDER_GITHUB', '2': 2},
    {'1': 'OAUTH_PROVIDER_MICROSOFT', '2': 3},
    {'1': 'OAUTH_PROVIDER_APPLE', '2': 4},
    {'1': 'OAUTH_PROVIDER_FACEBOOK', '2': 5},
  ],
};

/// Descriptor for `OAuthProvider`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List oAuthProviderDescriptor =
    $convert.base64Decode('Cg1PQXV0aFByb3ZpZGVyEh4KGk9BVVRIX1BST1ZJREVSX1VOU1BFQ0lGSUVEEAASGQoVT0FVVE'
        'hfUFJPVklERVJfR09PR0xFEAESGQoVT0FVVEhfUFJPVklERVJfR0lUSFVCEAISHAoYT0FVVEhf'
        'UFJPVklERVJfTUlDUk9TT0ZUEAMSGAoUT0FVVEhfUFJPVklERVJfQVBQTEUQBBIbChdPQVVUSF'
        '9QUk9WSURFUl9GQUNFQk9PSxAF');

@$core.Deprecated('Use userStatusDescriptor instead')
const UserStatus$json = {
  '1': 'UserStatus',
  '2': [
    {'1': 'USER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'USER_STATUS_PENDING', '2': 1},
    {'1': 'USER_STATUS_ACTIVE', '2': 2},
    {'1': 'USER_STATUS_SUSPENDED', '2': 3},
    {'1': 'USER_STATUS_DELETED', '2': 4},
  ],
};

/// Descriptor for `UserStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userStatusDescriptor =
    $convert.base64Decode('CgpVc2VyU3RhdHVzEhsKF1VTRVJfU1RBVFVTX1VOU1BFQ0lGSUVEEAASFwoTVVNFUl9TVEFUVV'
        'NfUEVORElORxABEhYKElVTRVJfU1RBVFVTX0FDVElWRRACEhkKFVVTRVJfU1RBVFVTX1NVU1BF'
        'TkRFRBADEhcKE1VTRVJfU1RBVFVTX0RFTEVURUQQBA==');

@$core.Deprecated('Use userRoleDescriptor instead')
const UserRole$json = {
  '1': 'UserRole',
  '2': [
    {'1': 'USER_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'USER_ROLE_ADMIN', '2': 1},
    {'1': 'USER_ROLE_USER', '2': 2},
    {'1': 'USER_ROLE_GUEST', '2': 3},
  ],
};

/// Descriptor for `UserRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userRoleDescriptor =
    $convert.base64Decode('CghVc2VyUm9sZRIZChVVU0VSX1JPTEVfVU5TUEVDSUZJRUQQABITCg9VU0VSX1JPTEVfQURNSU'
        '4QARISCg5VU0VSX1JPTEVfVVNFUhACEhMKD1VTRVJfUk9MRV9HVUVTVBAD');

@$core.Deprecated('Use authStatusDescriptor instead')
const AuthStatus$json = {
  '1': 'AuthStatus',
  '2': [
    {'1': 'AUTH_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'AUTH_STATUS_SUCCESS', '2': 1},
    {'1': 'AUTH_STATUS_MFA_REQUIRED', '2': 2},
    {'1': 'AUTH_STATUS_FAILED', '2': 3},
    {'1': 'AUTH_STATUS_LOCKED', '2': 4},
    {'1': 'AUTH_STATUS_SUSPENDED', '2': 5},
    {'1': 'AUTH_STATUS_PENDING', '2': 6},
  ],
};

/// Descriptor for `AuthStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authStatusDescriptor =
    $convert.base64Decode('CgpBdXRoU3RhdHVzEhsKF0FVVEhfU1RBVFVTX1VOU1BFQ0lGSUVEEAASFwoTQVVUSF9TVEFUVV'
        'NfU1VDQ0VTUxABEhwKGEFVVEhfU1RBVFVTX01GQV9SRVFVSVJFRBACEhYKEkFVVEhfU1RBVFVT'
        'X0ZBSUxFRBADEhYKEkFVVEhfU1RBVFVTX0xPQ0tFRBAEEhkKFUFVVEhfU1RBVFVTX1NVU1BFTk'
        'RFRBAFEhcKE0FVVEhfU1RBVFVTX1BFTkRJTkcQBg==');

@$core.Deprecated('Use verificationTypeDescriptor instead')
const VerificationType$json = {
  '1': 'VerificationType',
  '2': [
    {'1': 'VERIFICATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'VERIFICATION_TYPE_EMAIL', '2': 1},
    {'1': 'VERIFICATION_TYPE_PHONE', '2': 2},
  ],
};

/// Descriptor for `VerificationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List verificationTypeDescriptor =
    $convert.base64Decode('ChBWZXJpZmljYXRpb25UeXBlEiEKHVZFUklGSUNBVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASGw'
        'oXVkVSSUZJQ0FUSU9OX1RZUEVfRU1BSUwQARIbChdWRVJJRklDQVRJT05fVFlQRV9QSE9ORRAC');

@$core.Deprecated('Use mfaMethodDescriptor instead')
const MfaMethod$json = {
  '1': 'MfaMethod',
  '2': [
    {'1': 'MFA_METHOD_UNSPECIFIED', '2': 0},
    {'1': 'MFA_METHOD_TOTP', '2': 1},
    {'1': 'MFA_METHOD_SMS', '2': 2},
    {'1': 'MFA_METHOD_EMAIL', '2': 3},
    {'1': 'MFA_METHOD_RECOVERY_CODE', '2': 4},
  ],
};

/// Descriptor for `MfaMethod`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List mfaMethodDescriptor =
    $convert.base64Decode('CglNZmFNZXRob2QSGgoWTUZBX01FVEhPRF9VTlNQRUNJRklFRBAAEhMKD01GQV9NRVRIT0RfVE'
        '9UUBABEhIKDk1GQV9NRVRIT0RfU01TEAISFAoQTUZBX01FVEhPRF9FTUFJTBADEhwKGE1GQV9N'
        'RVRIT0RfUkVDT1ZFUllfQ09ERRAE');

@$core.Deprecated('Use authenticateRequestDescriptor instead')
const AuthenticateRequest$json = {
  '1': 'AuthenticateRequest',
  '2': [
    {'1': 'identifier', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'identifier'},
    {'1': 'identifier_type', '3': 2, '4': 1, '5': 14, '6': '.auth.IdentifierType', '10': 'identifierType'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'installation_id', '3': 4, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'installationId'},
    {'1': 'client_info', '3': 5, '4': 1, '5': 11, '6': '.auth.ClientInfo', '8': {}, '10': 'clientInfo'},
  ],
};

/// Descriptor for `AuthenticateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authenticateRequestDescriptor =
    $convert.base64Decode('ChNBdXRoZW50aWNhdGVSZXF1ZXN0EioKCmlkZW50aWZpZXIYASABKAlCCvpCB3IFEAEY/gFSCm'
        'lkZW50aWZpZXISPQoPaWRlbnRpZmllcl90eXBlGAIgASgOMhQuYXV0aC5JZGVudGlmaWVyVHlw'
        'ZVIOaWRlbnRpZmllclR5cGUSJgoIcGFzc3dvcmQYAyABKAlCCvpCB3IFEAEYgAFSCHBhc3N3b3'
        'JkEj0KD2luc3RhbGxhdGlvbl9pZBgEIAEoCzIKLmNvcmUuVVVJREII+kIFigECEAFSDmluc3Rh'
        'bGxhdGlvbklkEjsKC2NsaWVudF9pbmZvGAUgASgLMhAuYXV0aC5DbGllbnRJbmZvQgj6QgWKAQ'
        'IQAVIKY2xpZW50SW5mbw==');

@$core.Deprecated('Use signUpRequestDescriptor instead')
const SignUpRequest$json = {
  '1': 'SignUpRequest',
  '2': [
    {'1': 'identifier', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'identifier'},
    {'1': 'identifier_type', '3': 2, '4': 1, '5': 14, '6': '.auth.IdentifierType', '10': 'identifierType'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'display_name', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'displayName'},
    {'1': 'installation_id', '3': 5, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'installationId'},
    {'1': 'client_info', '3': 6, '4': 1, '5': 11, '6': '.auth.ClientInfo', '8': {}, '10': 'clientInfo'},
    {'1': 'locale', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'locale'},
    {'1': 'timezone', '3': 8, '4': 1, '5': 9, '8': {}, '10': 'timezone'},
  ],
};

/// Descriptor for `SignUpRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signUpRequestDescriptor =
    $convert.base64Decode('Cg1TaWduVXBSZXF1ZXN0EioKCmlkZW50aWZpZXIYASABKAlCCvpCB3IFEAEY/gFSCmlkZW50aW'
        'ZpZXISPQoPaWRlbnRpZmllcl90eXBlGAIgASgOMhQuYXV0aC5JZGVudGlmaWVyVHlwZVIOaWRl'
        'bnRpZmllclR5cGUSJgoIcGFzc3dvcmQYAyABKAlCCvpCB3IFEAgYgAFSCHBhc3N3b3JkEi0KDG'
        'Rpc3BsYXlfbmFtZRgEIAEoCUIK+kIHcgUQARj/AVILZGlzcGxheU5hbWUSPQoPaW5zdGFsbGF0'
        'aW9uX2lkGAUgASgLMgouY29yZS5VVUlEQgj6QgWKAQIQAVIOaW5zdGFsbGF0aW9uSWQSOwoLY2'
        'xpZW50X2luZm8YBiABKAsyEC5hdXRoLkNsaWVudEluZm9CCPpCBYoBAhABUgpjbGllbnRJbmZv'
        'Eh8KBmxvY2FsZRgHIAEoCUIH+kIEcgIYI1IGbG9jYWxlEiMKCHRpbWV6b25lGAggASgJQgf6Qg'
        'RyAhhAUgh0aW1lem9uZQ==');

@$core.Deprecated('Use authResultDescriptor instead')
const AuthResult$json = {
  '1': 'AuthResult',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.auth.AuthStatus', '10': 'status'},
    {'1': 'auth_info', '3': 2, '4': 1, '5': 11, '6': '.auth.AuthInfo', '10': 'authInfo'},
    {'1': 'mfa_challenge', '3': 3, '4': 1, '5': 11, '6': '.auth.MfaChallenge', '10': 'mfaChallenge'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {'1': 'lockout_info', '3': 5, '4': 1, '5': 11, '6': '.auth.LockoutInfo', '10': 'lockoutInfo'},
  ],
};

/// Descriptor for `AuthResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResultDescriptor =
    $convert.base64Decode('CgpBdXRoUmVzdWx0EigKBnN0YXR1cxgBIAEoDjIQLmF1dGguQXV0aFN0YXR1c1IGc3RhdHVzEi'
        'sKCWF1dGhfaW5mbxgCIAEoCzIOLmF1dGguQXV0aEluZm9SCGF1dGhJbmZvEjcKDW1mYV9jaGFs'
        'bGVuZ2UYAyABKAsyEi5hdXRoLk1mYUNoYWxsZW5nZVIMbWZhQ2hhbGxlbmdlEhgKB21lc3NhZ2'
        'UYBCABKAlSB21lc3NhZ2USNAoMbG9ja291dF9pbmZvGAUgASgLMhEuYXV0aC5Mb2Nrb3V0SW5m'
        'b1ILbG9ja291dEluZm8=');

@$core.Deprecated('Use lockoutInfoDescriptor instead')
const LockoutInfo$json = {
  '1': 'LockoutInfo',
  '2': [
    {'1': 'retry_after_seconds', '3': 1, '4': 1, '5': 5, '10': 'retryAfterSeconds'},
    {'1': 'failed_attempts', '3': 2, '4': 1, '5': 5, '10': 'failedAttempts'},
    {'1': 'max_attempts', '3': 3, '4': 1, '5': 5, '10': 'maxAttempts'},
    {'1': 'locked_until', '3': 4, '4': 1, '5': 3, '10': 'lockedUntil'},
  ],
};

/// Descriptor for `LockoutInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lockoutInfoDescriptor =
    $convert.base64Decode('CgtMb2Nrb3V0SW5mbxIuChNyZXRyeV9hZnRlcl9zZWNvbmRzGAEgASgFUhFyZXRyeUFmdGVyU2'
        'Vjb25kcxInCg9mYWlsZWRfYXR0ZW1wdHMYAiABKAVSDmZhaWxlZEF0dGVtcHRzEiEKDG1heF9h'
        'dHRlbXB0cxgDIAEoBVILbWF4QXR0ZW1wdHMSIQoMbG9ja2VkX3VudGlsGAQgASgDUgtsb2NrZW'
        'RVbnRpbA==');

@$core.Deprecated('Use mfaChallengeDescriptor instead')
const MfaChallenge$json = {
  '1': 'MfaChallenge',
  '2': [
    {'1': 'challenge_token', '3': 1, '4': 1, '5': 9, '10': 'challengeToken'},
    {'1': 'available_methods', '3': 2, '4': 3, '5': 11, '6': '.auth.MfaMethodInfo', '10': 'availableMethods'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 3, '10': 'expiresAt'},
  ],
};

/// Descriptor for `MfaChallenge`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaChallengeDescriptor =
    $convert.base64Decode('CgxNZmFDaGFsbGVuZ2USJwoPY2hhbGxlbmdlX3Rva2VuGAEgASgJUg5jaGFsbGVuZ2VUb2tlbh'
        'JAChFhdmFpbGFibGVfbWV0aG9kcxgCIAMoCzITLmF1dGguTWZhTWV0aG9kSW5mb1IQYXZhaWxh'
        'YmxlTWV0aG9kcxIdCgpleHBpcmVzX2F0GAMgASgDUglleHBpcmVzQXQ=');

@$core.Deprecated('Use mfaMethodInfoDescriptor instead')
const MfaMethodInfo$json = {
  '1': 'MfaMethodInfo',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 14, '6': '.auth.MfaMethod', '10': 'method'},
    {'1': 'hint', '3': 2, '4': 1, '5': 9, '10': 'hint'},
    {'1': 'is_default', '3': 3, '4': 1, '5': 8, '10': 'isDefault'},
  ],
};

/// Descriptor for `MfaMethodInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaMethodInfoDescriptor =
    $convert.base64Decode('Cg1NZmFNZXRob2RJbmZvEicKBm1ldGhvZBgBIAEoDjIPLmF1dGguTWZhTWV0aG9kUgZtZXRob2'
        'QSEgoEaGludBgCIAEoCVIEaGludBIdCgppc19kZWZhdWx0GAMgASgIUglpc0RlZmF1bHQ=');

@$core.Deprecated('Use verifyMfaRequestDescriptor instead')
const VerifyMfaRequest$json = {
  '1': 'VerifyMfaRequest',
  '2': [
    {'1': 'challenge_token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'challengeToken'},
    {'1': 'method', '3': 2, '4': 1, '5': 14, '6': '.auth.MfaMethod', '10': 'method'},
    {'1': 'code', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'client_info', '3': 4, '4': 1, '5': 11, '6': '.auth.ClientInfo', '10': 'clientInfo'},
  ],
};

/// Descriptor for `VerifyMfaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyMfaRequestDescriptor =
    $convert.base64Decode('ChBWZXJpZnlNZmFSZXF1ZXN0EjAKD2NoYWxsZW5nZV90b2tlbhgBIAEoCUIH+kIEcgIQAVIOY2'
        'hhbGxlbmdlVG9rZW4SJwoGbWV0aG9kGAIgASgOMg8uYXV0aC5NZmFNZXRob2RSBm1ldGhvZBId'
        'CgRjb2RlGAMgASgJQgn6QgZyBBAGGCBSBGNvZGUSMQoLY2xpZW50X2luZm8YBCABKAsyEC5hdX'
        'RoLkNsaWVudEluZm9SCmNsaWVudEluZm8=');

@$core.Deprecated('Use authInfoDescriptor instead')
const AuthInfo$json = {
  '1': 'AuthInfo',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'user_role', '3': 3, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'userRole'},
    {'1': 'refresh_token', '3': 4, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_token', '3': 5, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'email', '3': 6, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 7, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email_verified', '3': 8, '4': 1, '5': 8, '10': 'emailVerified'},
    {'1': 'phone_verified', '3': 9, '4': 1, '5': 8, '10': 'phoneVerified'},
    {'1': 'mfa_enabled', '3': 10, '4': 1, '5': 8, '10': 'mfaEnabled'},
    {'1': 'linked_providers', '3': 11, '4': 3, '5': 14, '6': '.auth.OAuthProvider', '10': 'linkedProviders'},
    {'1': 'status', '3': 12, '4': 1, '5': 14, '6': '.auth.UserStatus', '10': 'status'},
  ],
};

/// Descriptor for `AuthInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authInfoDescriptor =
    $convert.base64Decode('CghBdXRoSW5mbxIjCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVUlEUgZ1c2VySWQSIQoMZGlzcG'
        'xheV9uYW1lGAIgASgJUgtkaXNwbGF5TmFtZRIrCgl1c2VyX3JvbGUYAyABKA4yDi5hdXRoLlVz'
        'ZXJSb2xlUgh1c2VyUm9sZRIjCg1yZWZyZXNoX3Rva2VuGAQgASgJUgxyZWZyZXNoVG9rZW4SIQ'
        'oMYWNjZXNzX3Rva2VuGAUgASgJUgthY2Nlc3NUb2tlbhIUCgVlbWFpbBgGIAEoCVIFZW1haWwS'
        'FAoFcGhvbmUYByABKAlSBXBob25lEiUKDmVtYWlsX3ZlcmlmaWVkGAggASgIUg1lbWFpbFZlcm'
        'lmaWVkEiUKDnBob25lX3ZlcmlmaWVkGAkgASgIUg1waG9uZVZlcmlmaWVkEh8KC21mYV9lbmFi'
        'bGVkGAogASgIUgptZmFFbmFibGVkEj4KEGxpbmtlZF9wcm92aWRlcnMYCyADKA4yEy5hdXRoLk'
        '9BdXRoUHJvdmlkZXJSD2xpbmtlZFByb3ZpZGVycxIoCgZzdGF0dXMYDCABKA4yEC5hdXRoLlVz'
        'ZXJTdGF0dXNSBnN0YXR1cw==');

@$core.Deprecated('Use clientInfoDescriptor instead')
const ClientInfo$json = {
  '1': 'ClientInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'deviceId'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'deviceName'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'deviceType'},
    {'1': 'client_version', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'clientVersion'},
    {'1': 'metadata', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'metadata'},
  ],
};

/// Descriptor for `ClientInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientInfoDescriptor =
    $convert.base64Decode('CgpDbGllbnRJbmZvEiUKCWRldmljZV9pZBgBIAEoCUII+kIFcgMY/wFSCGRldmljZUlkEikKC2'
        'RldmljZV9uYW1lGAIgASgJQgj6QgVyAxj/AVIKZGV2aWNlTmFtZRIoCgtkZXZpY2VfdHlwZRgD'
        'IAEoCUIH+kIEcgIYMlIKZGV2aWNlVHlwZRIuCg5jbGllbnRfdmVyc2lvbhgEIAEoCUIH+kIEcg'
        'IYZFINY2xpZW50VmVyc2lvbhIzCghtZXRhZGF0YRgFIAEoCzIXLmdvb2dsZS5wcm90b2J1Zi5T'
        'dHJ1Y3RSCG1ldGFkYXRh');

@$core.Deprecated('Use requestVerificationRequestDescriptor instead')
const RequestVerificationRequest$json = {
  '1': 'RequestVerificationRequest',
  '2': [
    {'1': 'verification_type', '3': 1, '4': 1, '5': 14, '6': '.auth.VerificationType', '10': 'verificationType'},
  ],
};

/// Descriptor for `RequestVerificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestVerificationRequestDescriptor =
    $convert.base64Decode('ChpSZXF1ZXN0VmVyaWZpY2F0aW9uUmVxdWVzdBJDChF2ZXJpZmljYXRpb25fdHlwZRgBIAEoDj'
        'IWLmF1dGguVmVyaWZpY2F0aW9uVHlwZVIQdmVyaWZpY2F0aW9uVHlwZQ==');

@$core.Deprecated('Use confirmVerificationRequestDescriptor instead')
const ConfirmVerificationRequest$json = {
  '1': 'ConfirmVerificationRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'token'},
    {'1': 'verification_type', '3': 2, '4': 1, '5': 14, '6': '.auth.VerificationType', '10': 'verificationType'},
  ],
};

/// Descriptor for `ConfirmVerificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmVerificationRequestDescriptor =
    $convert.base64Decode('ChpDb25maXJtVmVyaWZpY2F0aW9uUmVxdWVzdBIdCgV0b2tlbhgBIAEoCUIH+kIEcgIQAVIFdG'
        '9rZW4SQwoRdmVyaWZpY2F0aW9uX3R5cGUYAiABKA4yFi5hdXRoLlZlcmlmaWNhdGlvblR5cGVS'
        'EHZlcmlmaWNhdGlvblR5cGU=');

@$core.Deprecated('Use getOAuthUrlRequestDescriptor instead')
const GetOAuthUrlRequest$json = {
  '1': 'GetOAuthUrlRequest',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 14, '6': '.auth.OAuthProvider', '10': 'provider'},
    {'1': 'redirect_uri', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'redirectUri'},
    {'1': 'scopes', '3': 3, '4': 3, '5': 9, '10': 'scopes'},
    {'1': 'state_data', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'stateData'},
  ],
};

/// Descriptor for `GetOAuthUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOAuthUrlRequestDescriptor =
    $convert.base64Decode('ChJHZXRPQXV0aFVybFJlcXVlc3QSLwoIcHJvdmlkZXIYASABKA4yEy5hdXRoLk9BdXRoUHJvdm'
        'lkZXJSCHByb3ZpZGVyEisKDHJlZGlyZWN0X3VyaRgCIAEoCUII+kIFcgMYgBBSC3JlZGlyZWN0'
        'VXJpEhYKBnNjb3BlcxgDIAMoCVIGc2NvcGVzEicKCnN0YXRlX2RhdGEYBCABKAlCCPpCBXIDGI'
        'AIUglzdGF0ZURhdGE=');

@$core.Deprecated('Use oAuthUrlReplyDescriptor instead')
const OAuthUrlReply$json = {
  '1': 'OAuthUrlReply',
  '2': [
    {'1': 'authorization_url', '3': 1, '4': 1, '5': 9, '10': 'authorizationUrl'},
    {'1': 'state', '3': 2, '4': 1, '5': 9, '10': 'state'},
  ],
};

/// Descriptor for `OAuthUrlReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oAuthUrlReplyDescriptor =
    $convert.base64Decode('Cg1PQXV0aFVybFJlcGx5EisKEWF1dGhvcml6YXRpb25fdXJsGAEgASgJUhBhdXRob3JpemF0aW'
        '9uVXJsEhQKBXN0YXRlGAIgASgJUgVzdGF0ZQ==');

@$core.Deprecated('Use exchangeOAuthCodeRequestDescriptor instead')
const ExchangeOAuthCodeRequest$json = {
  '1': 'ExchangeOAuthCodeRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'state', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'state'},
    {'1': 'installation_id', '3': 3, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'installationId'},
    {'1': 'client_info', '3': 4, '4': 1, '5': 11, '6': '.auth.ClientInfo', '8': {}, '10': 'clientInfo'},
  ],
};

/// Descriptor for `ExchangeOAuthCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeOAuthCodeRequestDescriptor =
    $convert.base64Decode('ChhFeGNoYW5nZU9BdXRoQ29kZVJlcXVlc3QSGwoEY29kZRgBIAEoCUIH+kIEcgIQAVIEY29kZR'
        'IdCgVzdGF0ZRgCIAEoCUIH+kIEcgIQAVIFc3RhdGUSPQoPaW5zdGFsbGF0aW9uX2lkGAMgASgL'
        'MgouY29yZS5VVUlEQgj6QgWKAQIQAVIOaW5zdGFsbGF0aW9uSWQSOwoLY2xpZW50X2luZm8YBC'
        'ABKAsyEC5hdXRoLkNsaWVudEluZm9CCPpCBYoBAhABUgpjbGllbnRJbmZv');

@$core.Deprecated('Use linkOAuthProviderRequestDescriptor instead')
const LinkOAuthProviderRequest$json = {
  '1': 'LinkOAuthProviderRequest',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'state', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'state'},
  ],
};

/// Descriptor for `LinkOAuthProviderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkOAuthProviderRequestDescriptor =
    $convert.base64Decode('ChhMaW5rT0F1dGhQcm92aWRlclJlcXVlc3QSGwoEY29kZRgBIAEoCUIH+kIEcgIQAVIEY29kZR'
        'IdCgVzdGF0ZRgCIAEoCUIH+kIEcgIQAVIFc3RhdGU=');

@$core.Deprecated('Use unlinkOAuthProviderRequestDescriptor instead')
const UnlinkOAuthProviderRequest$json = {
  '1': 'UnlinkOAuthProviderRequest',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 14, '6': '.auth.OAuthProvider', '10': 'provider'},
  ],
};

/// Descriptor for `UnlinkOAuthProviderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlinkOAuthProviderRequestDescriptor =
    $convert.base64Decode('ChpVbmxpbmtPQXV0aFByb3ZpZGVyUmVxdWVzdBIvCghwcm92aWRlchgBIAEoDjITLmF1dGguT0'
        'F1dGhQcm92aWRlclIIcHJvdmlkZXI=');

@$core.Deprecated('Use linkedProvidersReplyDescriptor instead')
const LinkedProvidersReply$json = {
  '1': 'LinkedProvidersReply',
  '2': [
    {'1': 'providers', '3': 1, '4': 3, '5': 11, '6': '.auth.LinkedProvider', '10': 'providers'},
  ],
};

/// Descriptor for `LinkedProvidersReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkedProvidersReplyDescriptor =
    $convert.base64Decode('ChRMaW5rZWRQcm92aWRlcnNSZXBseRIyCglwcm92aWRlcnMYASADKAsyFC5hdXRoLkxpbmtlZF'
        'Byb3ZpZGVyUglwcm92aWRlcnM=');

@$core.Deprecated('Use linkedProviderDescriptor instead')
const LinkedProvider$json = {
  '1': 'LinkedProvider',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 14, '6': '.auth.OAuthProvider', '10': 'provider'},
    {'1': 'provider_user_id', '3': 2, '4': 1, '5': 9, '10': 'providerUserId'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'linked_at', '3': 4, '4': 1, '5': 3, '10': 'linkedAt'},
  ],
};

/// Descriptor for `LinkedProvider`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkedProviderDescriptor =
    $convert.base64Decode('Cg5MaW5rZWRQcm92aWRlchIvCghwcm92aWRlchgBIAEoDjITLmF1dGguT0F1dGhQcm92aWRlcl'
        'IIcHJvdmlkZXISKAoQcHJvdmlkZXJfdXNlcl9pZBgCIAEoCVIOcHJvdmlkZXJVc2VySWQSFAoF'
        'ZW1haWwYAyABKAlSBWVtYWlsEhsKCWxpbmtlZF9hdBgEIAEoA1IIbGlua2VkQXQ=');

@$core.Deprecated('Use mfaStatusReplyDescriptor instead')
const MfaStatusReply$json = {
  '1': 'MfaStatusReply',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'methods', '3': 2, '4': 3, '5': 11, '6': '.auth.MfaMethodStatus', '10': 'methods'},
    {'1': 'recovery_codes_remaining', '3': 3, '4': 1, '5': 5, '10': 'recoveryCodesRemaining'},
  ],
};

/// Descriptor for `MfaStatusReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaStatusReplyDescriptor =
    $convert.base64Decode('Cg5NZmFTdGF0dXNSZXBseRIYCgdlbmFibGVkGAEgASgIUgdlbmFibGVkEi8KB21ldGhvZHMYAi'
        'ADKAsyFS5hdXRoLk1mYU1ldGhvZFN0YXR1c1IHbWV0aG9kcxI4ChhyZWNvdmVyeV9jb2Rlc19y'
        'ZW1haW5pbmcYAyABKAVSFnJlY292ZXJ5Q29kZXNSZW1haW5pbmc=');

@$core.Deprecated('Use mfaMethodStatusDescriptor instead')
const MfaMethodStatus$json = {
  '1': 'MfaMethodStatus',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 14, '6': '.auth.MfaMethod', '10': 'method'},
    {'1': 'enabled', '3': 2, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'hint', '3': 3, '4': 1, '5': 9, '10': 'hint'},
    {'1': 'configured_at', '3': 4, '4': 1, '5': 3, '10': 'configuredAt'},
  ],
};

/// Descriptor for `MfaMethodStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaMethodStatusDescriptor =
    $convert.base64Decode('Cg9NZmFNZXRob2RTdGF0dXMSJwoGbWV0aG9kGAEgASgOMg8uYXV0aC5NZmFNZXRob2RSBm1ldG'
        'hvZBIYCgdlbmFibGVkGAIgASgIUgdlbmFibGVkEhIKBGhpbnQYAyABKAlSBGhpbnQSIwoNY29u'
        'ZmlndXJlZF9hdBgEIAEoA1IMY29uZmlndXJlZEF0');

@$core.Deprecated('Use setupMfaRequestDescriptor instead')
const SetupMfaRequest$json = {
  '1': 'SetupMfaRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 14, '6': '.auth.MfaMethod', '10': 'method'},
    {'1': 'identifier', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'identifier'},
  ],
};

/// Descriptor for `SetupMfaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setupMfaRequestDescriptor =
    $convert.base64Decode('Cg9TZXR1cE1mYVJlcXVlc3QSJwoGbWV0aG9kGAEgASgOMg8uYXV0aC5NZmFNZXRob2RSBm1ldG'
        'hvZBIoCgppZGVudGlmaWVyGAIgASgJQgj6QgVyAxj+AVIKaWRlbnRpZmllcg==');

@$core.Deprecated('Use setupMfaReplyDescriptor instead')
const SetupMfaReply$json = {
  '1': 'SetupMfaReply',
  '2': [
    {'1': 'secret', '3': 1, '4': 1, '5': 9, '10': 'secret'},
    {'1': 'provisioning_uri', '3': 2, '4': 1, '5': 9, '10': 'provisioningUri'},
    {'1': 'masked_destination', '3': 3, '4': 1, '5': 9, '10': 'maskedDestination'},
    {'1': 'setup_token', '3': 4, '4': 1, '5': 9, '10': 'setupToken'},
    {'1': 'expires_at', '3': 5, '4': 1, '5': 3, '10': 'expiresAt'},
  ],
};

/// Descriptor for `SetupMfaReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setupMfaReplyDescriptor =
    $convert.base64Decode('Cg1TZXR1cE1mYVJlcGx5EhYKBnNlY3JldBgBIAEoCVIGc2VjcmV0EikKEHByb3Zpc2lvbmluZ1'
        '91cmkYAiABKAlSD3Byb3Zpc2lvbmluZ1VyaRItChJtYXNrZWRfZGVzdGluYXRpb24YAyABKAlS'
        'EW1hc2tlZERlc3RpbmF0aW9uEh8KC3NldHVwX3Rva2VuGAQgASgJUgpzZXR1cFRva2VuEh0KCm'
        'V4cGlyZXNfYXQYBSABKANSCWV4cGlyZXNBdA==');

@$core.Deprecated('Use confirmMfaSetupRequestDescriptor instead')
const ConfirmMfaSetupRequest$json = {
  '1': 'ConfirmMfaSetupRequest',
  '2': [
    {'1': 'setup_token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'setupToken'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'code'},
  ],
};

/// Descriptor for `ConfirmMfaSetupRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmMfaSetupRequestDescriptor =
    $convert.base64Decode('ChZDb25maXJtTWZhU2V0dXBSZXF1ZXN0EigKC3NldHVwX3Rva2VuGAEgASgJQgf6QgRyAhABUg'
        'pzZXR1cFRva2VuEh0KBGNvZGUYAiABKAlCCfpCBnIEEAYYCFIEY29kZQ==');

@$core.Deprecated('Use mfaSetupResultDescriptor instead')
const MfaSetupResult$json = {
  '1': 'MfaSetupResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
    {'1': 'recovery_codes', '3': 2, '4': 3, '5': 9, '10': 'recoveryCodes'},
    {'1': 'error_message', '3': 3, '4': 1, '5': 9, '10': 'errorMessage'},
  ],
};

/// Descriptor for `MfaSetupResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaSetupResultDescriptor =
    $convert.base64Decode('Cg5NZmFTZXR1cFJlc3VsdBIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNzEiUKDnJlY292ZXJ5X2'
        'NvZGVzGAIgAygJUg1yZWNvdmVyeUNvZGVzEiMKDWVycm9yX21lc3NhZ2UYAyABKAlSDGVycm9y'
        'TWVzc2FnZQ==');

@$core.Deprecated('Use disableMfaRequestDescriptor instead')
const DisableMfaRequest$json = {
  '1': 'DisableMfaRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 14, '6': '.auth.MfaMethod', '10': 'method'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'password'},
  ],
};

/// Descriptor for `DisableMfaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List disableMfaRequestDescriptor =
    $convert.base64Decode('ChFEaXNhYmxlTWZhUmVxdWVzdBInCgZtZXRob2QYASABKA4yDy5hdXRoLk1mYU1ldGhvZFIGbW'
        'V0aG9kEiMKCHBhc3N3b3JkGAIgASgJQgf6QgRyAhABUghwYXNzd29yZA==');

@$core.Deprecated('Use recoveryStartRequestDescriptor instead')
const RecoveryStartRequest$json = {
  '1': 'RecoveryStartRequest',
  '2': [
    {'1': 'identifier', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'identifier'},
    {'1': 'identifier_type', '3': 2, '4': 1, '5': 14, '6': '.auth.IdentifierType', '10': 'identifierType'},
  ],
};

/// Descriptor for `RecoveryStartRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recoveryStartRequestDescriptor =
    $convert.base64Decode('ChRSZWNvdmVyeVN0YXJ0UmVxdWVzdBIqCgppZGVudGlmaWVyGAEgASgJQgr6QgdyBRABGP4BUg'
        'ppZGVudGlmaWVyEj0KD2lkZW50aWZpZXJfdHlwZRgCIAEoDjIULmF1dGguSWRlbnRpZmllclR5'
        'cGVSDmlkZW50aWZpZXJUeXBl');

@$core.Deprecated('Use recoveryConfirmRequestDescriptor instead')
const RecoveryConfirmRequest$json = {
  '1': 'RecoveryConfirmRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'token'},
    {'1': 'new_password', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'newPassword'},
  ],
};

/// Descriptor for `RecoveryConfirmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recoveryConfirmRequestDescriptor =
    $convert.base64Decode('ChZSZWNvdmVyeUNvbmZpcm1SZXF1ZXN0Eh0KBXRva2VuGAEgASgJQgf6QgRyAhABUgV0b2tlbh'
        'ItCgxuZXdfcGFzc3dvcmQYAiABKAlCCvpCB3IFEAgYgAFSC25ld1Bhc3N3b3Jk');

@$core.Deprecated('Use changePasswordRequestDescriptor instead')
const ChangePasswordRequest$json = {
  '1': 'ChangePasswordRequest',
  '2': [
    {'1': 'current_password', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'currentPassword'},
    {'1': 'new_password', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'newPassword'},
  ],
};

/// Descriptor for `ChangePasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List changePasswordRequestDescriptor =
    $convert.base64Decode('ChVDaGFuZ2VQYXNzd29yZFJlcXVlc3QSMgoQY3VycmVudF9wYXNzd29yZBgBIAEoCUIH+kIEcg'
        'IQAVIPY3VycmVudFBhc3N3b3JkEi0KDG5ld19wYXNzd29yZBgCIAEoCUIK+kIHcgUQCBiAAVIL'
        'bmV3UGFzc3dvcmQ=');

@$core.Deprecated('Use setPasswordRequestDescriptor instead')
const SetPasswordRequest$json = {
  '1': 'SetPasswordRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'password'},
  ],
};

/// Descriptor for `SetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPasswordRequestDescriptor =
    $convert.base64Decode('ChJTZXRQYXNzd29yZFJlcXVlc3QSLQoHdXNlcl9pZBgBIAEoCzIKLmNvcmUuVVVJREII+kIFig'
        'ECEAFSBnVzZXJJZBImCghwYXNzd29yZBgCIAEoCUIK+kIHcgUQCBiAAVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor =
    $convert.base64Decode('ChNSZWZyZXNoVG9rZW5SZXF1ZXN0EiwKDXJlZnJlc2hfdG9rZW4YASABKAlCB/pCBHICEAFSDH'
        'JlZnJlc2hUb2tlbg==');

@$core.Deprecated('Use refreshTokenReplyDescriptor instead')
const RefreshTokenReply$json = {
  '1': 'RefreshTokenReply',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_token', '3': 2, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `RefreshTokenReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenReplyDescriptor =
    $convert.base64Decode('ChFSZWZyZXNoVG9rZW5SZXBseRIjCg1yZWZyZXNoX3Rva2VuGAEgASgJUgxyZWZyZXNoVG9rZW'
        '4SIQoMYWNjZXNzX3Rva2VuGAIgASgJUgthY2Nlc3NUb2tlbg==');

@$core.Deprecated('Use sessionInfoDescriptor instead')
const SessionInfo$json = {
  '1': 'SessionInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '10': 'deviceName'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 9, '10': 'deviceType'},
    {'1': 'client_version', '3': 4, '4': 1, '5': 9, '10': 'clientVersion'},
    {'1': 'ip_address', '3': 5, '4': 1, '5': 9, '10': 'ipAddress'},
    {'1': 'ip_country', '3': 6, '4': 1, '5': 9, '10': 'ipCountry'},
    {'1': 'created_at', '3': 7, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'last_seen_at', '3': 8, '4': 1, '5': 3, '10': 'lastSeenAt'},
    {'1': 'expires_at', '3': 9, '4': 1, '5': 3, '10': 'expiresAt'},
    {'1': 'is_current', '3': 10, '4': 1, '5': 8, '10': 'isCurrent'},
    {'1': 'ip_created_by', '3': 11, '4': 1, '5': 9, '10': 'ipCreatedBy'},
    {'1': 'activity_count', '3': 12, '4': 1, '5': 5, '10': 'activityCount'},
    {'1': 'metadata', '3': 13, '4': 1, '5': 11, '6': '.google.protobuf.Struct', '10': 'metadata'},
  ],
};

/// Descriptor for `SessionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionInfoDescriptor =
    $convert.base64Decode('CgtTZXNzaW9uSW5mbxIbCglkZXZpY2VfaWQYASABKAlSCGRldmljZUlkEh8KC2RldmljZV9uYW'
        '1lGAIgASgJUgpkZXZpY2VOYW1lEh8KC2RldmljZV90eXBlGAMgASgJUgpkZXZpY2VUeXBlEiUK'
        'DmNsaWVudF92ZXJzaW9uGAQgASgJUg1jbGllbnRWZXJzaW9uEh0KCmlwX2FkZHJlc3MYBSABKA'
        'lSCWlwQWRkcmVzcxIdCgppcF9jb3VudHJ5GAYgASgJUglpcENvdW50cnkSHQoKY3JlYXRlZF9h'
        'dBgHIAEoA1IJY3JlYXRlZEF0EiAKDGxhc3Rfc2Vlbl9hdBgIIAEoA1IKbGFzdFNlZW5BdBIdCg'
        'pleHBpcmVzX2F0GAkgASgDUglleHBpcmVzQXQSHQoKaXNfY3VycmVudBgKIAEoCFIJaXNDdXJy'
        'ZW50EiIKDWlwX2NyZWF0ZWRfYnkYCyABKAlSC2lwQ3JlYXRlZEJ5EiUKDmFjdGl2aXR5X2NvdW'
        '50GAwgASgFUg1hY3Rpdml0eUNvdW50EjMKCG1ldGFkYXRhGA0gASgLMhcuZ29vZ2xlLnByb3Rv'
        'YnVmLlN0cnVjdFIIbWV0YWRhdGE=');

@$core.Deprecated('Use listSessionsReplyDescriptor instead')
const ListSessionsReply$json = {
  '1': 'ListSessionsReply',
  '2': [
    {'1': 'sessions', '3': 1, '4': 3, '5': 11, '6': '.auth.SessionInfo', '10': 'sessions'},
  ],
};

/// Descriptor for `ListSessionsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsReplyDescriptor =
    $convert.base64Decode('ChFMaXN0U2Vzc2lvbnNSZXBseRItCghzZXNzaW9ucxgBIAMoCzIRLmF1dGguU2Vzc2lvbkluZm'
        '9SCHNlc3Npb25z');

@$core.Deprecated('Use revokeSessionRequestDescriptor instead')
const RevokeSessionRequest$json = {
  '1': 'RevokeSessionRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'deviceId'},
  ],
};

/// Descriptor for `RevokeSessionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeSessionRequestDescriptor =
    $convert.base64Decode('ChRSZXZva2VTZXNzaW9uUmVxdWVzdBInCglkZXZpY2VfaWQYASABKAlCCvpCB3IFEAEY/wFSCG'
        'RldmljZUlk');

@$core.Deprecated('Use revokeSessionsReplyDescriptor instead')
const RevokeSessionsReply$json = {
  '1': 'RevokeSessionsReply',
  '2': [
    {'1': 'revoked_count', '3': 1, '4': 1, '5': 5, '10': 'revokedCount'},
  ],
};

/// Descriptor for `RevokeSessionsReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeSessionsReplyDescriptor =
    $convert.base64Decode('ChNSZXZva2VTZXNzaW9uc1JlcGx5EiMKDXJldm9rZWRfY291bnQYASABKAVSDHJldm9rZWRDb3'
        'VudA==');

@$core.Deprecated('Use loadUsersInfoRequestDescriptor instead')
const LoadUsersInfoRequest$json = {
  '1': 'LoadUsersInfoRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 11, '6': '.core.UUID', '10': 'userIds'},
    {'1': 'statuses', '3': 3, '4': 3, '5': 9, '10': 'statuses'},
  ],
};

/// Descriptor for `LoadUsersInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadUsersInfoRequestDescriptor =
    $convert.base64Decode('ChRMb2FkVXNlcnNJbmZvUmVxdWVzdBIjCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVUlEUgZ1c2'
        'VySWQSJQoIdXNlcl9pZHMYAiADKAsyCi5jb3JlLlVVSURSB3VzZXJJZHMSGgoIc3RhdHVzZXMY'
        'AyADKAlSCHN0YXR1c2Vz');

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 5, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'phone', '3': 6, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'email_verified', '3': 7, '4': 1, '5': 8, '10': 'emailVerified'},
    {'1': 'phone_verified', '3': 8, '4': 1, '5': 8, '10': 'phoneVerified'},
    {'1': 'mfa_enabled', '3': 9, '4': 1, '5': 8, '10': 'mfaEnabled'},
    {'1': 'status', '3': 10, '4': 1, '5': 14, '6': '.auth.UserStatus', '10': 'status'},
    {'1': 'linked_providers', '3': 11, '4': 3, '5': 14, '6': '.auth.OAuthProvider', '10': 'linkedProviders'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor =
    $convert.base64Decode('CghVc2VySW5mbxIaCgJpZBgBIAEoCzIKLmNvcmUuVVVJRFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
        'FtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSIgoEcm9sZRgEIAEoDjIOLmF1dGguVXNlclJvbGVS'
        'BHJvbGUSGAoHZGVsZXRlZBgFIAEoCFIHZGVsZXRlZBIUCgVwaG9uZRgGIAEoCVIFcGhvbmUSJQ'
        'oOZW1haWxfdmVyaWZpZWQYByABKAhSDWVtYWlsVmVyaWZpZWQSJQoOcGhvbmVfdmVyaWZpZWQY'
        'CCABKAhSDXBob25lVmVyaWZpZWQSHwoLbWZhX2VuYWJsZWQYCSABKAhSCm1mYUVuYWJsZWQSKA'
        'oGc3RhdHVzGAogASgOMhAuYXV0aC5Vc2VyU3RhdHVzUgZzdGF0dXMSPgoQbGlua2VkX3Byb3Zp'
        'ZGVycxgLIAMoDjITLmF1dGguT0F1dGhQcm92aWRlclIPbGlua2VkUHJvdmlkZXJz');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 5, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'phone', '3': 6, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'status', '3': 7, '4': 1, '5': 9, '10': 'status'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 9, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor =
    $convert.base64Decode('CgRVc2VyEhoKAmlkGAEgASgLMgouY29yZS5VVUlEUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
        'QKBWVtYWlsGAMgASgJUgVlbWFpbBIiCgRyb2xlGAQgASgOMg4uYXV0aC5Vc2VyUm9sZVIEcm9s'
        'ZRIYCgdkZWxldGVkGAUgASgIUgdkZWxldGVkEhQKBXBob25lGAYgASgJUgVwaG9uZRIWCgZzdG'
        'F0dXMYByABKAlSBnN0YXR1cxIdCgpjcmVhdGVkX2F0GAggASgDUgljcmVhdGVkQXQSHQoKdXBk'
        'YXRlZF9hdBgJIAEoA1IJdXBkYXRlZEF0');

@$core.Deprecated('Use userIdDescriptor instead')
const UserId$json = {
  '1': 'UserId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'id'},
  ],
};

/// Descriptor for `UserId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userIdDescriptor =
    $convert.base64Decode('CgZVc2VySWQSJAoCaWQYASABKAsyCi5jb3JlLlVVSURCCPpCBYoBAhABUgJpZA==');

@$core.Deprecated('Use createUserRequestDescriptor instead')
const CreateUserRequest$json = {
  '1': 'CreateUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'phone'},
    {'1': 'password', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'role', '3': 6, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 7, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'locale', '3': 8, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'timezone', '3': 9, '4': 1, '5': 9, '10': 'timezone'},
  ],
};

/// Descriptor for `CreateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserRequestDescriptor =
    $convert.base64Decode('ChFDcmVhdGVVc2VyUmVxdWVzdBIkCgJpZBgBIAEoCzIKLmNvcmUuVVVJREII+kIFigECEAFSAm'
        'lkEh4KBG5hbWUYAiABKAlCCvpCB3IFEAEY/wFSBG5hbWUSHgoFZW1haWwYAyABKAlCCPpCBXID'
        'GP4BUgVlbWFpbBIdCgVwaG9uZRgEIAEoCUIH+kIEcgIYEFIFcGhvbmUSJAoIcGFzc3dvcmQYBS'
        'ABKAlCCPpCBXIDGIABUghwYXNzd29yZBIiCgRyb2xlGAYgASgOMg4uYXV0aC5Vc2VyUm9sZVIE'
        'cm9sZRIYCgdkZWxldGVkGAcgASgIUgdkZWxldGVkEhYKBmxvY2FsZRgIIAEoCVIGbG9jYWxlEh'
        'oKCHRpbWV6b25lGAkgASgJUgh0aW1lem9uZQ==');

@$core.Deprecated('Use updateUserRequestDescriptor instead')
const UpdateUserRequest$json = {
  '1': 'UpdateUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'phone'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 6, '4': 1, '5': 8, '10': 'deleted'},
    {'1': 'status', '3': 7, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `UpdateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserRequestDescriptor =
    $convert.base64Decode('ChFVcGRhdGVVc2VyUmVxdWVzdBIkCgJpZBgBIAEoCzIKLmNvcmUuVVVJREII+kIFigECEAFSAm'
        'lkEh4KBG5hbWUYAiABKAlCCvpCB3IFEAEY/wFSBG5hbWUSHgoFZW1haWwYAyABKAlCCPpCBXID'
        'GP4BUgVlbWFpbBIdCgVwaG9uZRgEIAEoCUIH+kIEcgIYEFIFcGhvbmUSIgoEcm9sZRgFIAEoDj'
        'IOLmF1dGguVXNlclJvbGVSBHJvbGUSGAoHZGVsZXRlZBgGIAEoCFIHZGVsZXRlZBIWCgZzdGF0'
        'dXMYByABKAlSBnN0YXR1cw==');

@$core.Deprecated('Use getAvatarUploadUrlRequestDescriptor instead')
const GetAvatarUploadUrlRequest$json = {
  '1': 'GetAvatarUploadUrlRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
    {'1': 'content_type', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'contentType'},
    {'1': 'content_size', '3': 3, '4': 1, '5': 4, '8': {}, '10': 'contentSize'},
  ],
};

/// Descriptor for `GetAvatarUploadUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAvatarUploadUrlRequestDescriptor =
    $convert.base64Decode('ChlHZXRBdmF0YXJVcGxvYWRVcmxSZXF1ZXN0Ei0KB3VzZXJfaWQYASABKAsyCi5jb3JlLlVVSU'
        'RCCPpCBYoBAhABUgZ1c2VySWQSSwoMY29udGVudF90eXBlGAIgASgJQij6QiVyI1IKaW1hZ2Uv'
        'anBlZ1IJaW1hZ2UvcG5nUgppbWFnZS93ZWJwUgtjb250ZW50VHlwZRIvCgxjb250ZW50X3Npem'
        'UYAyABKARCDPpCCTIHGICAgAUgAFILY29udGVudFNpemU=');

@$core.Deprecated('Use avatarUploadUrlDescriptor instead')
const AvatarUploadUrl$json = {
  '1': 'AvatarUploadUrl',
  '2': [
    {'1': 'upload_url', '3': 1, '4': 1, '5': 9, '10': 'uploadUrl'},
    {'1': 'expires_in', '3': 2, '4': 1, '5': 4, '10': 'expiresIn'},
  ],
};

/// Descriptor for `AvatarUploadUrl`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List avatarUploadUrlDescriptor =
    $convert.base64Decode('Cg9BdmF0YXJVcGxvYWRVcmwSHQoKdXBsb2FkX3VybBgBIAEoCVIJdXBsb2FkVXJsEh0KCmV4cG'
        'lyZXNfaW4YAiABKARSCWV4cGlyZXNJbg==');

@$core.Deprecated('Use confirmAvatarUploadRequestDescriptor instead')
const ConfirmAvatarUploadRequest$json = {
  '1': 'ConfirmAvatarUploadRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
  ],
};

/// Descriptor for `ConfirmAvatarUploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmAvatarUploadRequestDescriptor =
    $convert.base64Decode('ChpDb25maXJtQXZhdGFyVXBsb2FkUmVxdWVzdBItCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVU'
        'lEQgj6QgWKAQIQAVIGdXNlcklk');
