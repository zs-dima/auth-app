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

@$core.Deprecated('Use oSDescriptor instead')
const OS$json = {
  '1': 'OS',
  '2': [
    {'1': 'FUCHSIA', '2': 0},
    {'1': 'LINUX', '2': 1},
    {'1': 'MACOS', '2': 2},
    {'1': 'WINDOWS', '2': 3},
    {'1': 'IOS', '2': 4},
    {'1': 'ANDROID', '2': 5},
    {'1': 'UNKNOWN', '2': 6},
  ],
};

/// Descriptor for `OS`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List oSDescriptor =
    $convert.base64Decode('CgJPUxILCgdGVUNIU0lBEAASCQoFTElOVVgQARIJCgVNQUNPUxACEgsKB1dJTkRPV1MQAxIHCg'
        'NJT1MQBBILCgdBTkRST0lEEAUSCwoHVU5LTk9XThAG');

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
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
  ],
};

/// Descriptor for `ResetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resetPasswordRequestDescriptor =
    $convert.base64Decode('ChRSZXNldFBhc3N3b3JkUmVxdWVzdBIUCgVlbWFpbBgBIAEoCVIFZW1haWw=');

@$core.Deprecated('Use setPasswordRequestDescriptor instead')
const SetPasswordRequest$json = {
  '1': 'SetPasswordRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 3, '4': 1, '5': 9, '10': 'password'},
  ],
};

/// Descriptor for `SetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPasswordRequestDescriptor =
    $convert.base64Decode('ChJTZXRQYXNzd29yZFJlcXVlc3QSIwoHdXNlcl9pZBgBIAEoCzIKLmNvcmUuVVVJRFIGdXNlck'
        'lkEhQKBWVtYWlsGAIgASgJUgVlbWFpbBIaCghwYXNzd29yZBgDIAEoCVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use loadUserAvatarRequestDescriptor instead')
const LoadUserAvatarRequest$json = {
  '1': 'LoadUserAvatarRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 3, '5': 11, '6': '.core.UUID', '10': 'userId'},
  ],
};

/// Descriptor for `LoadUserAvatarRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List loadUserAvatarRequestDescriptor =
    $convert.base64Decode('ChVMb2FkVXNlckF2YXRhclJlcXVlc3QSIwoHdXNlcl9pZBgBIAMoCzIKLmNvcmUuVVVJRFIGdX'
        'Nlcklk');

@$core.Deprecated('Use signInRequestDescriptor instead')
const SignInRequest$json = {
  '1': 'SignInRequest',
  '2': [
    {'1': 'email', '3': 1, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '10': 'password'},
    {'1': 'installation_id', '3': 3, '4': 1, '5': 11, '6': '.core.UUID', '10': 'installationId'},
    {'1': 'device_info', '3': 4, '4': 1, '5': 11, '6': '.auth.DeviceInfo', '10': 'deviceInfo'},
  ],
};

/// Descriptor for `SignInRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signInRequestDescriptor =
    $convert.base64Decode('Cg1TaWduSW5SZXF1ZXN0EhQKBWVtYWlsGAEgASgJUgVlbWFpbBIaCghwYXNzd29yZBgCIAEoCV'
        'IIcGFzc3dvcmQSMwoPaW5zdGFsbGF0aW9uX2lkGAMgASgLMgouY29yZS5VVUlEUg5pbnN0YWxs'
        'YXRpb25JZBIxCgtkZXZpY2VfaW5mbxgEIAEoCzIQLmF1dGguRGV2aWNlSW5mb1IKZGV2aWNlSW'
        '5mbw==');

@$core.Deprecated('Use deviceInfoDescriptor instead')
const DeviceInfo$json = {
  '1': 'DeviceInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'model', '3': 2, '4': 1, '5': 9, '10': 'model'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'os_info', '3': 4, '4': 1, '5': 11, '6': '.auth.OsInfo', '10': 'osInfo'},
  ],
};

/// Descriptor for `DeviceInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceInfoDescriptor =
    $convert.base64Decode('CgpEZXZpY2VJbmZvEhoKAmlkGAEgASgLMgouY29yZS5VVUlEUgJpZBIUCgVtb2RlbBgCIAEoCV'
        'IFbW9kZWwSEgoEbmFtZRgDIAEoCVIEbmFtZRIlCgdvc19pbmZvGAQgASgLMgwuYXV0aC5Pc0lu'
        'Zm9SBm9zSW5mbw==');

@$core.Deprecated('Use osInfoDescriptor instead')
const OsInfo$json = {
  '1': 'OsInfo',
  '2': [
    {'1': 'os', '3': 1, '4': 1, '5': 14, '6': '.auth.OS', '10': 'os'},
    {'1': 'version', '3': 2, '4': 1, '5': 9, '10': 'version'},
  ],
};

/// Descriptor for `OsInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List osInfoDescriptor =
    $convert.base64Decode('CgZPc0luZm8SGAoCb3MYASABKA4yCC5hdXRoLk9TUgJvcxIYCgd2ZXJzaW9uGAIgASgJUgd2ZX'
        'JzaW9u');

@$core.Deprecated('Use refreshTokenRequestDescriptor instead')
const RefreshTokenRequest$json = {
  '1': 'RefreshTokenRequest',
  '2': [
    {'1': 'refresh_token', '3': 1, '4': 1, '5': 9, '10': 'refreshToken'},
  ],
};

/// Descriptor for `RefreshTokenRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshTokenRequestDescriptor =
    $convert.base64Decode('ChNSZWZyZXNoVG9rZW5SZXF1ZXN0EiMKDXJlZnJlc2hfdG9rZW4YASABKAlSDHJlZnJlc2hUb2'
        'tlbg==');

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
    {'1': 'blurhash', '3': 4, '4': 1, '5': 9, '9': 0, '10': 'blurhash', '17': true},
    {'1': 'refresh_token', '3': 5, '4': 1, '5': 9, '10': 'refreshToken'},
    {'1': 'access_token', '3': 6, '4': 1, '5': 9, '10': 'accessToken'},
  ],
  '8': [
    {'1': '_blurhash'},
  ],
};

/// Descriptor for `AuthInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List authInfoDescriptor =
    $convert.base64Decode('CghBdXRoSW5mbxIjCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVUlEUgZ1c2VySWQSGwoJdXNlcl'
        '9uYW1lGAIgASgJUgh1c2VyTmFtZRIrCgl1c2VyX3JvbGUYAyABKA4yDi5hdXRoLlVzZXJSb2xl'
        'Ugh1c2VyUm9sZRIfCghibHVyaGFzaBgEIAEoCUgAUghibHVyaGFzaIgBARIjCg1yZWZyZXNoX3'
        'Rva2VuGAUgASgJUgxyZWZyZXNoVG9rZW4SIQoMYWNjZXNzX3Rva2VuGAYgASgJUgthY2Nlc3NU'
        'b2tlbkILCglfYmx1cmhhc2g=');

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'blurhash', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'blurhash', '17': true},
    {'1': 'deleted', '3': 6, '4': 1, '5': 8, '10': 'deleted'},
  ],
  '8': [
    {'1': '_blurhash'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor =
    $convert.base64Decode('CghVc2VySW5mbxIaCgJpZBgBIAEoCzIKLmNvcmUuVVVJRFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
        'FtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSIgoEcm9sZRgEIAEoDjIOLmF1dGguVXNlclJvbGVS'
        'BHJvbGUSHwoIYmx1cmhhc2gYBSABKAlIAFIIYmx1cmhhc2iIAQESGAoHZGVsZXRlZBgGIAEoCF'
        'IHZGVsZXRlZEILCglfYmx1cmhhc2g=');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'blurhash', '3': 5, '4': 1, '5': 9, '9': 0, '10': 'blurhash', '17': true},
    {'1': 'deleted', '3': 6, '4': 1, '5': 8, '10': 'deleted'},
  ],
  '8': [
    {'1': '_blurhash'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor =
    $convert.base64Decode('CgRVc2VyEhoKAmlkGAEgASgLMgouY29yZS5VVUlEUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
        'QKBWVtYWlsGAMgASgJUgVlbWFpbBIiCgRyb2xlGAQgASgOMg4uYXV0aC5Vc2VyUm9sZVIEcm9s'
        'ZRIfCghibHVyaGFzaBgFIAEoCUgAUghibHVyaGFzaIgBARIYCgdkZWxldGVkGAYgASgIUgdkZW'
        'xldGVkQgsKCV9ibHVyaGFzaA==');

@$core.Deprecated('Use userPhotoDescriptor instead')
const UserPhoto$json = {
  '1': 'UserPhoto',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'photo', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'photo', '17': true},
  ],
  '8': [
    {'1': '_photo'},
  ],
};

/// Descriptor for `UserPhoto`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userPhotoDescriptor =
    $convert.base64Decode('CglVc2VyUGhvdG8SIwoHdXNlcl9pZBgBIAEoCzIKLmNvcmUuVVVJRFIGdXNlcklkEhkKBXBob3'
        'RvGAIgASgMSABSBXBob3RviAEBQggKBl9waG90bw==');

@$core.Deprecated('Use userAvatarDescriptor instead')
const UserAvatar$json = {
  '1': 'UserAvatar',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'avatar', '3': 2, '4': 1, '5': 12, '9': 0, '10': 'avatar', '17': true},
  ],
  '8': [
    {'1': '_avatar'},
  ],
};

/// Descriptor for `UserAvatar`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userAvatarDescriptor =
    $convert.base64Decode('CgpVc2VyQXZhdGFyEiMKB3VzZXJfaWQYASABKAsyCi5jb3JlLlVVSURSBnVzZXJJZBIbCgZhdm'
        'F0YXIYAiABKAxIAFIGYXZhdGFyiAEBQgkKB19hdmF0YXI=');

@$core.Deprecated('Use userIdDescriptor instead')
const UserId$json = {
  '1': 'UserId',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
  ],
};

/// Descriptor for `UserId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userIdDescriptor =
    $convert.base64Decode('CgZVc2VySWQSGgoCaWQYASABKAsyCi5jb3JlLlVVSURSAmlk');

@$core.Deprecated('Use createUserRequestDescriptor instead')
const CreateUserRequest$json = {
  '1': 'CreateUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '10': 'password'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 6, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `CreateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserRequestDescriptor =
    $convert.base64Decode('ChFDcmVhdGVVc2VyUmVxdWVzdBIaCgJpZBgBIAEoCzIKLmNvcmUuVVVJRFICaWQSEgoEbmFtZR'
        'gCIAEoCVIEbmFtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSGgoIcGFzc3dvcmQYBCABKAlSCHBh'
        'c3N3b3JkEiIKBHJvbGUYBSABKA4yDi5hdXRoLlVzZXJSb2xlUgRyb2xlEhgKB2RlbGV0ZWQYBi'
        'ABKAhSB2RlbGV0ZWQ=');

@$core.Deprecated('Use updateUserRequestDescriptor instead')
const UpdateUserRequest$json = {
  '1': 'UpdateUserRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.auth.UserRole', '10': 'role'},
    {'1': 'deleted', '3': 5, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `UpdateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserRequestDescriptor =
    $convert.base64Decode('ChFVcGRhdGVVc2VyUmVxdWVzdBIaCgJpZBgBIAEoCzIKLmNvcmUuVVVJRFICaWQSEgoEbmFtZR'
        'gCIAEoCVIEbmFtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSIgoEcm9sZRgEIAEoDjIOLmF1dGgu'
        'VXNlclJvbGVSBHJvbGUSGAoHZGVsZXRlZBgFIAEoCFIHZGVsZXRlZA==');
