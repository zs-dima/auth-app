// This is a generated file - do not edit.
//
// Generated from core.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class UserRole extends $pb.ProtobufEnum {
  static const UserRole USER_ROLE_UNSPECIFIED = UserRole._(0, _omitEnumNames ? '' : 'USER_ROLE_UNSPECIFIED');
  static const UserRole USER_ROLE_ADMIN = UserRole._(1, _omitEnumNames ? '' : 'USER_ROLE_ADMIN');
  static const UserRole USER_ROLE_USER = UserRole._(2, _omitEnumNames ? '' : 'USER_ROLE_USER');
  static const UserRole USER_ROLE_GUEST = UserRole._(3, _omitEnumNames ? '' : 'USER_ROLE_GUEST');

  static const $core.List<UserRole> values = <UserRole>[
    USER_ROLE_UNSPECIFIED,
    USER_ROLE_ADMIN,
    USER_ROLE_USER,
    USER_ROLE_GUEST,
  ];

  static final $core.List<UserRole?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static UserRole? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserRole._(super.value, super.name);
}

class UserStatus extends $pb.ProtobufEnum {
  static const UserStatus USER_STATUS_UNSPECIFIED = UserStatus._(0, _omitEnumNames ? '' : 'USER_STATUS_UNSPECIFIED');
  static const UserStatus USER_STATUS_PENDING = UserStatus._(1, _omitEnumNames ? '' : 'USER_STATUS_PENDING');
  static const UserStatus USER_STATUS_ACTIVE = UserStatus._(2, _omitEnumNames ? '' : 'USER_STATUS_ACTIVE');
  static const UserStatus USER_STATUS_SUSPENDED = UserStatus._(3, _omitEnumNames ? '' : 'USER_STATUS_SUSPENDED');
  static const UserStatus USER_STATUS_DELETED = UserStatus._(4, _omitEnumNames ? '' : 'USER_STATUS_DELETED');

  static const $core.List<UserStatus> values = <UserStatus>[
    USER_STATUS_UNSPECIFIED,
    USER_STATUS_PENDING,
    USER_STATUS_ACTIVE,
    USER_STATUS_SUSPENDED,
    USER_STATUS_DELETED,
  ];

  static final $core.List<UserStatus?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static UserStatus? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const UserStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
