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
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.UserRole', '10': 'role'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.core.UserStatus', '10': 'status'},
    {'1': 'avatar_url', '3': 7, '4': 1, '5': 9, '10': 'avatarUrl'},
    {'1': 'locale', '3': 8, '4': 1, '5': 9, '10': 'locale'},
    {'1': 'timezone', '3': 9, '4': 1, '5': 9, '10': 'timezone'},
  ],
};

/// Descriptor for `UserInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userInfoDescriptor =
    $convert.base64Decode('CghVc2VySW5mbxIaCgJpZBgBIAEoCzIKLmNvcmUuVVVJRFICaWQSEgoEbmFtZRgCIAEoCVIEbm'
        'FtZRIUCgVlbWFpbBgDIAEoCVIFZW1haWwSFAoFcGhvbmUYBCABKAlSBXBob25lEiIKBHJvbGUY'
        'BSABKA4yDi5jb3JlLlVzZXJSb2xlUgRyb2xlEigKBnN0YXR1cxgGIAEoDjIQLmNvcmUuVXNlcl'
        'N0YXR1c1IGc3RhdHVzEh0KCmF2YXRhcl91cmwYByABKAlSCWF2YXRhclVybBIWCgZsb2NhbGUY'
        'CCABKAlSBmxvY2FsZRIaCgh0aW1lem9uZRgJIAEoCVIIdGltZXpvbmU=');

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'email', '3': 3, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 4, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.UserRole', '10': 'role'},
    {'1': 'status', '3': 6, '4': 1, '5': 14, '6': '.core.UserStatus', '10': 'status'},
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
    $convert.base64Decode('CgRVc2VyEhoKAmlkGAEgASgLMgouY29yZS5VVUlEUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEh'
        'QKBWVtYWlsGAMgASgJUgVlbWFpbBIUCgVwaG9uZRgEIAEoCVIFcGhvbmUSIgoEcm9sZRgFIAEo'
        'DjIOLmNvcmUuVXNlclJvbGVSBHJvbGUSKAoGc3RhdHVzGAYgASgOMhAuY29yZS5Vc2VyU3RhdH'
        'VzUgZzdGF0dXMSJQoOZW1haWxfdmVyaWZpZWQYByABKAhSDWVtYWlsVmVyaWZpZWQSJQoOcGhv'
        'bmVfdmVyaWZpZWQYCCABKAhSDXBob25lVmVyaWZpZWQSHwoLbWZhX2VuYWJsZWQYCSABKAhSCm'
        '1mYUVuYWJsZWQSIQoMaGFzX3Bhc3N3b3JkGAogASgIUgtoYXNQYXNzd29yZBIdCgphdmF0YXJf'
        'dXJsGAsgASgJUglhdmF0YXJVcmwSFgoGbG9jYWxlGAwgASgJUgZsb2NhbGUSGgoIdGltZXpvbm'
        'UYDSABKAlSCHRpbWV6b25lEjkKCmNyZWF0ZWRfYXQYDiABKAsyGi5nb29nbGUucHJvdG9idWYu'
        'VGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgPIAEoCzIaLmdvb2dsZS5wcm90b2'
        'J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use listUsersRequestDescriptor instead')
const ListUsersRequest$json = {
  '1': 'ListUsersRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '10': 'userId'},
    {'1': 'user_ids', '3': 2, '4': 3, '5': 11, '6': '.core.UUID', '10': 'userIds'},
    {'1': 'statuses', '3': 3, '4': 3, '5': 14, '6': '.core.UserStatus', '10': 'statuses'},
    {'1': 'roles', '3': 4, '4': 3, '5': 14, '6': '.core.UserRole', '10': 'roles'},
    {'1': 'query', '3': 5, '4': 1, '5': 9, '8': {}, '10': 'query'},
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '8': {}, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListUsersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listUsersRequestDescriptor =
    $convert.base64Decode('ChBMaXN0VXNlcnNSZXF1ZXN0EiMKB3VzZXJfaWQYASABKAsyCi5jb3JlLlVVSURSBnVzZXJJZB'
        'IlCgh1c2VyX2lkcxgCIAMoCzIKLmNvcmUuVVVJRFIHdXNlcklkcxIsCghzdGF0dXNlcxgDIAMo'
        'DjIQLmNvcmUuVXNlclN0YXR1c1IIc3RhdHVzZXMSJAoFcm9sZXMYBCADKA4yDi5jb3JlLlVzZX'
        'JSb2xlUgVyb2xlcxIeCgVxdWVyeRgFIAEoCUII+kIFcgMY/wFSBXF1ZXJ5EicKCXBhZ2Vfc2l6'
        'ZRgGIAEoBUIK+kIHGgUY6AcoAFIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgHIAEoCVIJcGFnZV'
        'Rva2Vu');

@$core.Deprecated('Use createUserRequestDescriptor instead')
const CreateUserRequest$json = {
  '1': 'CreateUserRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'name'},
    {'1': 'email', '3': 2, '4': 1, '5': 9, '8': {}, '10': 'email'},
    {'1': 'phone', '3': 3, '4': 1, '5': 9, '8': {}, '10': 'phone'},
    {'1': 'password', '3': 4, '4': 1, '5': 9, '8': {}, '10': 'password'},
    {'1': 'role', '3': 5, '4': 1, '5': 14, '6': '.core.UserRole', '10': 'role'},
    {'1': 'locale', '3': 6, '4': 1, '5': 9, '8': {}, '10': 'locale'},
    {'1': 'timezone', '3': 7, '4': 1, '5': 9, '8': {}, '10': 'timezone'},
  ],
};

/// Descriptor for `CreateUserRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createUserRequestDescriptor =
    $convert.base64Decode('ChFDcmVhdGVVc2VyUmVxdWVzdBIeCgRuYW1lGAEgASgJQgr6QgdyBRABGP8BUgRuYW1lEh4KBW'
        'VtYWlsGAIgASgJQgj6QgVyAxj+AVIFZW1haWwSHQoFcGhvbmUYAyABKAlCB/pCBHICGBBSBXBo'
        'b25lEiQKCHBhc3N3b3JkGAQgASgJQgj6QgVyAxiAAVIIcGFzc3dvcmQSIgoEcm9sZRgFIAEoDj'
        'IOLmNvcmUuVXNlclJvbGVSBHJvbGUSHwoGbG9jYWxlGAYgASgJQgf6QgRyAhgjUgZsb2NhbGUS'
        'IwoIdGltZXpvbmUYByABKAlCB/pCBHICGEBSCHRpbWV6b25l');

@$core.Deprecated('Use updateUserRequestDescriptor instead')
const UpdateUserRequest$json = {
  '1': 'UpdateUserRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
    {'1': 'update_mask', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.FieldMask', '10': 'updateMask'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '8': {}, '9': 0, '10': 'name', '17': true},
    {'1': 'email', '3': 4, '4': 1, '5': 9, '8': {}, '9': 1, '10': 'email', '17': true},
    {'1': 'phone', '3': 5, '4': 1, '5': 9, '8': {}, '9': 2, '10': 'phone', '17': true},
    {'1': 'role', '3': 6, '4': 1, '5': 14, '6': '.core.UserRole', '9': 3, '10': 'role', '17': true},
    {'1': 'status', '3': 7, '4': 1, '5': 14, '6': '.core.UserStatus', '9': 4, '10': 'status', '17': true},
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
    $convert.base64Decode('ChFVcGRhdGVVc2VyUmVxdWVzdBItCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVUlEQgj6QgWKAQ'
        'IQAVIGdXNlcklkEjsKC3VwZGF0ZV9tYXNrGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLkZpZWxk'
        'TWFza1IKdXBkYXRlTWFzaxIhCgRuYW1lGAMgASgJQgj6QgVyAxj/AUgAUgRuYW1liAEBEiMKBW'
        'VtYWlsGAQgASgJQgj6QgVyAxj+AUgBUgVlbWFpbIgBARIiCgVwaG9uZRgFIAEoCUIH+kIEcgIY'
        'EEgCUgVwaG9uZYgBARInCgRyb2xlGAYgASgOMg4uY29yZS5Vc2VyUm9sZUgDUgRyb2xliAEBEi'
        '0KBnN0YXR1cxgHIAEoDjIQLmNvcmUuVXNlclN0YXR1c0gEUgZzdGF0dXOIAQESJAoGbG9jYWxl'
        'GAggASgJQgf6QgRyAhgjSAVSBmxvY2FsZYgBARIoCgh0aW1lem9uZRgJIAEoCUIH+kIEcgIYQE'
        'gGUgh0aW1lem9uZYgBAUIHCgVfbmFtZUIICgZfZW1haWxCCAoGX3Bob25lQgcKBV9yb2xlQgkK'
        'B19zdGF0dXNCCQoHX2xvY2FsZUILCglfdGltZXpvbmU=');

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
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
  ],
};

/// Descriptor for `ConfirmAvatarUploadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmAvatarUploadRequestDescriptor =
    $convert.base64Decode('ChpDb25maXJtQXZhdGFyVXBsb2FkUmVxdWVzdBItCgd1c2VyX2lkGAEgASgLMgouY29yZS5VVU'
        'lEQgj6QgWKAQIQAVIGdXNlcklk');

@$core.Deprecated('Use deleteAvatarRequestDescriptor instead')
const DeleteAvatarRequest$json = {
  '1': 'DeleteAvatarRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.UUID', '8': {}, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteAvatarRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAvatarRequestDescriptor =
    $convert.base64Decode('ChNEZWxldGVBdmF0YXJSZXF1ZXN0Ei0KB3VzZXJfaWQYASABKAsyCi5jb3JlLlVVSURCCPpCBY'
        'oBAhABUgZ1c2VySWQ=');
