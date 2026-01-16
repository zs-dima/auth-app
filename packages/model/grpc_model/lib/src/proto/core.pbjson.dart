// This is a generated file - do not edit.
//
// Generated from core.proto.

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
    $convert.base64Decode('CgRVVUlEEm0KBXZhbHVlGAEgASgJQlf6QlRyUjJNXlswLTlhLWZBLUZdezh9LVswLTlhLWZBLU'
        'ZdezR9LVswLTlhLWZBLUZdezR9LVswLTlhLWZBLUZdezR9LVswLTlhLWZBLUZdezEyfSTQAQFS'
        'BXZhbHVl');

@$core.Deprecated('Use operationResultDescriptor instead')
const OperationResult$json = {
  '1': 'OperationResult',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `OperationResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List operationResultDescriptor =
    $convert.base64Decode('Cg9PcGVyYXRpb25SZXN1bHQSGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use decimalValueDescriptor instead')
const DecimalValue$json = {
  '1': 'DecimalValue',
  '2': [
    {'1': 'units', '3': 1, '4': 1, '5': 3, '10': 'units'},
    {'1': 'nanos', '3': 2, '4': 1, '5': 5, '10': 'nanos'},
  ],
};

/// Descriptor for `DecimalValue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decimalValueDescriptor =
    $convert.base64Decode('CgxEZWNpbWFsVmFsdWUSFAoFdW5pdHMYASABKANSBXVuaXRzEhQKBW5hbm9zGAIgASgFUgVuYW'
        '5vcw==');

@$core.Deprecated('Use dateRangeDescriptor instead')
const DateRange$json = {
  '1': 'DateRange',
  '2': [
    {'1': 'from_date', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'fromDate'},
    {'1': 'to_date', '3': 2, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'toDate'},
  ],
};

/// Descriptor for `DateRange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dateRangeDescriptor =
    $convert.base64Decode('CglEYXRlUmFuZ2USNwoJZnJvbV9kYXRlGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
        'FtcFIIZnJvbURhdGUSMwoHdG9fZGF0ZRgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3Rh'
        'bXBSBnRvRGF0ZQ==');

@$core.Deprecated('Use fileBytesDescriptor instead')
const FileBytes$json = {
  '1': 'FileBytes',
  '2': [
    {'1': 'data', '3': 1, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `FileBytes`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileBytesDescriptor = $convert.base64Decode('CglGaWxlQnl0ZXMSEgoEZGF0YRgBIAEoDFIEZGF0YQ==');

@$core.Deprecated('Use fileDataDescriptor instead')
const FileData$json = {
  '1': 'FileData',
  '2': [
    {'1': 'file_name', '3': 1, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'file_hash', '3': 2, '4': 1, '5': 9, '10': 'fileHash'},
    {'1': 'data', '3': 3, '4': 1, '5': 12, '10': 'data'},
  ],
};

/// Descriptor for `FileData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileDataDescriptor =
    $convert.base64Decode('CghGaWxlRGF0YRIbCglmaWxlX25hbWUYASABKAlSCGZpbGVOYW1lEhsKCWZpbGVfaGFzaBgCIA'
        'EoCVIIZmlsZUhhc2gSEgoEZGF0YRgDIAEoDFIEZGF0YQ==');
