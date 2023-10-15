//
//  Generated code. Do not modify.
//  source: core.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use uUIDDescriptor instead')
const UUID$json = {
  '1': 'UUID',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `UUID`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uUIDDescriptor = $convert.base64Decode('CgRVVUlEEhQKBXZhbHVlGAEgASgJUgV2YWx1ZQ==');

@$core.Deprecated('Use resultReplyDescriptor instead')
const ResultReply$json = {
  '1': 'ResultReply',
  '2': [
    {'1': 'result', '3': 1, '4': 1, '5': 8, '10': 'result'},
  ],
};

/// Descriptor for `ResultReply`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resultReplyDescriptor =
    $convert.base64Decode('CgtSZXN1bHRSZXBseRIWCgZyZXN1bHQYASABKAhSBnJlc3VsdA==');

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
