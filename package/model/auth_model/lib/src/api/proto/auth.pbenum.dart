// This is a generated file - do not edit.
//
// Generated from auth.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

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

  static final $core.List<OS?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static OS? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OS._(super.value, super.name);
}

class UserRole extends $pb.ProtobufEnum {
  static const UserRole administrator = UserRole._(0, _omitEnumNames ? '' : 'administrator');
  static const UserRole user = UserRole._(1, _omitEnumNames ? '' : 'user');

  static const $core.List<UserRole> values = <UserRole>[
    administrator,
    user,
  ];

  static final $core.List<UserRole?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static UserRole? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserRole._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
