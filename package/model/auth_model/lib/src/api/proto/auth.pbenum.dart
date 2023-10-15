//
//  Generated code. Do not modify.
//  source: auth.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class OS extends $pb.ProtobufEnum {
  static const OS fuchsia = OS._(0, _omitEnumNames ? '' : 'fuchsia');
  static const OS linux = OS._(1, _omitEnumNames ? '' : 'linux');
  static const OS macOS = OS._(2, _omitEnumNames ? '' : 'macOS');
  static const OS windows = OS._(3, _omitEnumNames ? '' : 'windows');
  static const OS iOS = OS._(4, _omitEnumNames ? '' : 'iOS');
  static const OS android = OS._(5, _omitEnumNames ? '' : 'android');
  static const OS unknown = OS._(6, _omitEnumNames ? '' : 'unknown');

  static const $core.List<OS> values = <OS>[
    fuchsia,
    linux,
    macOS,
    windows,
    iOS,
    android,
    unknown,
  ];

  static final $core.Map<$core.int, OS> _byValue = $pb.ProtobufEnum.initByValue(values);
  static OS? valueOf($core.int value) => _byValue[value];

  const OS._($core.int v, $core.String n) : super(v, n);
}

class UserRole extends $pb.ProtobufEnum {
  static const UserRole administrator = UserRole._(0, _omitEnumNames ? '' : 'administrator');
  static const UserRole user = UserRole._(1, _omitEnumNames ? '' : 'user');

  static const $core.List<UserRole> values = <UserRole>[
    administrator,
    user,
  ];

  static final $core.Map<$core.int, UserRole> _byValue = $pb.ProtobufEnum.initByValue(values);
  static UserRole? valueOf($core.int value) => _byValue[value];

  const UserRole._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
