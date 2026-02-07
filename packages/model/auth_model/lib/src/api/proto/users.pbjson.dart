// This is a generated file - do not edit.
//
// Generated from users.proto.

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

@$core.Deprecated('Use userInfoDescriptor instead')
const UserInfo$json = {
  '1': 'UserInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.v1.UserRole', '10': 'role'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.core.v1.UserStatus', '10': 'status'},
    {'1': 'avatar_url', '3': 7, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'locale', '3': 8, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'timezone', '3': 9, '4': 1, '5': 9, '10': 'timezone'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor =
    $convert.base64Decode('CghVc2VySW5mbxIdCgJpZBgBIAEoCzINLmNvcmUudjEuVVVJRFICaWQSEgoEbmFtZRgCIAEoCV'
        'IEbmFtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSFAoFcGhvbmUYBCABKAlSBXBob25lEiUKBHJv'
        'bGUYBSABKA4yES5jb3JlLnYxLlVzZXJSb2xlUgRyb2xlEisKBnN0YXR1cxgGIAEoDjITLmNvcm'
        'UudjEuVXNlclN0YXR1c1IGc3RhdHVzEh0KCmF2YXRhcl91cmwYByABKAlSCWF2YXRhclVybBIW'
        'CgZsb2NhbGUYCCABKAlSBmxvY2FsZRIaCgh0aW1lem9uZRgJIAEoCVIIdGltZXpvbmU=');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.v1.UserRole', '10': 'role'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.core.v1.UserStatus', '10': 'status'},
    {'1': 'email_verified', '3': 7, '4': 1, '5': 8, '10': 'emailVerified'},
    {'1': 'phone_verified', '3': 8, '4': 1, '5': 8, '10': 'phoneVerified'},
    {'1': 'mfa_enabled', '3': 9, '4': 1, '5': 8, '10': 'mfaEnabled'},
    {'1': 'has_password', '3': 10, '4': 1, '5': 8, '10': 'hasPassword'},
    {'1': 'avatar_url', '3': 11, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'locale', '3': 12, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'timezone', '3': 13, '4': 1, '5': 9, '10': 'timezone'},
    {'1': 'created_at', '3': 14, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
    {'1': 'updated_at', '3': 15, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'updatedAt'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor =
    $convert.base64Decode('CgRVc2VyEh0KAmlkGAEgASgLMg0uY29yZS52MS5VVUlEUgJpZBISCgRuYW1lGAIgASgJUgRuYW'
        '1lEhQKBWVtYWlsGAMgASgJUgVlbWFpbBIUCgVwaG9uZRgEIAEoCVIFcGhvbmUSJQoEcm9sZRgF'
        'IAEoDjIRLmNvcmUudjEuVXNlclJvbGVSBHJvbGUSKwoGc3RhdHVzGAYgASgOMhMuY29yZS52MS'
        '5Vc2VyU3RhdHVzUgZzdGF0dXMSJQoOZW1haWxfdmVyaWZpZWQYByABKAhSDWVtYWlsVmVyaWZp'
        'ZWQSJQoOcGhvbmVfdmVyaWZpZWQYCCABKAhSDXBob25lVmVyaWZpZWQSHwoLbWZhX2VuYWJsZW'
        'QYCSABKAhSCm1mYUVuYWJsZWQSIQoMaGFzX3Bhc3N3b3JkGAogASgIUgtoYXNQYXNzd29yZBId'
        'CgphdmF0YXJfdXJsGAsgASgJUglhdmF0YXJVcmwSFgoGbG9jYWxlGAwgASgJUgZsb2NhbGUSGg'
        'oIdGltZXpvbmUYDSABKAlSCHRpbWV6b25lEjkKCmNyZWF0ZWRfYXQYDiABKAsyGi5nb29nbGUu'
        'cHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgPIAEoCzIaLmdvb2'
        'dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use listUsersRequestDescriptor instead')
const ListUsersRequest$json = {
  '1': 'ListUsersRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '10': 'userId'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 11, '6': '.core.v1.UUID', '10': 'userIds'},
    {'1': 'statuses', '3': 3, '4': 3, '5': 14, '6': '.core.v1.UserStatus', '10': 'statuses'},
    {'1': 'roles', '3': 4, '4': 3, '5': 14, '6': '.core.v1.UserRole', '10': 'roles'},
    {'1': 'query', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'query'},
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '8': {}, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUsersRequestDescriptor =
    $convert.base64Decode('ChBMaXN0VXNlcnNSZXF1ZXN0EiYKB3VzZXJfaWQYASABKAsyDS5jb3JlLnYxLlVVSURSBnVzZX'
        'JJZBIoCgh1c2VyX2lkcxgCIAMoCzINLmNvcmUudjEuVVVJRFIHdXNlcklkcxIvCghzdGF0dXNl'
        'cxgDIAMoDjITLmNvcmUudjEuVXNlclN0YXR1c1IIc3RhdHVzZXMSJwoFcm9sZXMYBCADKA4yES'
        '5jb3JlLnYxLlVzZXJSb2xlUgVyb2xlcxIeCgVxdWVyeRgFIAEoCUII+kIFcgMY/wFSBXF1ZXJ5'
        'EicKCXBhZ2Vfc2l6ZRgGIAEoBUIK+kIHGgUY6AcoAFIIcGFnZVNpemUSHQoKcGFnZV90b2tlbh'
        'gHIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use createUserRequestDescriptor instead')
const CreateUserRequest$json = {
  '1': 'CreateUserRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'phone', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'phone'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.v1.UserRole', '10': 'role'},
    {'1': 'locale', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'locale'},
    {'1': 'timezone', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'timezone'},
  ],
};

/// Descriptor for `CreateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserRequestDescriptor =
    $convert.base64Decode('ChFDcmVhdGVVc2VyUmVxdWVzdBIeCgRuYW1lGAEgASgJQgr6QgdyBRABGP8BUgRuYW1lEh4KBW'
        'VtYWlsGAIgASgJQgj6QgVyAxj+AVIFZW1haWwSHQoFcGhvbmUYAyABKAlCB/pCBHICGBBSBXBo'
        'b25lEiQKCHBhc3N3b3JkGAQgASgJQgj6QgVyAxiAAVIIcGFzc3dvcmQSJQoEcm9sZRgFIAEoDj'
        'IRLmNvcmUudjEuVXNlclJvbGVSBHJvbGUSHwoGbG9jYWxlGAYgASgJQgf6QgRyAhgjUgZsb2Nh'
        'bGUSIwoIdGltZXpvbmUYByABKAlCB/pCBHICGEBSCHRpbWV6b25l');

@$core.Deprecated('Use updateUserRequestDescriptor instead')
const UpdateUserRequest$json = {
  '1': 'UpdateUserRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '8': {}, '10': 'userId'},
    {'1': 'update_mask', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '8': {}, '9': 0, '10': 'name', '17': true},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '8': {}, '9': 1, '10': 'email', '17': true},
    {'1': 'phone', '3': 5, '4': 1, '5': 9, '8': {}, '9': 2, '10': 'phone', '17': true},
    {'1': 'role', '3': 6, '4': 1, '5': 14, '6': '.core.v1.UserRole', '9': 3, '10': 'role', '17': true},
    {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.core.v1.UserStatus', '9': 4, '10': 'status', '17': true},
    {'1': 'locale', '3': 8, '4': 1, '5': 9, '8': {}, '9': 5, '10': 'locale', '17': true},
    {'1': 'timezone', '3': 9, '4': 1, '5': 9, '8': {}, '9': 6, '10': 'timezone', '17': true},
  ],
  '8': [
    {'1': '_name'},
    {'1': '_email'},
    {'1': '_phone'},
    {'1': '_role'},
    {'1': '_status'},
    {'1': '_locale'},
    {'1': '_timezone'},
  ],
};

/// Descriptor for `UpdateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateUserRequestDescriptor =
    $convert.base64Decode('ChFVcGRhdGVVc2VyUmVxdWVzdBIwCgd1c2VyX2lkGAEgASgLMg0uY29yZS52MS5VVUlEQgj6Qg'
        'WKAQIQAVIGdXNlcklkEjsKC3VwZGF0ZV9tYXNrGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLkZp'
        'ZWxkTWFza1IKdXBkYXRlTWFzaxIhCgRuYW1lGAMgASgJQgj6QgVyAxj/AUgAUgRuYW1liAEBEi'
        'MKBWVtYWlsGAQgASgJQgj6QgVyAxj+AUgBUgVlbWFpbIgBARIiCgVwaG9uZRgFIAEoCUIH+kIE'
        'cgIYEEgCUgVwaG9uZYgBARIqCgRyb2xlGAYgASgOMhEuY29yZS52MS5Vc2VyUm9sZUgDUgRyb2'
        'xliAEBEjAKBnN0YXR1cxgHIAEoDjITLmNvcmUudjEuVXNlclN0YXR1c0gEUgZzdGF0dXOIAQES'
        'JAoGbG9jYWxlGAggASgJQgf6QgRyAhgjSAVSBmxvY2FsZYgBARIoCgh0aW1lem9uZRgJIAEoCU'
        'IH+kIEcgIYQEgGUgh0aW1lem9uZYgBAUIHCgVfbmFtZUIICgZfZW1haWxCCAoGX3Bob25lQgcK'
        'BV9yb2xlQgkKB19zdGF0dXNCCQoHX2xvY2FsZUILCglfdGltZXpvbmU=');

@$core.Deprecated('Use setPasswordRequestDescriptor instead')
const SetPasswordRequest$json = {
  '1': 'SetPasswordRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '8': {}, '10': 'userId'},
    {'1': 'password', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'password'},
  ],
};

/// Descriptor for `SetPasswordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setPasswordRequestDescriptor =
    $convert.base64Decode('ChJTZXRQYXNzd29yZFJlcXVlc3QSMAoHdXNlcl9pZBgBIAEoCzINLmNvcmUudjEuVVVJREII+k'
        'IFigECEAFSBnVzZXJJZBImCghwYXNzd29yZBgCIAEoCUIK+kIHcgUQCBiAAVIIcGFzc3dvcmQ=');

@$core.Deprecated('Use getAvatarUploadUrlRequestDescriptor instead')
const GetAvatarUploadUrlRequest$json = {
  '1': 'GetAvatarUploadUrlRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '8': {}, '10': 'userId'},
    {'1': 'content_type', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'contentType'},
    {'1': 'content_size', '3': 3, '4': 1, '5': 4, '8': {}, '10': 'contentSize'},
  ],
};

/// Descriptor for `GetAvatarUploadUrlRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAvatarUploadUrlRequestDescriptor =
    $convert.base64Decode('ChlHZXRBdmF0YXJVcGxvYWRVcmxSZXF1ZXN0EjAKB3VzZXJfaWQYASABKAsyDS5jb3JlLnYxLl'
        'VVSURCCPpCBYoBAhABUgZ1c2VySWQSSwoMY29udGVudF90eXBlGAIgASgJQij6QiVyI1IKaW1h'
        'Z2UvanBlZ1IJaW1hZ2UvcG5nUgppbWFnZS93ZWJwUgtjb250ZW50VHlwZRIvCgxjb250ZW50X3'
        'NpemUYAyABKARCDPpCCTIHGICAgAUgAFILY29udGVudFNpemU=');

@$core.Deprecated('Use getAvatarUploadUrlResponseDescriptor instead')
const GetAvatarUploadUrlResponse$json = {
  '1': 'GetAvatarUploadUrlResponse',
  '2': [
    {'1': 'upload_url', '3': 1, '4': 1, '5': 9, '10': 'uploadUrl'},
    {'1': 'expires_in', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Duration', '10': 'expiresIn'},
  ],
};

/// Descriptor for `GetAvatarUploadUrlResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAvatarUploadUrlResponseDescriptor =
    $convert.base64Decode('ChpHZXRBdmF0YXJVcGxvYWRVcmxSZXNwb25zZRIdCgp1cGxvYWRfdXJsGAEgASgJUgl1cGxvYW'
        'RVcmwSOAoKZXhwaXJlc19pbhgCIAEoCzIZLmdvb2dsZS5wcm90b2J1Zi5EdXJhdGlvblIJZXhw'
        'aXJlc0lu');

@$core.Deprecated('Use confirmAvatarUploadRequestDescriptor instead')
const ConfirmAvatarUploadRequest$json = {
  '1': 'ConfirmAvatarUploadRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '8': {}, '10': 'userId'},
  ],
};

/// Descriptor for `ConfirmAvatarUploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmAvatarUploadRequestDescriptor =
    $convert.base64Decode('ChpDb25maXJtQXZhdGFyVXBsb2FkUmVxdWVzdBIwCgd1c2VyX2lkGAEgASgLMg0uY29yZS52MS'
        '5VVUlEQgj6QgWKAQIQAVIGdXNlcklk');

@$core.Deprecated('Use deleteAvatarRequestDescriptor instead')
const DeleteAvatarRequest$json = {
  '1': 'DeleteAvatarRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '8': {}, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteAvatarRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAvatarRequestDescriptor =
    $convert.base64Decode('ChNEZWxldGVBdmF0YXJSZXF1ZXN0EjAKB3VzZXJfaWQYASABKAsyDS5jb3JlLnYxLlVVSURCCP'
        'pCBYoBAhABUgZ1c2VySWQ=');
