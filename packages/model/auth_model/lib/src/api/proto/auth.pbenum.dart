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
  static const OS FUCHSIA = OS._(0, _omitEnumNames ? '' : 'FUCHSIA');
  static const OS LINUX = OS._(1, _omitEnumNames ? '' : 'LINUX');
  static const OS MACOS = OS._(2, _omitEnumNames ? '' : 'MACOS');
  static const OS WINDOWS = OS._(3, _omitEnumNames ? '' : 'WINDOWS');
  static const OS IOS = OS._(4, _omitEnumNames ? '' : 'IOS');
  static const OS ANDROID = OS._(5, _omitEnumNames ? '' : 'ANDROID');
  static const OS UNKNOWN = OS._(6, _omitEnumNames ? '' : 'UNKNOWN');

  static const $core.List<OS> values = <OS>[
    FUCHSIA,
    LINUX,
    MACOS,
    WINDOWS,
    IOS,
    ANDROID,
    UNKNOWN,
  ];

  static final $core.List<OS?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static OS? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OS._(super.value, super.name);
}

class UserRole extends $pb.ProtobufEnum {
  static const UserRole ADMINISTRATOR = UserRole._(0, _omitEnumNames ? '' : 'ADMINISTRATOR');
  static const UserRole USER = UserRole._(1, _omitEnumNames ? '' : 'USER');

  static const $core.List<UserRole> values = <UserRole>[
    ADMINISTRATOR,
    USER,
  ];

  static final $core.List<UserRole?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 1);
  static UserRole? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserRole._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
