// This is a generated file - do not edit.
//
// Generated from users/v1/users.proto.

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

import 'package:protobuf/well_known_types/google/protobuf/duration.pbjson.dart' as $3;
import 'package:protobuf/well_known_types/google/protobuf/empty.pbjson.dart' as $4;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pbjson.dart' as $2;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart' as $1;

import '../../core/v1/core.pbjson.dart' as $0;

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
        '5jb3JlLnYxLlVzZXJSb2xlUgVyb2xlcxIeCgVxdWVyeRgFIAEoCUIIukgFcgMY/wFSBXF1ZXJ5'
        'EicKCXBhZ2Vfc2l6ZRgGIAEoBUIKukgHGgUY6AcoAFIIcGFnZVNpemUSHQoKcGFnZV90b2tlbh'
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
    $convert.base64Decode('ChFDcmVhdGVVc2VyUmVxdWVzdBIeCgRuYW1lGAEgASgJQgq6SAdyBRABGP8BUgRuYW1lEh4KBW'
        'VtYWlsGAIgASgJQgi6SAVyAxj+AVIFZW1haWwSHQoFcGhvbmUYAyABKAlCB7pIBHICGBBSBXBo'
        'b25lEiQKCHBhc3N3b3JkGAQgASgJQgi6SAVyAxiAAVIIcGFzc3dvcmQSJQoEcm9sZRgFIAEoDj'
        'IRLmNvcmUudjEuVXNlclJvbGVSBHJvbGUSHwoGbG9jYWxlGAYgASgJQge6SARyAhgjUgZsb2Nh'
        'bGUSIwoIdGltZXpvbmUYByABKAlCB7pIBHICGEBSCHRpbWV6b25l');

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
    $convert.base64Decode('ChFVcGRhdGVVc2VyUmVxdWVzdBIuCgd1c2VyX2lkGAEgASgLMg0uY29yZS52MS5VVUlEQga6SA'
        'PIAQFSBnVzZXJJZBI7Cgt1cGRhdGVfbWFzaxgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVs'
        'ZE1hc2tSCnVwZGF0ZU1hc2sSIQoEbmFtZRgDIAEoCUIIukgFcgMY/wFIAFIEbmFtZYgBARIjCg'
        'VlbWFpbBgEIAEoCUIIukgFcgMY/gFIAVIFZW1haWyIAQESIgoFcGhvbmUYBSABKAlCB7pIBHIC'
        'GBBIAlIFcGhvbmWIAQESKgoEcm9sZRgGIAEoDjIRLmNvcmUudjEuVXNlclJvbGVIA1IEcm9sZY'
        'gBARIwCgZzdGF0dXMYByABKA4yEy5jb3JlLnYxLlVzZXJTdGF0dXNIBFIGc3RhdHVziAEBEiQK'
        'BmxvY2FsZRgIIAEoCUIHukgEcgIYI0gFUgZsb2NhbGWIAQESKAoIdGltZXpvbmUYCSABKAlCB7'
        'pIBHICGEBIBlIIdGltZXpvbmWIAQFCBwoFX25hbWVCCAoGX2VtYWlsQggKBl9waG9uZUIHCgVf'
        'cm9sZUIJCgdfc3RhdHVzQgkKB19sb2NhbGVCCwoJX3RpbWV6b25l');

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
    $convert.base64Decode('ChJTZXRQYXNzd29yZFJlcXVlc3QSLgoHdXNlcl9pZBgBIAEoCzINLmNvcmUudjEuVVVJREIGuk'
        'gDyAEBUgZ1c2VySWQSJgoIcGFzc3dvcmQYAiABKAlCCrpIB3IFEAgYgAFSCHBhc3N3b3Jk');

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
    $convert.base64Decode('ChlHZXRBdmF0YXJVcGxvYWRVcmxSZXF1ZXN0Ei4KB3VzZXJfaWQYASABKAsyDS5jb3JlLnYxLl'
        'VVSURCBrpIA8gBAVIGdXNlcklkEksKDGNvbnRlbnRfdHlwZRgCIAEoCUIoukglciNSCmltYWdl'
        'L2pwZWdSCWltYWdlL3BuZ1IKaW1hZ2Uvd2VicFILY29udGVudFR5cGUSLwoMY29udGVudF9zaX'
        'plGAMgASgEQgy6SAkyBxiAgIAFIABSC2NvbnRlbnRTaXpl');

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
    $convert.base64Decode('ChpDb25maXJtQXZhdGFyVXBsb2FkUmVxdWVzdBIuCgd1c2VyX2lkGAEgASgLMg0uY29yZS52MS'
        '5VVUlEQga6SAPIAQFSBnVzZXJJZA==');

@$core.Deprecated('Use deleteAvatarRequestDescriptor instead')
const DeleteAvatarRequest$json = {
  '1': 'DeleteAvatarRequest',
  '2': [
    {'1': 'user_id', '3': 1, '4': 1, '5': 11, '6': '.core.v1.UUID', '8': {}, '10': 'userId'},
  ],
};

/// Descriptor for `DeleteAvatarRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteAvatarRequestDescriptor =
    $convert.base64Decode('ChNEZWxldGVBdmF0YXJSZXF1ZXN0Ei4KB3VzZXJfaWQYASABKAsyDS5jb3JlLnYxLlVVSURCBr'
        'pIA8gBAVIGdXNlcklk');

const $core.Map<$core.String, $core.dynamic> UserServiceBase$json = {
  '1': 'UserService',
  '2': [
    {'1': 'ListUsersInfo', '2': '.users.v1.ListUsersRequest', '3': '.users.v1.UserInfo', '4': {}, '6': true},
    {'1': 'ListUsers', '2': '.users.v1.ListUsersRequest', '3': '.users.v1.User', '4': {}, '6': true},
    {'1': 'CreateUser', '2': '.users.v1.CreateUserRequest', '3': '.users.v1.User', '4': {}},
    {'1': 'UpdateUser', '2': '.users.v1.UpdateUserRequest', '3': '.users.v1.User', '4': {}},
    {'1': 'SetPassword', '2': '.users.v1.SetPasswordRequest', '3': '.google.protobuf.Empty', '4': {}},
    {
      '1': 'GetAvatarUploadUrl',
      '2': '.users.v1.GetAvatarUploadUrlRequest',
      '3': '.users.v1.GetAvatarUploadUrlResponse',
      '4': {}
    },
    {'1': 'ConfirmAvatarUpload', '2': '.users.v1.ConfirmAvatarUploadRequest', '3': '.google.protobuf.Empty', '4': {}},
    {'1': 'DeleteAvatar', '2': '.users.v1.DeleteAvatarRequest', '3': '.google.protobuf.Empty', '4': {}},
  ],
};

@$core.Deprecated('Use userServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> UserServiceBase$messageJson = {
  '.users.v1.ListUsersRequest': ListUsersRequest$json,
  '.core.v1.UUID': $0.UUID$json,
  '.users.v1.UserInfo': UserInfo$json,
  '.users.v1.User': User$json,
  '.google.protobuf.Timestamp': $1.Timestamp$json,
  '.users.v1.CreateUserRequest': CreateUserRequest$json,
  '.users.v1.UpdateUserRequest': UpdateUserRequest$json,
  '.google.protobuf.FieldMask': $2.FieldMask$json,
  '.users.v1.SetPasswordRequest': SetPasswordRequest$json,
  '.google.protobuf.Empty': $4.Empty$json,
  '.users.v1.GetAvatarUploadUrlRequest': GetAvatarUploadUrlRequest$json,
  '.users.v1.GetAvatarUploadUrlResponse': GetAvatarUploadUrlResponse$json,
  '.google.protobuf.Duration': $3.Duration$json,
  '.users.v1.ConfirmAvatarUploadRequest': ConfirmAvatarUploadRequest$json,
  '.users.v1.DeleteAvatarRequest': DeleteAvatarRequest$json,
};

/// Descriptor for `UserService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List userServiceDescriptor =
    $convert.base64Decode('CgtVc2VyU2VydmljZRJDCg1MaXN0VXNlcnNJbmZvEhoudXNlcnMudjEuTGlzdFVzZXJzUmVxdW'
        'VzdBoSLnVzZXJzLnYxLlVzZXJJbmZvIgAwARI7CglMaXN0VXNlcnMSGi51c2Vycy52MS5MaXN0'
        'VXNlcnNSZXF1ZXN0Gg4udXNlcnMudjEuVXNlciIAMAESOwoKQ3JlYXRlVXNlchIbLnVzZXJzLn'
        'YxLkNyZWF0ZVVzZXJSZXF1ZXN0Gg4udXNlcnMudjEuVXNlciIAEjsKClVwZGF0ZVVzZXISGy51'
        'c2Vycy52MS5VcGRhdGVVc2VyUmVxdWVzdBoOLnVzZXJzLnYxLlVzZXIiABJFCgtTZXRQYXNzd2'
        '9yZBIcLnVzZXJzLnYxLlNldFBhc3N3b3JkUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0'
        'eSIAEmEKEkdldEF2YXRhclVwbG9hZFVybBIjLnVzZXJzLnYxLkdldEF2YXRhclVwbG9hZFVybF'
        'JlcXVlc3QaJC51c2Vycy52MS5HZXRBdmF0YXJVcGxvYWRVcmxSZXNwb25zZSIAElUKE0NvbmZp'
        'cm1BdmF0YXJVcGxvYWQSJC51c2Vycy52MS5Db25maXJtQXZhdGFyVXBsb2FkUmVxdWVzdBoWLm'
        'dvb2dsZS5wcm90b2J1Zi5FbXB0eSIAEkcKDERlbGV0ZUF2YXRhchIdLnVzZXJzLnYxLkRlbGV0'
        'ZUF2YXRhclJlcXVlc3QaFi5nb29nbGUucHJvdG9idWYuRW1wdHkiAA==');
