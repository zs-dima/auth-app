// This is a generated file - do not edit.
//
// Generated from users.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart' as $5;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart' as $4;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $3;

import 'core.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class UserInfo extends $pb.GeneratedMessage {
  factory UserInfo({
    $2.UUID? id,
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    $2.UserRole? role,
    $2.UserStatus? status,
    $core.String? avatarUrl,
    $core.String? locale,
    $core.String? timezone,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (role != null) result.role = role;
    if (status != null) result.status = status;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    return result;
  }

  UserInfo._();

  factory UserInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aE<$2.UserRole>(5, _omitFieldNames ? '' : 'role', enumValues: $2.UserRole.values)
    ..aE<$2.UserStatus>(6, _omitFieldNames ? '' : 'status', enumValues: $2.UserStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(8, _omitFieldNames ? '' : 'locale')
    ..aOS(9, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserInfo copyWith(void Function(UserInfo) updates) =>
      super.copyWith((message) => updates(message as UserInfo)) as UserInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserInfo create() => UserInfo._();
  @$core.override
  UserInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserInfo>(create);
  static UserInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.UserRole get role => $_getN(4);
  @$pb.TagNumber(5)
  set role($2.UserRole value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.UserStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status($2.UserStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get avatarUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set avatarUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvatarUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvatarUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get locale => $_getSZ(7);
  @$pb.TagNumber(8)
  set locale($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLocale() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocale() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get timezone => $_getSZ(8);
  @$pb.TagNumber(9)
  set timezone($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTimezone() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimezone() => $_clearField(9);
}

class User extends $pb.GeneratedMessage {
  factory User({
    $2.UUID? id,
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    $2.UserRole? role,
    $2.UserStatus? status,
    $core.bool? emailVerified,
    $core.bool? phoneVerified,
    $core.bool? mfaEnabled,
    $core.bool? hasPassword,
    $core.String? avatarUrl,
    $core.String? locale,
    $core.String? timezone,
    $3.Timestamp? createdAt,
    $3.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (role != null) result.role = role;
    if (status != null) result.status = status;
    if (emailVerified != null) result.emailVerified = emailVerified;
    if (phoneVerified != null) result.phoneVerified = phoneVerified;
    if (mfaEnabled != null) result.mfaEnabled = mfaEnabled;
    if (hasPassword != null) result.hasPassword = hasPassword;
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  User._();

  factory User.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory User.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'User',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aE<$2.UserRole>(5, _omitFieldNames ? '' : 'role', enumValues: $2.UserRole.values)
    ..aE<$2.UserStatus>(6, _omitFieldNames ? '' : 'status', enumValues: $2.UserStatus.values)
    ..aOB(7, _omitFieldNames ? '' : 'emailVerified')
    ..aOB(8, _omitFieldNames ? '' : 'phoneVerified')
    ..aOB(9, _omitFieldNames ? '' : 'mfaEnabled')
    ..aOB(10, _omitFieldNames ? '' : 'hasPassword')
    ..aOS(11, _omitFieldNames ? '' : 'avatarUrl')
    ..aOS(12, _omitFieldNames ? '' : 'locale')
    ..aOS(13, _omitFieldNames ? '' : 'timezone')
    ..aOM<$3.Timestamp>(14, _omitFieldNames ? '' : 'createdAt', subBuilder: $3.Timestamp.create)
    ..aOM<$3.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt', subBuilder: $3.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  User copyWith(void Function(User) updates) => super.copyWith((message) => updates(message as User)) as User;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static User create() => User._();
  @$core.override
  User createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static User getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<User>(create);
  static User? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  @$pb.TagNumber(5)
  $2.UserRole get role => $_getN(4);
  @$pb.TagNumber(5)
  set role($2.UserRole value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.UserStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status($2.UserStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get emailVerified => $_getBF(6);
  @$pb.TagNumber(7)
  set emailVerified($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEmailVerified() => $_has(6);
  @$pb.TagNumber(7)
  void clearEmailVerified() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get phoneVerified => $_getBF(7);
  @$pb.TagNumber(8)
  set phoneVerified($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPhoneVerified() => $_has(7);
  @$pb.TagNumber(8)
  void clearPhoneVerified() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get mfaEnabled => $_getBF(8);
  @$pb.TagNumber(9)
  set mfaEnabled($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMfaEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearMfaEnabled() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get hasPassword => $_getBF(9);
  @$pb.TagNumber(10)
  set hasPassword($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHasPassword() => $_has(9);
  @$pb.TagNumber(10)
  void clearHasPassword() => $_clearField(10);

  /// Linked OAuth providers
  /// repeated OAuthProvider linked_providers = 11;
  @$pb.TagNumber(11)
  $core.String get avatarUrl => $_getSZ(10);
  @$pb.TagNumber(11)
  set avatarUrl($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAvatarUrl() => $_has(10);
  @$pb.TagNumber(11)
  void clearAvatarUrl() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get locale => $_getSZ(11);
  @$pb.TagNumber(12)
  set locale($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLocale() => $_has(11);
  @$pb.TagNumber(12)
  void clearLocale() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get timezone => $_getSZ(12);
  @$pb.TagNumber(13)
  set timezone($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasTimezone() => $_has(12);
  @$pb.TagNumber(13)
  void clearTimezone() => $_clearField(13);

  @$pb.TagNumber(14)
  $3.Timestamp get createdAt => $_getN(13);
  @$pb.TagNumber(14)
  set createdAt($3.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCreatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearCreatedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $3.Timestamp ensureCreatedAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $3.Timestamp get updatedAt => $_getN(14);
  @$pb.TagNumber(15)
  set updatedAt($3.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasUpdatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearUpdatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $3.Timestamp ensureUpdatedAt() => $_ensure(14);
}

class ListUsersRequest extends $pb.GeneratedMessage {
  factory ListUsersRequest({
    $2.UUID? userId,
    $core.Iterable<$2.UUID>? userIds,
    $core.Iterable<$2.UserStatus>? statuses,
    $core.Iterable<$2.UserRole>? roles,
    $core.String? query,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (userIds != null) result.userIds.addAll(userIds);
    if (statuses != null) result.statuses.addAll(statuses);
    if (roles != null) result.roles.addAll(roles);
    if (query != null) result.query = query;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListUsersRequest._();

  factory ListUsersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListUsersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUsersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..pPM<$2.UUID>(2, _omitFieldNames ? '' : 'userIds', subBuilder: $2.UUID.create)
    ..pc<$2.UserStatus>(3, _omitFieldNames ? '' : 'statuses', $pb.PbFieldType.KE,
        valueOf: $2.UserStatus.valueOf,
        enumValues: $2.UserStatus.values,
        defaultEnumValue: $2.UserStatus.USER_STATUS_UNSPECIFIED)
    ..pc<$2.UserRole>(4, _omitFieldNames ? '' : 'roles', $pb.PbFieldType.KE,
        valueOf: $2.UserRole.valueOf,
        enumValues: $2.UserRole.values,
        defaultEnumValue: $2.UserRole.USER_ROLE_UNSPECIFIED)
    ..aOS(5, _omitFieldNames ? '' : 'query')
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOS(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUsersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUsersRequest copyWith(void Function(ListUsersRequest) updates) =>
      super.copyWith((message) => updates(message as ListUsersRequest)) as ListUsersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListUsersRequest create() => ListUsersRequest._();
  @$core.override
  ListUsersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListUsersRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUsersRequest>(create);
  static ListUsersRequest? _defaultInstance;

  /// Impersonated user id (admin only)
  @$pb.TagNumber(1)
  $2.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureUserId() => $_ensure(0);

  /// Optional: filter by specific user IDs; if empty, load all users
  @$pb.TagNumber(2)
  $pb.PbList<$2.UUID> get userIds => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$2.UserStatus> get statuses => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$2.UserRole> get roles => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get query => $_getSZ(4);
  @$pb.TagNumber(5)
  set query($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuery() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuery() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pageToken => $_getSZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class CreateUserRequest extends $pb.GeneratedMessage {
  factory CreateUserRequest({
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    $core.String? password,
    $2.UserRole? role,
    $core.String? locale,
    $core.String? timezone,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (password != null) result.password = password;
    if (role != null) result.role = role;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    return result;
  }

  CreateUserRequest._();

  factory CreateUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'email')
    ..aOS(3, _omitFieldNames ? '' : 'phone')
    ..aOS(4, _omitFieldNames ? '' : 'password')
    ..aE<$2.UserRole>(5, _omitFieldNames ? '' : 'role', enumValues: $2.UserRole.values)
    ..aOS(6, _omitFieldNames ? '' : 'locale')
    ..aOS(7, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateUserRequest copyWith(void Function(CreateUserRequest) updates) =>
      super.copyWith((message) => updates(message as CreateUserRequest)) as CreateUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateUserRequest create() => CreateUserRequest._();
  @$core.override
  CreateUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateUserRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateUserRequest>(create);
  static CreateUserRequest? _defaultInstance;

  /// Display name
  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  /// Email (optional if phone is provided)
  @$pb.TagNumber(2)
  $core.String get email => $_getSZ(1);
  @$pb.TagNumber(2)
  set email($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEmail() => $_has(1);
  @$pb.TagNumber(2)
  void clearEmail() => $_clearField(2);

  /// Phone in E.164 format (optional if email is provided)
  @$pb.TagNumber(3)
  $core.String get phone => $_getSZ(2);
  @$pb.TagNumber(3)
  set phone($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhone() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhone() => $_clearField(3);

  /// Password (optional for OAuth-only accounts)
  @$pb.TagNumber(4)
  $core.String get password => $_getSZ(3);
  @$pb.TagNumber(4)
  set password($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPassword() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassword() => $_clearField(4);

  /// User role
  @$pb.TagNumber(5)
  $2.UserRole get role => $_getN(4);
  @$pb.TagNumber(5)
  set role($2.UserRole value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);

  /// Locale (BCP 47)
  @$pb.TagNumber(6)
  $core.String get locale => $_getSZ(5);
  @$pb.TagNumber(6)
  set locale($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLocale() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocale() => $_clearField(6);

  /// Timezone (IANA)
  @$pb.TagNumber(7)
  $core.String get timezone => $_getSZ(6);
  @$pb.TagNumber(7)
  set timezone($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTimezone() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimezone() => $_clearField(7);
}

class UpdateUserRequest extends $pb.GeneratedMessage {
  factory UpdateUserRequest({
    $2.UUID? userId,
    $4.FieldMask? updateMask,
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    $2.UserRole? role,
    $2.UserStatus? status,
    $core.String? locale,
    $core.String? timezone,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (updateMask != null) result.updateMask = updateMask;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (role != null) result.role = role;
    if (status != null) result.status = status;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    return result;
  }

  UpdateUserRequest._();

  factory UpdateUserRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateUserRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateUserRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..aOM<$4.FieldMask>(2, _omitFieldNames ? '' : 'updateMask', subBuilder: $4.FieldMask.create)
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'email')
    ..aOS(5, _omitFieldNames ? '' : 'phone')
    ..aE<$2.UserRole>(6, _omitFieldNames ? '' : 'role', enumValues: $2.UserRole.values)
    ..aE<$2.UserStatus>(7, _omitFieldNames ? '' : 'status', enumValues: $2.UserStatus.values)
    ..aOS(8, _omitFieldNames ? '' : 'locale')
    ..aOS(9, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateUserRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateUserRequest copyWith(void Function(UpdateUserRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateUserRequest)) as UpdateUserRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateUserRequest create() => UpdateUserRequest._();
  @$core.override
  UpdateUserRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateUserRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateUserRequest>(create);
  static UpdateUserRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureUserId() => $_ensure(0);

  @$pb.TagNumber(2)
  $4.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($4.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $4.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get email => $_getSZ(3);
  @$pb.TagNumber(4)
  set email($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearEmail() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get phone => $_getSZ(4);
  @$pb.TagNumber(5)
  set phone($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPhone() => $_has(4);
  @$pb.TagNumber(5)
  void clearPhone() => $_clearField(5);

  @$pb.TagNumber(6)
  $2.UserRole get role => $_getN(5);
  @$pb.TagNumber(6)
  set role($2.UserRole value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  @$pb.TagNumber(7)
  $2.UserStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status($2.UserStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get locale => $_getSZ(7);
  @$pb.TagNumber(8)
  set locale($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLocale() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocale() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get timezone => $_getSZ(8);
  @$pb.TagNumber(9)
  set timezone($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTimezone() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimezone() => $_clearField(9);
}

class SetPasswordRequest extends $pb.GeneratedMessage {
  factory SetPasswordRequest({
    $2.UUID? userId,
    $core.String? password,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (password != null) result.password = password;
    return result;
  }

  SetPasswordRequest._();

  factory SetPasswordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetPasswordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetPasswordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPasswordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetPasswordRequest copyWith(void Function(SetPasswordRequest) updates) =>
      super.copyWith((message) => updates(message as SetPasswordRequest)) as SetPasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetPasswordRequest create() => SetPasswordRequest._();
  @$core.override
  SetPasswordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetPasswordRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetPasswordRequest>(create);
  static SetPasswordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureUserId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

/// Request for presigned upload URL
class GetAvatarUploadUrlRequest extends $pb.GeneratedMessage {
  factory GetAvatarUploadUrlRequest({
    $2.UUID? userId,
    $core.String? contentType,
    $fixnum.Int64? contentSize,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (contentType != null) result.contentType = contentType;
    if (contentSize != null) result.contentSize = contentSize;
    return result;
  }

  GetAvatarUploadUrlRequest._();

  factory GetAvatarUploadUrlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAvatarUploadUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAvatarUploadUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'contentType')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'contentSize', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAvatarUploadUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAvatarUploadUrlRequest copyWith(void Function(GetAvatarUploadUrlRequest) updates) =>
      super.copyWith((message) => updates(message as GetAvatarUploadUrlRequest)) as GetAvatarUploadUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAvatarUploadUrlRequest create() => GetAvatarUploadUrlRequest._();
  @$core.override
  GetAvatarUploadUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAvatarUploadUrlRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAvatarUploadUrlRequest>(create);
  static GetAvatarUploadUrlRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureUserId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get contentType => $_getSZ(1);
  @$pb.TagNumber(2)
  set contentType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContentType() => $_has(1);
  @$pb.TagNumber(2)
  void clearContentType() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get contentSize => $_getI64(2);
  @$pb.TagNumber(3)
  set contentSize($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContentSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearContentSize() => $_clearField(3);
}

/// Response with presigned URL for direct S3 upload
class GetAvatarUploadUrlResponse extends $pb.GeneratedMessage {
  factory GetAvatarUploadUrlResponse({
    $core.String? uploadUrl,
    $5.Duration? expiresIn,
  }) {
    final result = create();
    if (uploadUrl != null) result.uploadUrl = uploadUrl;
    if (expiresIn != null) result.expiresIn = expiresIn;
    return result;
  }

  GetAvatarUploadUrlResponse._();

  factory GetAvatarUploadUrlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAvatarUploadUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAvatarUploadUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uploadUrl')
    ..aOM<$5.Duration>(2, _omitFieldNames ? '' : 'expiresIn', subBuilder: $5.Duration.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAvatarUploadUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAvatarUploadUrlResponse copyWith(void Function(GetAvatarUploadUrlResponse) updates) =>
      super.copyWith((message) => updates(message as GetAvatarUploadUrlResponse)) as GetAvatarUploadUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAvatarUploadUrlResponse create() => GetAvatarUploadUrlResponse._();
  @$core.override
  GetAvatarUploadUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAvatarUploadUrlResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAvatarUploadUrlResponse>(create);
  static GetAvatarUploadUrlResponse? _defaultInstance;

  /// Presigned PUT URL for S3
  @$pb.TagNumber(1)
  $core.String get uploadUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set uploadUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUploadUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUploadUrl() => $_clearField(1);

  /// URL expiration in seconds
  @$pb.TagNumber(2)
  $5.Duration get expiresIn => $_getN(1);
  @$pb.TagNumber(2)
  set expiresIn($5.Duration value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresIn() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresIn() => $_clearField(2);
  @$pb.TagNumber(2)
  $5.Duration ensureExpiresIn() => $_ensure(1);
}

/// Confirm avatar upload completed
class ConfirmAvatarUploadRequest extends $pb.GeneratedMessage {
  factory ConfirmAvatarUploadRequest({
    $2.UUID? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  ConfirmAvatarUploadRequest._();

  factory ConfirmAvatarUploadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfirmAvatarUploadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmAvatarUploadRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmAvatarUploadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmAvatarUploadRequest copyWith(void Function(ConfirmAvatarUploadRequest) updates) =>
      super.copyWith((message) => updates(message as ConfirmAvatarUploadRequest)) as ConfirmAvatarUploadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmAvatarUploadRequest create() => ConfirmAvatarUploadRequest._();
  @$core.override
  ConfirmAvatarUploadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfirmAvatarUploadRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmAvatarUploadRequest>(create);
  static ConfirmAvatarUploadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureUserId() => $_ensure(0);
}

class DeleteAvatarRequest extends $pb.GeneratedMessage {
  factory DeleteAvatarRequest({
    $2.UUID? userId,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    return result;
  }

  DeleteAvatarRequest._();

  factory DeleteAvatarRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteAvatarRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAvatarRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'users'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAvatarRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAvatarRequest copyWith(void Function(DeleteAvatarRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteAvatarRequest)) as DeleteAvatarRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAvatarRequest create() => DeleteAvatarRequest._();
  @$core.override
  DeleteAvatarRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteAvatarRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteAvatarRequest>(create);
  static DeleteAvatarRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureUserId() => $_ensure(0);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
