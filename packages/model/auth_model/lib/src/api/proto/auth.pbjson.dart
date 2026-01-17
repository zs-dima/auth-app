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

@$core.Deprecated('Use tokenPairDescriptor instead')
const TokenPair$json = {
  '1': 'TokenPair',
  '2': [
    {'1': 'access_token', '3': 1, '4': 1, '5': 9, '10': 'accessToken'},
    {'1': 'refresh_token', '3': 2, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiresAt'},
  ],
};

/// Descriptor for `TokenPair`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tokenPairDescriptor =
    $convert.base64Decode('CglUb2tlblBhaXISIQoMYWNjZXNzX3Rva2VuGAEgASgJUgthY2Nlc3NUb2tlbhIjCg1yZWZyZX'
        'NoX3Rva2VuGAIgASgJUgxyZWZyZXNoVG9rZW4SOQoKZXhwaXJlc19hdBgDIAEoCzIaLmdvb2ds'
        'ZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWV4cGlyZXNBdA==');

@$core.Deprecated('Use clientInfoDescriptor instead')
const ClientInfo$json = {
  '1': 'ClientInfo',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'deviceId'},
    {'1': 'device_name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'deviceName'},
    {'1': 'device_type', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'deviceType'},
    {'1': 'client_version', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'clientVersion'},
    {'1': 'metadata', '3': 5, '4': 3, '5': 11, '6': '.auth.ClientInfo.MetadataEntry', '10': 'metadata'},
  ],
  '3': [ClientInfo_MetadataEntry$json],
};

@$core.Deprecated('Use clientInfoDescriptor instead')
const ClientInfo_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ClientInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List clientInfoDescriptor =
    $convert.base64Decode('CgpDbGllbnRJbmZvEicKCWRldmljZV9pZBgBIAEoCUIK+kIHcgUQARj/AVIIZGV2aWNlSWQSKQ'
        'oLZGV2aWNlX25hbWUYAiABKAlCCPpCBXIDGP8BUgpkZXZpY2VOYW1lEigKC2RldmljZV90eXBl'
        'GAMgASgJQgf6QgRyAhgyUgpkZXZpY2VUeXBlEi4KDmNsaWVudF92ZXJzaW9uGAQgASgJQgf6Qg'
        'RyAhhkUg1jbGllbnRWZXJzaW9uEjoKCG1ldGFkYXRhGAUgAygLMh4uYXV0aC5DbGllbnRJbmZv'
        'Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUg'
        'NrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use userSnapshotDescriptor instead')
const UserSnapshot$json = {
  '1': 'UserSnapshot',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'display_name', '3': 2, '4': 1, '5': 9, '10': 'displayName'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.UserRole', '10': 'role'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.core.UserStatus', '10': 'status'},
    {'1': 'email_verified', '3': 7, '4': 1, '5': 8, '10': 'emailVerified'},
    {'1': 'phone_verified', '3': 8, '4': 1, '5': 8, '10': 'phoneVerified'},
    {'1': 'mfa_enabled', '3': 9, '4': 1, '5': 8, '10': 'mfaEnabled'},
    {'1': 'linked_providers', '3': 10, '4': 3, '5': 14, '6': '.auth.OAuthProvider', '10': 'linkedProviders'},
    {'1': 'avatar_url', '3': 11, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'has_password', '3': 12, '4': 1, '5': 8, '10': 'hasPassword'},
  ],
};

/// Descriptor for `UserSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userSnapshotDescriptor =
    $convert.base64Decode('CgxVc2VyU25hcHNob3QSIwoHdXNlcl9pZBgBIAEoCzIKLmNvcmUuVVVJRFIGdXNlcklkEiEKDG'
        'Rpc3BsYXlfbmFtZRgCIAEoCVILZGlzcGxheU5hbWUSFAoFZW1haWwYAyABKAlSBWVtYWlsEhQK'
        'BXBob25lGAQgASgJUgVwaG9uZRIiCgRyb2xlGAUgASgOMg4uY29yZS5Vc2VyUm9sZVIEcm9sZR'
        'IoCgZzdGF0dXMYBiABKA4yEC5jb3JlLlVzZXJTdGF0dXNSBnN0YXR1cxIlCg5lbWFpbF92ZXJp'
        'ZmllZBgHIAEoCFINZW1haWxWZXJpZmllZBIlCg5waG9uZV92ZXJpZmllZBgIIAEoCFINcGhvbm'
        'VWZXJpZmllZBIfCgttZmFfZW5hYmxlZBgJIAEoCFIKbWZhRW5hYmxlZBI+ChBsaW5rZWRfcHJv'
        'dmlkZXJzGAogAygOMhMuYXV0aC5PQXV0aFByb3ZpZGVyUg9saW5rZWRQcm92aWRlcnMSHQoKYX'
        'ZhdGFyX3VybBgLIAEoCVIJYXZhdGFyVXJsEiEKDGhhc19wYXNzd29yZBgMIAEoCFILaGFzUGFz'
        'c3dvcmQ=');

@$core.Deprecated('Use lockoutInfoDescriptor instead')
const LockoutInfo$json = {
  '1': 'LockoutInfo',
  '2': [
    {'1': 'retry_after', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Duration', '10': 'retryAfter'},
    {'1': 'failed_attempts', '3': 2, '4': 1, '5': 5, '10': 'failedAttempts'},
    {'1': 'max_attempts', '3': 3, '4': 1, '5': 5, '10': 'maxAttempts'},
    {'1': 'locked_until', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lockedUntil'},
  ],
};

/// Descriptor for `LockoutInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List lockoutInfoDescriptor =
    $convert.base64Decode('CgtMb2Nrb3V0SW5mbxI6CgtyZXRyeV9hZnRlchgBIAEoCzIZLmdvb2dsZS5wcm90b2J1Zi5EdX'
        'JhdGlvblIKcmV0cnlBZnRlchInCg9mYWlsZWRfYXR0ZW1wdHMYAiABKAVSDmZhaWxlZEF0dGVt'
        'cHRzEiEKDG1heF9hdHRlbXB0cxgDIAEoBVILbWF4QXR0ZW1wdHMSPQoMbG9ja2VkX3VudGlsGA'
        'QgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILbG9ja2VkVW50aWw=');

@$core.Deprecated('Use mfaChallengeDescriptor instead')
const MfaChallenge$json = {
  '1': 'MfaChallenge',
  '2': [
    {'1': 'challenge_token', '3': 1, '4': 1, '5': 9, '10': 'challengeToken'},
    {'1': 'available_methods', '3': 2, '4': 3, '5': 11, '6': '.auth.MfaMethodInfo', '10': 'availableMethods'},
    {'1': 'expires_at', '3': 3, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiresAt'},
  ],
};

/// Descriptor for `MfaChallenge`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaChallengeDescriptor =
    $convert.base64Decode('CgxNZmFDaGFsbGVuZ2USJwoPY2hhbGxlbmdlX3Rva2VuGAEgASgJUg5jaGFsbGVuZ2VUb2tlbh'
        'JAChFhdmFpbGFibGVfbWV0aG9kcxgCIAMoCzITLmF1dGguTWZhTWV0aG9kSW5mb1IQYXZhaWxh'
        'YmxlTWV0aG9kcxI5CgpleHBpcmVzX2F0GAMgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
        'FtcFIJZXhwaXJlc0F0');

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

@$core.Deprecated('Use authResponseDescriptor instead')
const AuthResponse$json = {
  '1': 'AuthResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.auth.AuthStatus', '10': 'status'},
    {'1': 'tokens', '3': 2, '4': 1, '5': 11, '6': '.auth.TokenPair', '10': 'tokens'},
    {'1': 'user', '3': 3, '4': 1, '5': 11, '6': '.auth.UserSnapshot', '10': 'user'},
    {'1': 'mfa_challenge', '3': 4, '4': 1, '5': 11, '6': '.auth.MfaChallenge', '10': 'mfaChallenge'},
    {'1': 'lockout_info', '3': 5, '4': 1, '5': 11, '6': '.auth.LockoutInfo', '10': 'lockoutInfo'},
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `AuthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authResponseDescriptor =
    $convert.base64Decode('CgxBdXRoUmVzcG9uc2USKAoGc3RhdHVzGAEgASgOMhAuYXV0aC5BdXRoU3RhdHVzUgZzdGF0dX'
        'MSJwoGdG9rZW5zGAIgASgLMg8uYXV0aC5Ub2tlblBhaXJSBnRva2VucxImCgR1c2VyGAMgASgL'
        'MhIuYXV0aC5Vc2VyU25hcHNob3RSBHVzZXISNwoNbWZhX2NoYWxsZW5nZRgEIAEoCzISLmF1dG'
        'guTWZhQ2hhbGxlbmdlUgxtZmFDaGFsbGVuZ2USNAoMbG9ja291dF9pbmZvGAUgASgLMhEuYXV0'
        'aC5Mb2Nrb3V0SW5mb1ILbG9ja291dEluZm8SGAoHbWVzc2FnZRgGIAEoCVIHbWVzc2FnZQ==');

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

@$core.Deprecated('Use verifyMfaRequestDescriptor instead')
const VerifyMfaRequest$json = {
  '1': 'VerifyMfaRequest',
  '2': [
    {'1': 'challenge_token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'challengeToken'},
    {'1': 'method', '3': 2, '4': 1, '5': 14, '6': '.auth.MfaMethod', '8': {}, '10': 'method'},
    {'1': 'code', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'code'},
    {'1': 'client_info', '3': 4, '4': 1, '5': 11, '6': '.auth.ClientInfo', '10': 'clientInfo'},
  ],
};

/// Descriptor for `VerifyMfaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyMfaRequestDescriptor =
    $convert.base64Decode('ChBWZXJpZnlNZmFSZXF1ZXN0EjAKD2NoYWxsZW5nZV90b2tlbhgBIAEoCUIH+kIEcgIQAVIOY2'
        'hhbGxlbmdlVG9rZW4SMQoGbWV0aG9kGAIgASgOMg8uYXV0aC5NZmFNZXRob2RCCPpCBYIBAiAA'
        'UgZtZXRob2QSHQoEY29kZRgDIAEoCUIJ+kIGcgQQBhggUgRjb2RlEjEKC2NsaWVudF9pbmZvGA'
        'QgASgLMhAuYXV0aC5DbGllbnRJbmZvUgpjbGllbnRJbmZv');

@$core.Deprecated('Use refreshTokensRequestDescriptor instead')
const RefreshTokensRequest$json = {
  '1': 'RefreshTokensRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokensRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokensRequestDescriptor =
    $convert.base64Decode('ChRSZWZyZXNoVG9rZW5zUmVxdWVzdBIsCg1yZWZyZXNoX3Rva2VuGAEgASgJQgf6QgRyAhABUg'
        'xyZWZyZXNoVG9rZW4=');

@$core.Deprecated('Use validateCredentialsRequestDescriptor instead')
const ValidateCredentialsRequest$json = {
  '1': 'ValidateCredentialsRequest',
};

/// Descriptor for `ValidateCredentialsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateCredentialsRequestDescriptor =
    $convert.base64Decode('ChpWYWxpZGF0ZUNyZWRlbnRpYWxzUmVxdWVzdA==');

@$core.Deprecated('Use validateCredentialsResponseDescriptor instead')
const ValidateCredentialsResponse$json = {
  '1': 'ValidateCredentialsResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
    {'1': 'user', '3': 2, '4': 1, '5': 11, '6': '.auth.UserSnapshot', '10': 'user'},
  ],
};

/// Descriptor for `ValidateCredentialsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List validateCredentialsResponseDescriptor =
    $convert.base64Decode('ChtWYWxpZGF0ZUNyZWRlbnRpYWxzUmVzcG9uc2USFAoFdmFsaWQYASABKAhSBXZhbGlkEiYKBH'
        'VzZXIYAiABKAsyEi5hdXRoLlVzZXJTbmFwc2hvdFIEdXNlcg==');

@$core.Deprecated('Use signOutRequestDescriptor instead')
const SignOutRequest$json = {
  '1': 'SignOutRequest',
};

/// Descriptor for `SignOutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signOutRequestDescriptor = $convert.base64Decode('Cg5TaWduT3V0UmVxdWVzdA==');

@$core.Deprecated('Use getOAuthUrlRequestDescriptor instead')
const GetOAuthUrlRequest$json = {
  '1': 'GetOAuthUrlRequest',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 14, '6': '.auth.OAuthProvider', '8': {}, '10': 'provider'},
    {'1': 'redirect_uri', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'redirectUri'},
    {'1': 'scopes', '3': 3, '4': 3, '5': 9, '10': 'scopes'},
    {'1': 'state_data', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'stateData'},
  ],
};

/// Descriptor for `GetOAuthUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOAuthUrlRequestDescriptor =
    $convert.base64Decode('ChJHZXRPQXV0aFVybFJlcXVlc3QSOQoIcHJvdmlkZXIYASABKA4yEy5hdXRoLk9BdXRoUHJvdm'
        'lkZXJCCPpCBYIBAiAAUghwcm92aWRlchIrCgxyZWRpcmVjdF91cmkYAiABKAlCCPpCBXIDGIAQ'
        'UgtyZWRpcmVjdFVyaRIWCgZzY29wZXMYAyADKAlSBnNjb3BlcxInCgpzdGF0ZV9kYXRhGAQgAS'
        'gJQgj6QgVyAxiACFIJc3RhdGVEYXRh');

@$core.Deprecated('Use getOAuthUrlResponseDescriptor instead')
const GetOAuthUrlResponse$json = {
  '1': 'GetOAuthUrlResponse',
  '2': [
    {'1': 'authorization_url', '3': 1, '4': 1, '5': 9, '10': 'authorizationUrl'},
    {'1': 'state', '3': 2, '4': 1, '5': 9, '10': 'state'},
  ],
};

/// Descriptor for `GetOAuthUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getOAuthUrlResponseDescriptor =
    $convert.base64Decode('ChNHZXRPQXV0aFVybFJlc3BvbnNlEisKEWF1dGhvcml6YXRpb25fdXJsGAEgASgJUhBhdXRob3'
        'JpemF0aW9uVXJsEhQKBXN0YXRlGAIgASgJUgVzdGF0ZQ==');

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
    {'1': 'provider', '3': 1, '4': 1, '5': 14, '6': '.auth.OAuthProvider', '8': {}, '10': 'provider'},
  ],
};

/// Descriptor for `UnlinkOAuthProviderRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unlinkOAuthProviderRequestDescriptor =
    $convert.base64Decode('ChpVbmxpbmtPQXV0aFByb3ZpZGVyUmVxdWVzdBI5Cghwcm92aWRlchgBIAEoDjITLmF1dGguT0'
        'F1dGhQcm92aWRlckII+kIFggECIABSCHByb3ZpZGVy');

@$core.Deprecated('Use listLinkedProvidersRequestDescriptor instead')
const ListLinkedProvidersRequest$json = {
  '1': 'ListLinkedProvidersRequest',
};

/// Descriptor for `ListLinkedProvidersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLinkedProvidersRequestDescriptor =
    $convert.base64Decode('ChpMaXN0TGlua2VkUHJvdmlkZXJzUmVxdWVzdA==');

@$core.Deprecated('Use listLinkedProvidersResponseDescriptor instead')
const ListLinkedProvidersResponse$json = {
  '1': 'ListLinkedProvidersResponse',
  '2': [
    {'1': 'providers', '3': 1, '4': 3, '5': 11, '6': '.auth.LinkedProvider', '10': 'providers'},
  ],
};

/// Descriptor for `ListLinkedProvidersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLinkedProvidersResponseDescriptor =
    $convert.base64Decode('ChtMaXN0TGlua2VkUHJvdmlkZXJzUmVzcG9uc2USMgoJcHJvdmlkZXJzGAEgAygLMhQuYXV0aC'
        '5MaW5rZWRQcm92aWRlclIJcHJvdmlkZXJz');

@$core.Deprecated('Use linkedProviderDescriptor instead')
const LinkedProvider$json = {
  '1': 'LinkedProvider',
  '2': [
    {'1': 'provider', '3': 1, '4': 1, '5': 14, '6': '.auth.OAuthProvider', '10': 'provider'},
    {'1': 'provider_user_id', '3': 2, '4': 1, '5': 9, '10': 'providerUserId'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'linked_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'linkedAt'},
  ],
};

/// Descriptor for `LinkedProvider`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List linkedProviderDescriptor =
    $convert.base64Decode('Cg5MaW5rZWRQcm92aWRlchIvCghwcm92aWRlchgBIAEoDjITLmF1dGguT0F1dGhQcm92aWRlcl'
        'IIcHJvdmlkZXISKAoQcHJvdmlkZXJfdXNlcl9pZBgCIAEoCVIOcHJvdmlkZXJVc2VySWQSFAoF'
        'ZW1haWwYAyABKAlSBWVtYWlsEjcKCWxpbmtlZF9hdBgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
        '5UaW1lc3RhbXBSCGxpbmtlZEF0');

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

@$core.Deprecated('Use requestVerificationRequestDescriptor instead')
const RequestVerificationRequest$json = {
  '1': 'RequestVerificationRequest',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.auth.VerificationType', '8': {}, '10': 'type'},
  ],
};

/// Descriptor for `RequestVerificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestVerificationRequestDescriptor =
    $convert.base64Decode('ChpSZXF1ZXN0VmVyaWZpY2F0aW9uUmVxdWVzdBI0CgR0eXBlGAEgASgOMhYuYXV0aC5WZXJpZm'
        'ljYXRpb25UeXBlQgj6QgWCAQIgAFIEdHlwZQ==');

@$core.Deprecated('Use confirmVerificationRequestDescriptor instead')
const ConfirmVerificationRequest$json = {
  '1': 'ConfirmVerificationRequest',
  '2': [
    {'1': 'token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'token'},
    {'1': 'type', '3': 2, '4': 1, '5': 14, '6': '.auth.VerificationType', '8': {}, '10': 'type'},
  ],
};

/// Descriptor for `ConfirmVerificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmVerificationRequestDescriptor =
    $convert.base64Decode('ChpDb25maXJtVmVyaWZpY2F0aW9uUmVxdWVzdBIdCgV0b2tlbhgBIAEoCUIH+kIEcgIQAVIFdG'
        '9rZW4SNAoEdHlwZRgCIAEoDjIWLmF1dGguVmVyaWZpY2F0aW9uVHlwZUII+kIFggECIABSBHR5'
        'cGU=');

@$core.Deprecated('Use getMfaStatusRequestDescriptor instead')
const GetMfaStatusRequest$json = {
  '1': 'GetMfaStatusRequest',
};

/// Descriptor for `GetMfaStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMfaStatusRequestDescriptor = $convert.base64Decode('ChNHZXRNZmFTdGF0dXNSZXF1ZXN0');

@$core.Deprecated('Use getMfaStatusResponseDescriptor instead')
const GetMfaStatusResponse$json = {
  '1': 'GetMfaStatusResponse',
  '2': [
    {'1': 'enabled', '3': 1, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'methods', '3': 2, '4': 3, '5': 11, '6': '.auth.MfaMethodStatus', '10': 'methods'},
    {'1': 'recovery_codes_remaining', '3': 3, '4': 1, '5': 5, '10': 'recoveryCodesRemaining'},
  ],
};

/// Descriptor for `GetMfaStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getMfaStatusResponseDescriptor =
    $convert.base64Decode('ChRHZXRNZmFTdGF0dXNSZXNwb25zZRIYCgdlbmFibGVkGAEgASgIUgdlbmFibGVkEi8KB21ldG'
        'hvZHMYAiADKAsyFS5hdXRoLk1mYU1ldGhvZFN0YXR1c1IHbWV0aG9kcxI4ChhyZWNvdmVyeV9j'
        'b2Rlc19yZW1haW5pbmcYAyABKAVSFnJlY292ZXJ5Q29kZXNSZW1haW5pbmc=');

@$core.Deprecated('Use mfaMethodStatusDescriptor instead')
const MfaMethodStatus$json = {
  '1': 'MfaMethodStatus',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 14, '6': '.auth.MfaMethod', '10': 'method'},
    {'1': 'enabled', '3': 2, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'hint', '3': 3, '4': 1, '5': 9, '10': 'hint'},
    {'1': 'configured_at', '3': 4, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'configuredAt'},
  ],
};

/// Descriptor for `MfaMethodStatus`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaMethodStatusDescriptor =
    $convert.base64Decode('Cg9NZmFNZXRob2RTdGF0dXMSJwoGbWV0aG9kGAEgASgOMg8uYXV0aC5NZmFNZXRob2RSBm1ldG'
        'hvZBIYCgdlbmFibGVkGAIgASgIUgdlbmFibGVkEhIKBGhpbnQYAyABKAlSBGhpbnQSPwoNY29u'
        'ZmlndXJlZF9hdBgEIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDGNvbmZpZ3VyZW'
        'RBdA==');

@$core.Deprecated('Use setupMfaRequestDescriptor instead')
const SetupMfaRequest$json = {
  '1': 'SetupMfaRequest',
  '2': [
    {'1': 'method', '3': 1, '4': 1, '5': 14, '6': '.auth.MfaMethod', '8': {}, '10': 'method'},
    {'1': 'identifier', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'identifier'},
  ],
};

/// Descriptor for `SetupMfaRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setupMfaRequestDescriptor =
    $convert.base64Decode('Cg9TZXR1cE1mYVJlcXVlc3QSMQoGbWV0aG9kGAEgASgOMg8uYXV0aC5NZmFNZXRob2RCCPpCBY'
        'IBAiAAUgZtZXRob2QSKAoKaWRlbnRpZmllchgCIAEoCUII+kIFcgMY/gFSCmlkZW50aWZpZXI=');

@$core.Deprecated('Use setupMfaResponseDescriptor instead')
const SetupMfaResponse$json = {
  '1': 'SetupMfaResponse',
  '2': [
    {'1': 'secret', '3': 1, '4': 1, '5': 9, '10': 'secret'},
    {'1': 'provisioning_uri', '3': 2, '4': 1, '5': 9, '10': 'provisioningUri'},
    {'1': 'masked_destination', '3': 3, '4': 1, '5': 9, '10': 'maskedDestination'},
    {'1': 'setup_token', '3': 4, '4': 1, '5': 9, '10': 'setupToken'},
    {'1': 'expires_at', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiresAt'},
  ],
};

/// Descriptor for `SetupMfaResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setupMfaResponseDescriptor =
    $convert.base64Decode('ChBTZXR1cE1mYVJlc3BvbnNlEhYKBnNlY3JldBgBIAEoCVIGc2VjcmV0EikKEHByb3Zpc2lvbm'
        'luZ191cmkYAiABKAlSD3Byb3Zpc2lvbmluZ1VyaRItChJtYXNrZWRfZGVzdGluYXRpb24YAyAB'
        'KAlSEW1hc2tlZERlc3RpbmF0aW9uEh8KC3NldHVwX3Rva2VuGAQgASgJUgpzZXR1cFRva2VuEj'
        'kKCmV4cGlyZXNfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglleHBpcmVz'
        'QXQ=');

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

@$core.Deprecated('Use confirmMfaSetupResponseDescriptor instead')
const ConfirmMfaSetupResponse$json = {
  '1': 'ConfirmMfaSetupResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 11, '6': '.auth.MfaSetupSuccess', '9': 0, '10': 'success'},
    {'1': 'error', '3': 2, '4': 1, '5': 11, '6': '.auth.MfaSetupError', '9': 0, '10': 'error'},
  ],
  '8': [
    {'1': 'result'},
  ],
};

/// Descriptor for `ConfirmMfaSetupResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmMfaSetupResponseDescriptor =
    $convert.base64Decode('ChdDb25maXJtTWZhU2V0dXBSZXNwb25zZRIxCgdzdWNjZXNzGAEgASgLMhUuYXV0aC5NZmFTZX'
        'R1cFN1Y2Nlc3NIAFIHc3VjY2VzcxIrCgVlcnJvchgCIAEoCzITLmF1dGguTWZhU2V0dXBFcnJv'
        'ckgAUgVlcnJvckIICgZyZXN1bHQ=');

@$core.Deprecated('Use mfaSetupSuccessDescriptor instead')
const MfaSetupSuccess$json = {
  '1': 'MfaSetupSuccess',
  '2': [
    {'1': 'recovery_codes', '3': 1, '4': 3, '5': 9, '10': 'recoveryCodes'},
  ],
};

/// Descriptor for `MfaSetupSuccess`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaSetupSuccessDescriptor =
    $convert.base64Decode('Cg9NZmFTZXR1cFN1Y2Nlc3MSJQoOcmVjb3ZlcnlfY29kZXMYASADKAlSDXJlY292ZXJ5Q29kZX'
        'M=');

@$core.Deprecated('Use mfaSetupErrorDescriptor instead')
const MfaSetupError$json = {
  '1': 'MfaSetupError',
  '2': [
    {'1': 'message', '3': 1, '4': 1, '5': 9, '10': 'message'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
  ],
};

/// Descriptor for `MfaSetupError`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mfaSetupErrorDescriptor =
    $convert.base64Decode('Cg1NZmFTZXR1cEVycm9yEhgKB21lc3NhZ2UYASABKAlSB21lc3NhZ2USEgoEY29kZRgCIAEoCV'
        'IEY29kZQ==');

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

@$core.Deprecated('Use listSessionsRequestDescriptor instead')
const ListSessionsRequest$json = {
  '1': 'ListSessionsRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'refreshToken'},
  ],
};

/// Descriptor for `ListSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsRequestDescriptor =
    $convert.base64Decode('ChNMaXN0U2Vzc2lvbnNSZXF1ZXN0EiwKDXJlZnJlc2hfdG9rZW4YASABKAlCB/pCBHICEAFSDH'
        'JlZnJlc2hUb2tlbg==');

@$core.Deprecated('Use listSessionsResponseDescriptor instead')
const ListSessionsResponse$json = {
  '1': 'ListSessionsResponse',
  '2': [
    {'1': 'sessions', '3': 1, '4': 3, '5': 11, '6': '.auth.SessionInfo', '10': 'sessions'},
  ],
};

/// Descriptor for `ListSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSessionsResponseDescriptor =
    $convert.base64Decode('ChRMaXN0U2Vzc2lvbnNSZXNwb25zZRItCghzZXNzaW9ucxgBIAMoCzIRLmF1dGguU2Vzc2lvbk'
        'luZm9SCHNlc3Npb25z');

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
    {'1': 'created_at', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'last_seen_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'lastSeenAt'},
    {'1': 'expires_at', '3': 9, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'expiresAt'},
    {'1': 'is_current', '3': 10, '4': 1, '5': 8, '10': 'isCurrent'},
    {'1': 'ip_created_by', '3': 11, '4': 1, '5': 9, '10': 'ipCreatedBy'},
    {'1': 'activity_count', '3': 12, '4': 1, '5': 5, '10': 'activityCount'},
    {'1': 'metadata', '3': 13, '4': 3, '5': 11, '6': '.auth.SessionInfo.MetadataEntry', '10': 'metadata'},
  ],
  '3': [SessionInfo_MetadataEntry$json],
};

@$core.Deprecated('Use sessionInfoDescriptor instead')
const SessionInfo_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SessionInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sessionInfoDescriptor =
    $convert.base64Decode('CgtTZXNzaW9uSW5mbxIbCglkZXZpY2VfaWQYASABKAlSCGRldmljZUlkEh8KC2RldmljZV9uYW'
        '1lGAIgASgJUgpkZXZpY2VOYW1lEh8KC2RldmljZV90eXBlGAMgASgJUgpkZXZpY2VUeXBlEiUK'
        'DmNsaWVudF92ZXJzaW9uGAQgASgJUg1jbGllbnRWZXJzaW9uEh0KCmlwX2FkZHJlc3MYBSABKA'
        'lSCWlwQWRkcmVzcxIdCgppcF9jb3VudHJ5GAYgASgJUglpcENvdW50cnkSOQoKY3JlYXRlZF9h'
        'dBgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI8CgxsYXN0X3'
        'NlZW5fYXQYCCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgpsYXN0U2VlbkF0EjkK'
        'CmV4cGlyZXNfYXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglleHBpcmVzQX'
        'QSHQoKaXNfY3VycmVudBgKIAEoCFIJaXNDdXJyZW50EiIKDWlwX2NyZWF0ZWRfYnkYCyABKAlS'
        'C2lwQ3JlYXRlZEJ5EiUKDmFjdGl2aXR5X2NvdW50GAwgASgFUg1hY3Rpdml0eUNvdW50EjsKCG'
        '1ldGFkYXRhGA0gAygLMh8uYXV0aC5TZXNzaW9uSW5mby5NZXRhZGF0YUVudHJ5UghtZXRhZGF0'
        'YRo7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YW'
        'x1ZToCOAE=');

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

@$core.Deprecated('Use revokeOtherSessionsRequestDescriptor instead')
const RevokeOtherSessionsRequest$json = {
  '1': 'RevokeOtherSessionsRequest',
};

/// Descriptor for `RevokeOtherSessionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeOtherSessionsRequestDescriptor =
    $convert.base64Decode('ChpSZXZva2VPdGhlclNlc3Npb25zUmVxdWVzdA==');

@$core.Deprecated('Use revokeSessionsResponseDescriptor instead')
const RevokeSessionsResponse$json = {
  '1': 'RevokeSessionsResponse',
  '2': [
    {'1': 'revoked_count', '3': 1, '4': 1, '5': 5, '10': 'revokedCount'},
  ],
};

/// Descriptor for `RevokeSessionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List revokeSessionsResponseDescriptor =
    $convert.base64Decode('ChZSZXZva2VTZXNzaW9uc1Jlc3BvbnNlEiMKDXJldm9rZWRfY291bnQYASABKAVSDHJldm9rZW'
        'RDb3VudA==');
