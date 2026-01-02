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

@$core.Deprecated('Use userRoleDescriptor instead')
const UserRole$json = {
  '1': 'UserRole',
  '2': [
    {'1': 'ADMINISTRATOR', '2': 0},
    {'1': 'USER', '2': 1},
  ],
};

/// Descriptor for `UserRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userRoleDescriptor =
    $convert.base64Decode('CghVc2VyUm9sZRIRCg1BRE1JTklTVFJBVE9SEAASCAoEVVNFUhAB');

@$core.Deprecated('Use resetPasswordRequestDescriptor instead')
const ResetPasswordRequest$json = {
  '1': 'ResetPasswordRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'email'},
  ],
};

/// Descriptor for `ResetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resetPasswordRequestDescriptor =
    $convert.base64Decode('ChRSZXNldFBhc3N3b3JkUmVxdWVzdBIdCgVlbWFpbBgBIAEoCUIH+kIEcgJgAVIFZW1haWw=');

@$core.Deprecated('Use setPasswordRequestDescriptor instead')
const SetPasswordRequest$json = {
  '1': 'SetPasswordRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'password'},
  ],
};

/// Descriptor for `SetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPasswordRequestDescriptor =
    $convert.base64Decode('ChJTZXRQYXNzd29yZFJlcXVlc3QSLQoHdXNlcl9pZBgBIAEoCzIKLmNvcmUuVVVJREII+kIFig'
        'ECEAFSBnVzZXJJZBIdCgVlbWFpbBgCIAEoCUIH+kIEcgJgAVIFZW1haWwSIwoIcGFzc3dvcmQY'
        'AyABKAlCB/pCBHICEAVSCHBhc3N3b3Jk');

@$core.Deprecated('Use signInRequestDescriptor instead')
const SignInRequest$json = {
  '1': 'SignInRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'installation_id', '3': 3, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'installationId'},
    {'1': 'device_info', '3': 4, '4': 1, '5': 11, '6': '.auth.DeviceInfo', '8': {}, '10': 'deviceInfo'},
  ],
};

/// Descriptor for `SignInRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signInRequestDescriptor =
    $convert.base64Decode('Cg1TaWduSW5SZXF1ZXN0Eh0KBWVtYWlsGAEgASgJQgf6QgRyAmABUgVlbWFpbBIjCghwYXNzd2'
        '9yZBgCIAEoCUIH+kIEcgIQBVIIcGFzc3dvcmQSPQoPaW5zdGFsbGF0aW9uX2lkGAMgASgLMgou'
        'Y29yZS5VVUlEQgj6QgWKAQIQAVIOaW5zdGFsbGF0aW9uSWQSOwoLZGV2aWNlX2luZm8YBCABKA'
        'syEC5hdXRoLkRldmljZUluZm9CCPpCBYoBAhABUgpkZXZpY2VJbmZv');

@$core.Deprecated('Use loadUsersInfoRequestDescriptor instead')
const LoadUsersInfoRequest$json = {
  '1': 'LoadUsersInfoRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 11, '6': '.core.UUID', '10': 'userIds'},
  ],
};

/// Descriptor for `LoadUsersInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadUsersInfoRequestDescriptor =
    $convert.base64Decode('ChRMb2FkVXNlcnNJbmZvUmVxdWVzdBIjCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVUlEUgZ1c2'
        'VySWQSJQoIdXNlcl9pZHMYAiADKAsyCi5jb3JlLlVVSURSB3VzZXJJZHM=');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'id'},
    {'1': 'model', '3': 2, '4': 1, '5': 9, '10': 'model'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'os_info', '3': 4, '4': 1, '5': 11, '6': '.auth.OsInfo', '10': 'osInfo'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor =
    $convert.base64Decode('CgpEZXZpY2VJbmZvEiQKAmlkGAEgASgLMgouY29yZS5VVUlEQgj6QgWKAQIQAVICaWQSFAoFbW'
        '9kZWwYAiABKAlSBW1vZGVsEhIKBG5hbWUYAyABKAlSBG5hbWUSJQoHb3NfaW5mbxgEIAEoCzIM'
        'LmF1dGguT3NJbmZvUgZvc0luZm8=');

@$core.Deprecated('Use osInfoDescriptor instead')
const OsInfo$json = {
  '1': 'OsInfo',
  '2': [
    {'1': 'os', '3': 1, '4': 1, '5': 9, '10': 'os'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
  ],
};

/// Descriptor for `OsInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List osInfoDescriptor =
    $convert.base64Decode('CgZPc0luZm8SDgoCb3MYASABKAlSAm9zEhgKB3ZlcnNpb24YAiABKAlSB3ZlcnNpb24=');

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

@$core.Deprecated('Use authInfoDescriptor instead')
const AuthInfo$json = {
  '1': 'AuthInfo',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'user_name', '3': 2, '4': 1, '5': 9, '10': 'userName'},
    {'1': 'user_role', '3': 3, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'userRole'},
    {'1': 'refresh_token', '3': 4, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_token', '3': 5, '4': 1, '5': 9, '10': 'accessToken'},
  ],
};

/// Descriptor for `AuthInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authInfoDescriptor =
    $convert.base64Decode('CghBdXRoSW5mbxIjCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVUlEUgZ1c2VySWQSGwoJdXNlcl'
        '9uYW1lGAIgASgJUgh1c2VyTmFtZRIrCgl1c2VyX3JvbGUYAyABKA4yDi5hdXRoLlVzZXJSb2xl'
        'Ugh1c2VyUm9sZRIjCg1yZWZyZXNoX3Rva2VuGAQgASgJUgxyZWZyZXNoVG9rZW4SIQoMYWNjZX'
        'NzX3Rva2VuGAUgASgJUgthY2Nlc3NUb2tlbg==');

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 5, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor =
    $convert.base64Decode('CghVc2VySW5mbxIaCgJpZBgBIAEoCzIKLmNvcmUuVVVJRFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
        'FtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSIgoEcm9sZRgEIAEoDjIOLmF1dGguVXNlclJvbGVS'
        'BHJvbGUSGAoHZGVsZXRlZBgFIAEoCFIHZGVsZXRlZA==');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 5, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor =
    $convert.base64Decode('CgRVc2VyEhoKAmlkGAEgASgLMgouY29yZS5VVUlEUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
        'QKBWVtYWlsGAMgASgJUgVlbWFpbBIiCgRyb2xlGAQgASgOMg4uYXV0aC5Vc2VyUm9sZVIEcm9s'
        'ZRIYCgdkZWxldGVkGAUgASgIUgdkZWxldGVk');

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
    {'1': 'password', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 6, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `CreateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserRequestDescriptor =
    $convert.base64Decode('ChFDcmVhdGVVc2VyUmVxdWVzdBIkCgJpZBgBIAEoCzIKLmNvcmUuVVVJREII+kIFigECEAFSAm'
        'lkEh4KBG5hbWUYAiABKAlCCvpCB3IFEAEY/wFSBG5hbWUSHQoFZW1haWwYAyABKAlCB/pCBHIC'
        'YAFSBWVtYWlsEiMKCHBhc3N3b3JkGAQgASgJQgf6QgRyAhAFUghwYXNzd29yZBIiCgRyb2xlGA'
        'UgASgOMg4uYXV0aC5Vc2VyUm9sZVIEcm9sZRIYCgdkZWxldGVkGAYgASgIUgdkZWxldGVk');

@$core.Deprecated('Use updateUserRequestDescriptor instead')
const UpdateUserRequest$json = {
  '1': 'UpdateUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 5, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `UpdateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserRequestDescriptor =
    $convert.base64Decode('ChFVcGRhdGVVc2VyUmVxdWVzdBIkCgJpZBgBIAEoCzIKLmNvcmUuVVVJREII+kIFigECEAFSAm'
        'lkEh4KBG5hbWUYAiABKAlCCvpCB3IFEAEY/wFSBG5hbWUSHQoFZW1haWwYAyABKAlCB/pCBHIC'
        'YAFSBWVtYWlsEiIKBHJvbGUYBCABKA4yDi5hdXRoLlVzZXJSb2xlUgRyb2xlEhgKB2RlbGV0ZW'
        'QYBSABKAhSB2RlbGV0ZWQ=');
