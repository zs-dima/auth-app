// This is a generated file - do not edit.
//
// Generated from core/v1/core.proto.

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

@$core.Deprecated('Use uUIDDescriptor instead')
const UUID$json = {
  '1': 'UUID',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'value'},
  ],
};

/// Descriptor for `UUID`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uUIDDescriptor =
    $convert.base64Decode('CgRVVUlEEiEKBXZhbHVlGAEgASgJQgu6SAjYAQFyA7ABAVIFdmFsdWU=');
