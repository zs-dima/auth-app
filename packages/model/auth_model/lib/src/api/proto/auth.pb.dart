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
import 'package:protobuf/well_known_types/google/protobuf/duration.pb.dart' as $4;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $2;

import 'auth.pbenum.dart';
import 'core.pb.dart' as $3;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'auth.pbenum.dart';

class TokenPair extends $pb.GeneratedMessage {
  factory TokenPair({
    $core.String? accessToken,
    $core.String? refreshToken,
    $2.Timestamp? expiresAt,
  }) {
    final result = create();
    if (accessToken != null) result.accessToken = accessToken;
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  TokenPair._();

  factory TokenPair.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TokenPair.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TokenPair',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'accessToken')
    ..aOS(2, _omitFieldNames ? '' : 'refreshToken')
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'expiresAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenPair clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TokenPair copyWith(void Function(TokenPair) updates) =>
      super.copyWith((message) => updates(message as TokenPair)) as TokenPair;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TokenPair create() => TokenPair._();
  @$core.override
  TokenPair createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TokenPair getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenPair>(create);
  static TokenPair? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get accessToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set accessToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAccessToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccessToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get refreshToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set refreshToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRefreshToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearRefreshToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $2.Timestamp get expiresAt => $_getN(2);
  @$pb.TagNumber(3)
  set expiresAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureExpiresAt() => $_ensure(2);
}

/// Client information sent with authentication requests
class ClientInfo extends $pb.GeneratedMessage {
  factory ClientInfo({
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? deviceType,
    $core.String? clientVersion,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientVersion != null) result.clientVersion = clientVersion;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  ClientInfo._();

  factory ClientInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClientInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClientInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'deviceType')
    ..aOS(4, _omitFieldNames ? '' : 'clientVersion')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'ClientInfo.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('auth'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClientInfo copyWith(void Function(ClientInfo) updates) =>
      super.copyWith((message) => updates(message as ClientInfo)) as ClientInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClientInfo create() => ClientInfo._();
  @$core.override
  ClientInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClientInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClientInfo>(create);
  static ClientInfo? _defaultInstance;

  /// Unique device/client identifier
  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  /// Human-readable device name
  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => $_clearField(2);

  /// Device type: 'mobile', 'tablet', 'desktop', 'web', 'unknown'
  @$pb.TagNumber(3)
  $core.String get deviceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  /// App/client version
  @$pb.TagNumber(4)
  $core.String get clientVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientVersion() => $_clearField(4);

  /// Additional metadata (`device_model`, `os_info`, fingerprint, etc.)
  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(4);
}

/// Info returned on successful auth
class UserSnapshot extends $pb.GeneratedMessage {
  factory UserSnapshot({
    $3.UUID? userId,
    $core.String? displayName,
    $core.String? email,
    $core.String? phone,
    $3.UserRole? role,
    $3.UserStatus? status,
    $core.bool? emailVerified,
    $core.bool? phoneVerified,
    $core.bool? mfaEnabled,
    $core.Iterable<OAuthProvider>? linkedProviders,
    $core.String? avatarUrl,
    $core.bool? hasPassword,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (role != null) result.role = role;
    if (status != null) result.status = status;
    if (emailVerified != null) result.emailVerified = emailVerified;
    if (phoneVerified != null) result.phoneVerified = phoneVerified;
    if (mfaEnabled != null) result.mfaEnabled = mfaEnabled;
    if (linkedProviders != null) result.linkedProviders.addAll(linkedProviders);
    if (avatarUrl != null) result.avatarUrl = avatarUrl;
    if (hasPassword != null) result.hasPassword = hasPassword;
    return result;
  }

  UserSnapshot._();

  factory UserSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserSnapshot.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$3.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $3.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aE<$3.UserRole>(5, _omitFieldNames ? '' : 'role', enumValues: $3.UserRole.values)
    ..aE<$3.UserStatus>(6, _omitFieldNames ? '' : 'status', enumValues: $3.UserStatus.values)
    ..aOB(7, _omitFieldNames ? '' : 'emailVerified')
    ..aOB(8, _omitFieldNames ? '' : 'phoneVerified')
    ..aOB(9, _omitFieldNames ? '' : 'mfaEnabled')
    ..pc<OAuthProvider>(10, _omitFieldNames ? '' : 'linkedProviders', $pb.PbFieldType.KE,
        valueOf: OAuthProvider.valueOf,
        enumValues: OAuthProvider.values,
        defaultEnumValue: OAuthProvider.OAUTH_PROVIDER_UNSPECIFIED)
    ..aOS(11, _omitFieldNames ? '' : 'avatarUrl')
    ..aOB(12, _omitFieldNames ? '' : 'hasPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserSnapshot copyWith(void Function(UserSnapshot) updates) =>
      super.copyWith((message) => updates(message as UserSnapshot)) as UserSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserSnapshot create() => UserSnapshot._();
  @$core.override
  UserSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserSnapshot getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserSnapshot>(create);
  static UserSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $3.UUID get userId => $_getN(0);
  @$pb.TagNumber(1)
  set userId($3.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasUserId() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserId() => $_clearField(1);
  @$pb.TagNumber(1)
  $3.UUID ensureUserId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

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
  $3.UserRole get role => $_getN(4);
  @$pb.TagNumber(5)
  set role($3.UserRole value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);

  @$pb.TagNumber(6)
  $3.UserStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status($3.UserStatus value) => $_setField(6, value);
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
  $pb.PbList<OAuthProvider> get linkedProviders => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get avatarUrl => $_getSZ(10);
  @$pb.TagNumber(11)
  set avatarUrl($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAvatarUrl() => $_has(10);
  @$pb.TagNumber(11)
  void clearAvatarUrl() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasPassword => $_getBF(11);
  @$pb.TagNumber(12)
  set hasPassword($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasPassword() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasPassword() => $_clearField(12);
}

/// Account lockout information
class LockoutInfo extends $pb.GeneratedMessage {
  factory LockoutInfo({
    $4.Duration? retryAfter,
    $core.int? failedAttempts,
    $core.int? maxAttempts,
    $2.Timestamp? lockedUntil,
  }) {
    final result = create();
    if (retryAfter != null) result.retryAfter = retryAfter;
    if (failedAttempts != null) result.failedAttempts = failedAttempts;
    if (maxAttempts != null) result.maxAttempts = maxAttempts;
    if (lockedUntil != null) result.lockedUntil = lockedUntil;
    return result;
  }

  LockoutInfo._();

  factory LockoutInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LockoutInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LockoutInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$4.Duration>(1, _omitFieldNames ? '' : 'retryAfter', subBuilder: $4.Duration.create)
    ..aI(2, _omitFieldNames ? '' : 'failedAttempts')
    ..aI(3, _omitFieldNames ? '' : 'maxAttempts')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'lockedUntil', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LockoutInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LockoutInfo copyWith(void Function(LockoutInfo) updates) =>
      super.copyWith((message) => updates(message as LockoutInfo)) as LockoutInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LockoutInfo create() => LockoutInfo._();
  @$core.override
  LockoutInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LockoutInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LockoutInfo>(create);
  static LockoutInfo? _defaultInstance;

  /// Duration until account is unlocked
  @$pb.TagNumber(1)
  $4.Duration get retryAfter => $_getN(0);
  @$pb.TagNumber(1)
  set retryAfter($4.Duration value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRetryAfter() => $_has(0);
  @$pb.TagNumber(1)
  void clearRetryAfter() => $_clearField(1);
  @$pb.TagNumber(1)
  $4.Duration ensureRetryAfter() => $_ensure(0);

  /// Number of failed attempts
  @$pb.TagNumber(2)
  $core.int get failedAttempts => $_getIZ(1);
  @$pb.TagNumber(2)
  set failedAttempts($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFailedAttempts() => $_has(1);
  @$pb.TagNumber(2)
  void clearFailedAttempts() => $_clearField(2);

  /// Maximum attempts before lockout (configurable)
  @$pb.TagNumber(3)
  $core.int get maxAttempts => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxAttempts($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxAttempts() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxAttempts() => $_clearField(3);

  /// Lockout timestamp
  @$pb.TagNumber(4)
  $2.Timestamp get lockedUntil => $_getN(3);
  @$pb.TagNumber(4)
  set lockedUntil($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLockedUntil() => $_has(3);
  @$pb.TagNumber(4)
  void clearLockedUntil() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureLockedUntil() => $_ensure(3);
}

/// MFA challenge - returned when second factor is required
class MfaChallenge extends $pb.GeneratedMessage {
  factory MfaChallenge({
    $core.String? challengeToken,
    $core.Iterable<MfaMethodInfo>? availableMethods,
    $2.Timestamp? expiresAt,
  }) {
    final result = create();
    if (challengeToken != null) result.challengeToken = challengeToken;
    if (availableMethods != null) result.availableMethods.addAll(availableMethods);
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  MfaChallenge._();

  factory MfaChallenge.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaChallenge.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaChallenge',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'challengeToken')
    ..pPM<MfaMethodInfo>(2, _omitFieldNames ? '' : 'availableMethods', subBuilder: MfaMethodInfo.create)
    ..aOM<$2.Timestamp>(3, _omitFieldNames ? '' : 'expiresAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaChallenge clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaChallenge copyWith(void Function(MfaChallenge) updates) =>
      super.copyWith((message) => updates(message as MfaChallenge)) as MfaChallenge;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaChallenge create() => MfaChallenge._();
  @$core.override
  MfaChallenge createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaChallenge getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaChallenge>(create);
  static MfaChallenge? _defaultInstance;

  /// Token to correlate MFA verification with original auth attempt
  @$pb.TagNumber(1)
  $core.String get challengeToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set challengeToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChallengeToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearChallengeToken() => $_clearField(1);

  /// Available MFA methods for this user
  @$pb.TagNumber(2)
  $pb.PbList<MfaMethodInfo> get availableMethods => $_getList(1);

  /// Challenge expiration - typically 5 minutes
  @$pb.TagNumber(3)
  $2.Timestamp get expiresAt => $_getN(2);
  @$pb.TagNumber(3)
  set expiresAt($2.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.Timestamp ensureExpiresAt() => $_ensure(2);
}

/// Information about an available MFA method
class MfaMethodInfo extends $pb.GeneratedMessage {
  factory MfaMethodInfo({
    MfaMethod? method,
    $core.String? hint,
    $core.bool? isDefault,
  }) {
    final result = create();
    if (method != null) result.method = method;
    if (hint != null) result.hint = hint;
    if (isDefault != null) result.isDefault = isDefault;
    return result;
  }

  MfaMethodInfo._();

  factory MfaMethodInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaMethodInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaMethodInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<MfaMethod>(1, _omitFieldNames ? '' : 'method', enumValues: MfaMethod.values)
    ..aOS(2, _omitFieldNames ? '' : 'hint')
    ..aOB(3, _omitFieldNames ? '' : 'isDefault')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaMethodInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaMethodInfo copyWith(void Function(MfaMethodInfo) updates) =>
      super.copyWith((message) => updates(message as MfaMethodInfo)) as MfaMethodInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaMethodInfo create() => MfaMethodInfo._();
  @$core.override
  MfaMethodInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaMethodInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaMethodInfo>(create);
  static MfaMethodInfo? _defaultInstance;

  @$pb.TagNumber(1)
  MfaMethod get method => $_getN(0);
  @$pb.TagNumber(1)
  set method(MfaMethod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  /// Masked hint (e.g., "***-***-1234" for SMS, "john***@gm***.com" for email)
  @$pb.TagNumber(2)
  $core.String get hint => $_getSZ(1);
  @$pb.TagNumber(2)
  set hint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHint() => $_has(1);
  @$pb.TagNumber(2)
  void clearHint() => $_clearField(2);

  /// True if this is the user's preferred/default method
  @$pb.TagNumber(3)
  $core.bool get isDefault => $_getBF(2);
  @$pb.TagNumber(3)
  set isDefault($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsDefault() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsDefault() => $_clearField(3);
}

/// Unified authentication request supporting multiple identifier types
class AuthenticateRequest extends $pb.GeneratedMessage {
  factory AuthenticateRequest({
    $core.String? identifier,
    IdentifierType? identifierType,
    $core.String? password,
    $3.UUID? installationId,
    ClientInfo? clientInfo,
  }) {
    final result = create();
    if (identifier != null) result.identifier = identifier;
    if (identifierType != null) result.identifierType = identifierType;
    if (password != null) result.password = password;
    if (installationId != null) result.installationId = installationId;
    if (clientInfo != null) result.clientInfo = clientInfo;
    return result;
  }

  AuthenticateRequest._();

  factory AuthenticateRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthenticateRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthenticateRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identifier')
    ..aE<IdentifierType>(2, _omitFieldNames ? '' : 'identifierType', enumValues: IdentifierType.values)
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..aOM<$3.UUID>(4, _omitFieldNames ? '' : 'installationId', subBuilder: $3.UUID.create)
    ..aOM<ClientInfo>(5, _omitFieldNames ? '' : 'clientInfo', subBuilder: ClientInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthenticateRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthenticateRequest copyWith(void Function(AuthenticateRequest) updates) =>
      super.copyWith((message) => updates(message as AuthenticateRequest)) as AuthenticateRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthenticateRequest create() => AuthenticateRequest._();
  @$core.override
  AuthenticateRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthenticateRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthenticateRequest>(create);
  static AuthenticateRequest? _defaultInstance;

  /// Primary identifier (email or phone)
  @$pb.TagNumber(1)
  $core.String get identifier => $_getSZ(0);
  @$pb.TagNumber(1)
  set identifier($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => $_clearField(1);

  /// Type of identifier
  @$pb.TagNumber(2)
  IdentifierType get identifierType => $_getN(1);
  @$pb.TagNumber(2)
  set identifierType(IdentifierType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentifierType() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentifierType() => $_clearField(2);

  /// Password (NIST: min 8 chars, check against breach databases)
  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  /// Installation ID for immediate session
  @$pb.TagNumber(4)
  $3.UUID get installationId => $_getN(3);
  @$pb.TagNumber(4)
  set installationId($3.UUID value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasInstallationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInstallationId() => $_clearField(4);
  @$pb.TagNumber(4)
  $3.UUID ensureInstallationId() => $_ensure(3);

  /// Client info for session
  @$pb.TagNumber(5)
  ClientInfo get clientInfo => $_getN(4);
  @$pb.TagNumber(5)
  set clientInfo(ClientInfo value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasClientInfo() => $_has(4);
  @$pb.TagNumber(5)
  void clearClientInfo() => $_clearField(5);
  @$pb.TagNumber(5)
  ClientInfo ensureClientInfo() => $_ensure(4);
}

/// Authentication result
/// Returns tokens on success, or MFA challenge if second factor required
class AuthResponse extends $pb.GeneratedMessage {
  factory AuthResponse({
    AuthStatus? status,
    TokenPair? tokens,
    UserSnapshot? user,
    MfaChallenge? mfaChallenge,
    LockoutInfo? lockoutInfo,
    $core.String? message,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (tokens != null) result.tokens = tokens;
    if (user != null) result.user = user;
    if (mfaChallenge != null) result.mfaChallenge = mfaChallenge;
    if (lockoutInfo != null) result.lockoutInfo = lockoutInfo;
    if (message != null) result.message = message;
    return result;
  }

  AuthResponse._();

  factory AuthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<AuthStatus>(1, _omitFieldNames ? '' : 'status', enumValues: AuthStatus.values)
    ..aOM<TokenPair>(2, _omitFieldNames ? '' : 'tokens', subBuilder: TokenPair.create)
    ..aOM<UserSnapshot>(3, _omitFieldNames ? '' : 'user', subBuilder: UserSnapshot.create)
    ..aOM<MfaChallenge>(4, _omitFieldNames ? '' : 'mfaChallenge', subBuilder: MfaChallenge.create)
    ..aOM<LockoutInfo>(5, _omitFieldNames ? '' : 'lockoutInfo', subBuilder: LockoutInfo.create)
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthResponse copyWith(void Function(AuthResponse) updates) =>
      super.copyWith((message) => updates(message as AuthResponse)) as AuthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthResponse create() => AuthResponse._();
  @$core.override
  AuthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthResponse>(create);
  static AuthResponse? _defaultInstance;

  /// Status of authentication attempt
  @$pb.TagNumber(1)
  AuthStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(AuthStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  @$pb.TagNumber(2)
  TokenPair get tokens => $_getN(1);
  @$pb.TagNumber(2)
  set tokens(TokenPair value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTokens() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokens() => $_clearField(2);
  @$pb.TagNumber(2)
  TokenPair ensureTokens() => $_ensure(1);

  @$pb.TagNumber(3)
  UserSnapshot get user => $_getN(2);
  @$pb.TagNumber(3)
  set user(UserSnapshot value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUser() => $_has(2);
  @$pb.TagNumber(3)
  void clearUser() => $_clearField(3);
  @$pb.TagNumber(3)
  UserSnapshot ensureUser() => $_ensure(2);

  /// Populated on AUTH_STATUS_MFA_REQUIRED
  @$pb.TagNumber(4)
  MfaChallenge get mfaChallenge => $_getN(3);
  @$pb.TagNumber(4)
  set mfaChallenge(MfaChallenge value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMfaChallenge() => $_has(3);
  @$pb.TagNumber(4)
  void clearMfaChallenge() => $_clearField(4);
  @$pb.TagNumber(4)
  MfaChallenge ensureMfaChallenge() => $_ensure(3);

  /// Populated on AUTH_STATUS_LOCKED
  @$pb.TagNumber(5)
  LockoutInfo get lockoutInfo => $_getN(4);
  @$pb.TagNumber(5)
  set lockoutInfo(LockoutInfo value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLockoutInfo() => $_has(4);
  @$pb.TagNumber(5)
  void clearLockoutInfo() => $_clearField(5);
  @$pb.TagNumber(5)
  LockoutInfo ensureLockoutInfo() => $_ensure(4);

  /// Message for user (generic per OWASP - prevent enumeration)
  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);
}

/// Register a new user account
class SignUpRequest extends $pb.GeneratedMessage {
  factory SignUpRequest({
    $core.String? identifier,
    IdentifierType? identifierType,
    $core.String? password,
    $core.String? displayName,
    $3.UUID? installationId,
    ClientInfo? clientInfo,
    $core.String? locale,
    $core.String? timezone,
  }) {
    final result = create();
    if (identifier != null) result.identifier = identifier;
    if (identifierType != null) result.identifierType = identifierType;
    if (password != null) result.password = password;
    if (displayName != null) result.displayName = displayName;
    if (installationId != null) result.installationId = installationId;
    if (clientInfo != null) result.clientInfo = clientInfo;
    if (locale != null) result.locale = locale;
    if (timezone != null) result.timezone = timezone;
    return result;
  }

  SignUpRequest._();

  factory SignUpRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignUpRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignUpRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identifier')
    ..aE<IdentifierType>(2, _omitFieldNames ? '' : 'identifierType', enumValues: IdentifierType.values)
    ..aOS(3, _omitFieldNames ? '' : 'password')
    ..aOS(4, _omitFieldNames ? '' : 'displayName')
    ..aOM<$3.UUID>(5, _omitFieldNames ? '' : 'installationId', subBuilder: $3.UUID.create)
    ..aOM<ClientInfo>(6, _omitFieldNames ? '' : 'clientInfo', subBuilder: ClientInfo.create)
    ..aOS(7, _omitFieldNames ? '' : 'locale')
    ..aOS(8, _omitFieldNames ? '' : 'timezone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignUpRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignUpRequest copyWith(void Function(SignUpRequest) updates) =>
      super.copyWith((message) => updates(message as SignUpRequest)) as SignUpRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignUpRequest create() => SignUpRequest._();
  @$core.override
  SignUpRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignUpRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignUpRequest>(create);
  static SignUpRequest? _defaultInstance;

  /// User identifier (email or phone in E.164 format)
  @$pb.TagNumber(1)
  $core.String get identifier => $_getSZ(0);
  @$pb.TagNumber(1)
  set identifier($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => $_clearField(1);

  /// Type of identifier (auto-detected if not specified based on format)
  @$pb.TagNumber(2)
  IdentifierType get identifierType => $_getN(1);
  @$pb.TagNumber(2)
  set identifierType(IdentifierType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentifierType() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentifierType() => $_clearField(2);

  /// Password
  @$pb.TagNumber(3)
  $core.String get password => $_getSZ(2);
  @$pb.TagNumber(3)
  set password($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPassword() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassword() => $_clearField(3);

  /// Display name
  @$pb.TagNumber(4)
  $core.String get displayName => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDisplayName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayName() => $_clearField(4);

  /// Unique installation/app instance ID
  @$pb.TagNumber(5)
  $3.UUID get installationId => $_getN(4);
  @$pb.TagNumber(5)
  set installationId($3.UUID value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasInstallationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInstallationId() => $_clearField(5);
  @$pb.TagNumber(5)
  $3.UUID ensureInstallationId() => $_ensure(4);

  /// Client/device information for session (stored in sessions table)
  @$pb.TagNumber(6)
  ClientInfo get clientInfo => $_getN(5);
  @$pb.TagNumber(6)
  set clientInfo(ClientInfo value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasClientInfo() => $_has(5);
  @$pb.TagNumber(6)
  void clearClientInfo() => $_clearField(6);
  @$pb.TagNumber(6)
  ClientInfo ensureClientInfo() => $_ensure(5);

  /// Locale (BCP 47, e.g., `en-US`)
  @$pb.TagNumber(7)
  $core.String get locale => $_getSZ(6);
  @$pb.TagNumber(7)
  set locale($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLocale() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocale() => $_clearField(7);

  /// Timezone (IANA, e.g., `America/New_York`)
  @$pb.TagNumber(8)
  $core.String get timezone => $_getSZ(7);
  @$pb.TagNumber(8)
  set timezone($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTimezone() => $_has(7);
  @$pb.TagNumber(8)
  void clearTimezone() => $_clearField(8);
}

/// Verify MFA code to complete authentication
class VerifyMfaRequest extends $pb.GeneratedMessage {
  factory VerifyMfaRequest({
    $core.String? challengeToken,
    MfaMethod? method,
    $core.String? code,
    ClientInfo? clientInfo,
  }) {
    final result = create();
    if (challengeToken != null) result.challengeToken = challengeToken;
    if (method != null) result.method = method;
    if (code != null) result.code = code;
    if (clientInfo != null) result.clientInfo = clientInfo;
    return result;
  }

  VerifyMfaRequest._();

  factory VerifyMfaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyMfaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyMfaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'challengeToken')
    ..aE<MfaMethod>(2, _omitFieldNames ? '' : 'method', enumValues: MfaMethod.values)
    ..aOS(3, _omitFieldNames ? '' : 'code')
    ..aOM<ClientInfo>(4, _omitFieldNames ? '' : 'clientInfo', subBuilder: ClientInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMfaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyMfaRequest copyWith(void Function(VerifyMfaRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyMfaRequest)) as VerifyMfaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyMfaRequest create() => VerifyMfaRequest._();
  @$core.override
  VerifyMfaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyMfaRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyMfaRequest>(create);
  static VerifyMfaRequest? _defaultInstance;

  /// Challenge token from MfaChallenge
  @$pb.TagNumber(1)
  $core.String get challengeToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set challengeToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChallengeToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearChallengeToken() => $_clearField(1);

  /// Method used for verification
  @$pb.TagNumber(2)
  MfaMethod get method => $_getN(1);
  @$pb.TagNumber(2)
  set method(MfaMethod value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMethod() => $_has(1);
  @$pb.TagNumber(2)
  void clearMethod() => $_clearField(2);

  /// Verification code (6-digit TOTP, SMS code, recovery code, etc.)
  @$pb.TagNumber(3)
  $core.String get code => $_getSZ(2);
  @$pb.TagNumber(3)
  set code($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCode() => $_has(2);
  @$pb.TagNumber(3)
  void clearCode() => $_clearField(3);

  /// Client info for session creation
  @$pb.TagNumber(4)
  ClientInfo get clientInfo => $_getN(3);
  @$pb.TagNumber(4)
  set clientInfo(ClientInfo value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasClientInfo() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientInfo() => $_clearField(4);
  @$pb.TagNumber(4)
  ClientInfo ensureClientInfo() => $_ensure(3);
}

class RefreshTokensRequest extends $pb.GeneratedMessage {
  factory RefreshTokensRequest({
    $core.String? refreshToken,
  }) {
    final result = create();
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshTokensRequest._();

  factory RefreshTokensRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokensRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshTokensRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokensRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokensRequest copyWith(void Function(RefreshTokensRequest) updates) =>
      super.copyWith((message) => updates(message as RefreshTokensRequest)) as RefreshTokensRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokensRequest create() => RefreshTokensRequest._();
  @$core.override
  RefreshTokensRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokensRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshTokensRequest>(create);
  static RefreshTokensRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);
}

class ValidateCredentialsRequest extends $pb.GeneratedMessage {
  factory ValidateCredentialsRequest() => create();

  ValidateCredentialsRequest._();

  factory ValidateCredentialsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateCredentialsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateCredentialsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateCredentialsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateCredentialsRequest copyWith(void Function(ValidateCredentialsRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateCredentialsRequest)) as ValidateCredentialsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateCredentialsRequest create() => ValidateCredentialsRequest._();
  @$core.override
  ValidateCredentialsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateCredentialsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateCredentialsRequest>(create);
  static ValidateCredentialsRequest? _defaultInstance;
}

class ValidateCredentialsResponse extends $pb.GeneratedMessage {
  factory ValidateCredentialsResponse({
    $core.bool? valid,
    UserSnapshot? user,
  }) {
    final result = create();
    if (valid != null) result.valid = valid;
    if (user != null) result.user = user;
    return result;
  }

  ValidateCredentialsResponse._();

  factory ValidateCredentialsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ValidateCredentialsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateCredentialsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOM<UserSnapshot>(2, _omitFieldNames ? '' : 'user', subBuilder: UserSnapshot.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateCredentialsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateCredentialsResponse copyWith(void Function(ValidateCredentialsResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateCredentialsResponse)) as ValidateCredentialsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidateCredentialsResponse create() => ValidateCredentialsResponse._();
  @$core.override
  ValidateCredentialsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ValidateCredentialsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidateCredentialsResponse>(create);
  static ValidateCredentialsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  @$pb.TagNumber(2)
  UserSnapshot get user => $_getN(1);
  @$pb.TagNumber(2)
  set user(UserSnapshot value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUser() => $_has(1);
  @$pb.TagNumber(2)
  void clearUser() => $_clearField(2);
  @$pb.TagNumber(2)
  UserSnapshot ensureUser() => $_ensure(1);
}

class SignOutRequest extends $pb.GeneratedMessage {
  factory SignOutRequest() => create();

  SignOutRequest._();

  factory SignOutRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SignOutRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignOutRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignOutRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignOutRequest copyWith(void Function(SignOutRequest) updates) =>
      super.copyWith((message) => updates(message as SignOutRequest)) as SignOutRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignOutRequest create() => SignOutRequest._();
  @$core.override
  SignOutRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SignOutRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignOutRequest>(create);
  static SignOutRequest? _defaultInstance;
}

/// Get OAuth authorization URL
class GetOAuthUrlRequest extends $pb.GeneratedMessage {
  factory GetOAuthUrlRequest({
    OAuthProvider? provider,
    $core.String? redirectUri,
    $core.Iterable<$core.String>? scopes,
    $core.String? stateData,
  }) {
    final result = create();
    if (provider != null) result.provider = provider;
    if (redirectUri != null) result.redirectUri = redirectUri;
    if (scopes != null) result.scopes.addAll(scopes);
    if (stateData != null) result.stateData = stateData;
    return result;
  }

  GetOAuthUrlRequest._();

  factory GetOAuthUrlRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOAuthUrlRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOAuthUrlRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<OAuthProvider>(1, _omitFieldNames ? '' : 'provider', enumValues: OAuthProvider.values)
    ..aOS(2, _omitFieldNames ? '' : 'redirectUri')
    ..pPS(3, _omitFieldNames ? '' : 'scopes')
    ..aOS(4, _omitFieldNames ? '' : 'stateData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOAuthUrlRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOAuthUrlRequest copyWith(void Function(GetOAuthUrlRequest) updates) =>
      super.copyWith((message) => updates(message as GetOAuthUrlRequest)) as GetOAuthUrlRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOAuthUrlRequest create() => GetOAuthUrlRequest._();
  @$core.override
  GetOAuthUrlRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetOAuthUrlRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOAuthUrlRequest>(create);
  static GetOAuthUrlRequest? _defaultInstance;

  /// OAuth provider
  @$pb.TagNumber(1)
  OAuthProvider get provider => $_getN(0);
  @$pb.TagNumber(1)
  set provider(OAuthProvider value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProvider() => $_has(0);
  @$pb.TagNumber(1)
  void clearProvider() => $_clearField(1);

  /// Optional: redirect URI override
  @$pb.TagNumber(2)
  $core.String get redirectUri => $_getSZ(1);
  @$pb.TagNumber(2)
  set redirectUri($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRedirectUri() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedirectUri() => $_clearField(2);

  /// Optional: additional scopes
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get scopes => $_getList(2);

  /// Optional: state data to preserve across OAuth flow
  @$pb.TagNumber(4)
  $core.String get stateData => $_getSZ(3);
  @$pb.TagNumber(4)
  set stateData($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStateData() => $_has(3);
  @$pb.TagNumber(4)
  void clearStateData() => $_clearField(4);
}

/// OAuth URL response
class GetOAuthUrlResponse extends $pb.GeneratedMessage {
  factory GetOAuthUrlResponse({
    $core.String? authorizationUrl,
    $core.String? state,
  }) {
    final result = create();
    if (authorizationUrl != null) result.authorizationUrl = authorizationUrl;
    if (state != null) result.state = state;
    return result;
  }

  GetOAuthUrlResponse._();

  factory GetOAuthUrlResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetOAuthUrlResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetOAuthUrlResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'authorizationUrl')
    ..aOS(2, _omitFieldNames ? '' : 'state')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOAuthUrlResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetOAuthUrlResponse copyWith(void Function(GetOAuthUrlResponse) updates) =>
      super.copyWith((message) => updates(message as GetOAuthUrlResponse)) as GetOAuthUrlResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetOAuthUrlResponse create() => GetOAuthUrlResponse._();
  @$core.override
  GetOAuthUrlResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetOAuthUrlResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetOAuthUrlResponse>(create);
  static GetOAuthUrlResponse? _defaultInstance;

  /// Authorization URL to redirect user
  @$pb.TagNumber(1)
  $core.String get authorizationUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set authorizationUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAuthorizationUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearAuthorizationUrl() => $_clearField(1);

  /// State parameter (for CSRF protection)
  @$pb.TagNumber(2)
  $core.String get state => $_getSZ(1);
  @$pb.TagNumber(2)
  set state($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);
}

/// Exchange OAuth authorization code
class ExchangeOAuthCodeRequest extends $pb.GeneratedMessage {
  factory ExchangeOAuthCodeRequest({
    $core.String? code,
    $core.String? state,
    $3.UUID? installationId,
    ClientInfo? clientInfo,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (state != null) result.state = state;
    if (installationId != null) result.installationId = installationId;
    if (clientInfo != null) result.clientInfo = clientInfo;
    return result;
  }

  ExchangeOAuthCodeRequest._();

  factory ExchangeOAuthCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExchangeOAuthCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExchangeOAuthCodeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'state')
    ..aOM<$3.UUID>(3, _omitFieldNames ? '' : 'installationId', subBuilder: $3.UUID.create)
    ..aOM<ClientInfo>(4, _omitFieldNames ? '' : 'clientInfo', subBuilder: ClientInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeOAuthCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExchangeOAuthCodeRequest copyWith(void Function(ExchangeOAuthCodeRequest) updates) =>
      super.copyWith((message) => updates(message as ExchangeOAuthCodeRequest)) as ExchangeOAuthCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExchangeOAuthCodeRequest create() => ExchangeOAuthCodeRequest._();
  @$core.override
  ExchangeOAuthCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExchangeOAuthCodeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExchangeOAuthCodeRequest>(create);
  static ExchangeOAuthCodeRequest? _defaultInstance;

  /// Authorization code from OAuth callback
  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  /// State parameter from callback
  @$pb.TagNumber(2)
  $core.String get state => $_getSZ(1);
  @$pb.TagNumber(2)
  set state($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);

  /// Installation ID
  @$pb.TagNumber(3)
  $3.UUID get installationId => $_getN(2);
  @$pb.TagNumber(3)
  set installationId($3.UUID value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInstallationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstallationId() => $_clearField(3);
  @$pb.TagNumber(3)
  $3.UUID ensureInstallationId() => $_ensure(2);

  /// Client info
  @$pb.TagNumber(4)
  ClientInfo get clientInfo => $_getN(3);
  @$pb.TagNumber(4)
  set clientInfo(ClientInfo value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasClientInfo() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientInfo() => $_clearField(4);
  @$pb.TagNumber(4)
  ClientInfo ensureClientInfo() => $_ensure(3);
}

/// Link OAuth provider to existing account
class LinkOAuthProviderRequest extends $pb.GeneratedMessage {
  factory LinkOAuthProviderRequest({
    $core.String? code,
    $core.String? state,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (state != null) result.state = state;
    return result;
  }

  LinkOAuthProviderRequest._();

  factory LinkOAuthProviderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LinkOAuthProviderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkOAuthProviderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'state')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkOAuthProviderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkOAuthProviderRequest copyWith(void Function(LinkOAuthProviderRequest) updates) =>
      super.copyWith((message) => updates(message as LinkOAuthProviderRequest)) as LinkOAuthProviderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkOAuthProviderRequest create() => LinkOAuthProviderRequest._();
  @$core.override
  LinkOAuthProviderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LinkOAuthProviderRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkOAuthProviderRequest>(create);
  static LinkOAuthProviderRequest? _defaultInstance;

  /// Authorization code from OAuth callback
  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  /// State parameter
  @$pb.TagNumber(2)
  $core.String get state => $_getSZ(1);
  @$pb.TagNumber(2)
  set state($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);
}

/// Unlink OAuth provider
class UnlinkOAuthProviderRequest extends $pb.GeneratedMessage {
  factory UnlinkOAuthProviderRequest({
    OAuthProvider? provider,
  }) {
    final result = create();
    if (provider != null) result.provider = provider;
    return result;
  }

  UnlinkOAuthProviderRequest._();

  factory UnlinkOAuthProviderRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnlinkOAuthProviderRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlinkOAuthProviderRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<OAuthProvider>(1, _omitFieldNames ? '' : 'provider', enumValues: OAuthProvider.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlinkOAuthProviderRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlinkOAuthProviderRequest copyWith(void Function(UnlinkOAuthProviderRequest) updates) =>
      super.copyWith((message) => updates(message as UnlinkOAuthProviderRequest)) as UnlinkOAuthProviderRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnlinkOAuthProviderRequest create() => UnlinkOAuthProviderRequest._();
  @$core.override
  UnlinkOAuthProviderRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnlinkOAuthProviderRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlinkOAuthProviderRequest>(create);
  static UnlinkOAuthProviderRequest? _defaultInstance;

  @$pb.TagNumber(1)
  OAuthProvider get provider => $_getN(0);
  @$pb.TagNumber(1)
  set provider(OAuthProvider value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProvider() => $_has(0);
  @$pb.TagNumber(1)
  void clearProvider() => $_clearField(1);
}

class ListLinkedProvidersRequest extends $pb.GeneratedMessage {
  factory ListLinkedProvidersRequest() => create();

  ListLinkedProvidersRequest._();

  factory ListLinkedProvidersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLinkedProvidersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListLinkedProvidersRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLinkedProvidersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLinkedProvidersRequest copyWith(void Function(ListLinkedProvidersRequest) updates) =>
      super.copyWith((message) => updates(message as ListLinkedProvidersRequest)) as ListLinkedProvidersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLinkedProvidersRequest create() => ListLinkedProvidersRequest._();
  @$core.override
  ListLinkedProvidersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLinkedProvidersRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListLinkedProvidersRequest>(create);
  static ListLinkedProvidersRequest? _defaultInstance;
}

/// Linked OAuth providers response
class ListLinkedProvidersResponse extends $pb.GeneratedMessage {
  factory ListLinkedProvidersResponse({
    $core.Iterable<LinkedProvider>? providers,
  }) {
    final result = create();
    if (providers != null) result.providers.addAll(providers);
    return result;
  }

  ListLinkedProvidersResponse._();

  factory ListLinkedProvidersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLinkedProvidersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListLinkedProvidersResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..pPM<LinkedProvider>(1, _omitFieldNames ? '' : 'providers', subBuilder: LinkedProvider.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLinkedProvidersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLinkedProvidersResponse copyWith(void Function(ListLinkedProvidersResponse) updates) =>
      super.copyWith((message) => updates(message as ListLinkedProvidersResponse)) as ListLinkedProvidersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLinkedProvidersResponse create() => ListLinkedProvidersResponse._();
  @$core.override
  ListLinkedProvidersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLinkedProvidersResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListLinkedProvidersResponse>(create);
  static ListLinkedProvidersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LinkedProvider> get providers => $_getList(0);
}

class LinkedProvider extends $pb.GeneratedMessage {
  factory LinkedProvider({
    OAuthProvider? provider,
    $core.String? providerUserId,
    $core.String? email,
    $2.Timestamp? linkedAt,
  }) {
    final result = create();
    if (provider != null) result.provider = provider;
    if (providerUserId != null) result.providerUserId = providerUserId;
    if (email != null) result.email = email;
    if (linkedAt != null) result.linkedAt = linkedAt;
    return result;
  }

  LinkedProvider._();

  factory LinkedProvider.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LinkedProvider.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkedProvider',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<OAuthProvider>(1, _omitFieldNames ? '' : 'provider', enumValues: OAuthProvider.values)
    ..aOS(2, _omitFieldNames ? '' : 'providerUserId')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'linkedAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkedProvider clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkedProvider copyWith(void Function(LinkedProvider) updates) =>
      super.copyWith((message) => updates(message as LinkedProvider)) as LinkedProvider;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkedProvider create() => LinkedProvider._();
  @$core.override
  LinkedProvider createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LinkedProvider getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkedProvider>(create);
  static LinkedProvider? _defaultInstance;

  @$pb.TagNumber(1)
  OAuthProvider get provider => $_getN(0);
  @$pb.TagNumber(1)
  set provider(OAuthProvider value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasProvider() => $_has(0);
  @$pb.TagNumber(1)
  void clearProvider() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get providerUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set providerUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProviderUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearProviderUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $2.Timestamp get linkedAt => $_getN(3);
  @$pb.TagNumber(4)
  set linkedAt($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLinkedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLinkedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureLinkedAt() => $_ensure(3);
}

/// Start account recovery (password reset)
/// Always returns success to prevent user enumeration (OWASP)
class RecoveryStartRequest extends $pb.GeneratedMessage {
  factory RecoveryStartRequest({
    $core.String? identifier,
    IdentifierType? identifierType,
  }) {
    final result = create();
    if (identifier != null) result.identifier = identifier;
    if (identifierType != null) result.identifierType = identifierType;
    return result;
  }

  RecoveryStartRequest._();

  factory RecoveryStartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecoveryStartRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecoveryStartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'identifier')
    ..aE<IdentifierType>(2, _omitFieldNames ? '' : 'identifierType', enumValues: IdentifierType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecoveryStartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecoveryStartRequest copyWith(void Function(RecoveryStartRequest) updates) =>
      super.copyWith((message) => updates(message as RecoveryStartRequest)) as RecoveryStartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecoveryStartRequest create() => RecoveryStartRequest._();
  @$core.override
  RecoveryStartRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecoveryStartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecoveryStartRequest>(create);
  static RecoveryStartRequest? _defaultInstance;

  /// Email or phone number (used to look up account)
  @$pb.TagNumber(1)
  $core.String get identifier => $_getSZ(0);
  @$pb.TagNumber(1)
  set identifier($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIdentifier() => $_has(0);
  @$pb.TagNumber(1)
  void clearIdentifier() => $_clearField(1);

  /// Identifier type (email or phone)
  @$pb.TagNumber(2)
  IdentifierType get identifierType => $_getN(1);
  @$pb.TagNumber(2)
  set identifierType(IdentifierType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentifierType() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentifierType() => $_clearField(2);
}

/// Confirm recovery and set new password
class RecoveryConfirmRequest extends $pb.GeneratedMessage {
  factory RecoveryConfirmRequest({
    $core.String? token,
    $core.String? newPassword,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (newPassword != null) result.newPassword = newPassword;
    return result;
  }

  RecoveryConfirmRequest._();

  factory RecoveryConfirmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecoveryConfirmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecoveryConfirmRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aOS(2, _omitFieldNames ? '' : 'newPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecoveryConfirmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecoveryConfirmRequest copyWith(void Function(RecoveryConfirmRequest) updates) =>
      super.copyWith((message) => updates(message as RecoveryConfirmRequest)) as RecoveryConfirmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecoveryConfirmRequest create() => RecoveryConfirmRequest._();
  @$core.override
  RecoveryConfirmRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecoveryConfirmRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecoveryConfirmRequest>(create);
  static RecoveryConfirmRequest? _defaultInstance;

  /// Recovery token from email/SMS
  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  /// New password (NIST: min 8 chars with MFA, min 15 without)
  @$pb.TagNumber(2)
  $core.String get newPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPassword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPassword() => $_clearField(2);
}

/// Change password (requires current password)
class ChangePasswordRequest extends $pb.GeneratedMessage {
  factory ChangePasswordRequest({
    $core.String? currentPassword,
    $core.String? newPassword,
  }) {
    final result = create();
    if (currentPassword != null) result.currentPassword = currentPassword;
    if (newPassword != null) result.newPassword = newPassword;
    return result;
  }

  ChangePasswordRequest._();

  factory ChangePasswordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ChangePasswordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'currentPassword')
    ..aOS(2, _omitFieldNames ? '' : 'newPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest copyWith(void Function(ChangePasswordRequest) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordRequest)) as ChangePasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest create() => ChangePasswordRequest._();
  @$core.override
  ChangePasswordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChangePasswordRequest>(create);
  static ChangePasswordRequest? _defaultInstance;

  /// Current password for verification
  @$pb.TagNumber(1)
  $core.String get currentPassword => $_getSZ(0);
  @$pb.TagNumber(1)
  set currentPassword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrentPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentPassword() => $_clearField(1);

  /// New password
  @$pb.TagNumber(2)
  $core.String get newPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPassword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPassword() => $_clearField(2);
}

class RequestVerificationRequest extends $pb.GeneratedMessage {
  factory RequestVerificationRequest({
    VerificationType? type,
  }) {
    final result = create();
    if (type != null) result.type = type;
    return result;
  }

  RequestVerificationRequest._();

  factory RequestVerificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestVerificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RequestVerificationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<VerificationType>(1, _omitFieldNames ? '' : 'type', enumValues: VerificationType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestVerificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestVerificationRequest copyWith(void Function(RequestVerificationRequest) updates) =>
      super.copyWith((message) => updates(message as RequestVerificationRequest)) as RequestVerificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestVerificationRequest create() => RequestVerificationRequest._();
  @$core.override
  RequestVerificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestVerificationRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RequestVerificationRequest>(create);
  static RequestVerificationRequest? _defaultInstance;

  /// Type of verification
  @$pb.TagNumber(1)
  VerificationType get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(VerificationType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);
}

class ConfirmVerificationRequest extends $pb.GeneratedMessage {
  factory ConfirmVerificationRequest({
    $core.String? token,
    VerificationType? type,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (type != null) result.type = type;
    return result;
  }

  ConfirmVerificationRequest._();

  factory ConfirmVerificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfirmVerificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmVerificationRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'token')
    ..aE<VerificationType>(2, _omitFieldNames ? '' : 'type', enumValues: VerificationType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmVerificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmVerificationRequest copyWith(void Function(ConfirmVerificationRequest) updates) =>
      super.copyWith((message) => updates(message as ConfirmVerificationRequest)) as ConfirmVerificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmVerificationRequest create() => ConfirmVerificationRequest._();
  @$core.override
  ConfirmVerificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfirmVerificationRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmVerificationRequest>(create);
  static ConfirmVerificationRequest? _defaultInstance;

  /// Verification token from email/SMS
  @$pb.TagNumber(1)
  $core.String get token => $_getSZ(0);
  @$pb.TagNumber(1)
  set token($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => $_clearField(1);

  /// Type of verification
  @$pb.TagNumber(2)
  VerificationType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(VerificationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);
}

/// =============================================================================
/// MFA
/// =============================================================================
class GetMfaStatusRequest extends $pb.GeneratedMessage {
  factory GetMfaStatusRequest() => create();

  GetMfaStatusRequest._();

  factory GetMfaStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMfaStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMfaStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMfaStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMfaStatusRequest copyWith(void Function(GetMfaStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetMfaStatusRequest)) as GetMfaStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMfaStatusRequest create() => GetMfaStatusRequest._();
  @$core.override
  GetMfaStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMfaStatusRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMfaStatusRequest>(create);
  static GetMfaStatusRequest? _defaultInstance;
}

/// MFA status for current user
class GetMfaStatusResponse extends $pb.GeneratedMessage {
  factory GetMfaStatusResponse({
    $core.bool? enabled,
    $core.Iterable<MfaMethodStatus>? methods,
    $core.int? recoveryCodesRemaining,
  }) {
    final result = create();
    if (enabled != null) result.enabled = enabled;
    if (methods != null) result.methods.addAll(methods);
    if (recoveryCodesRemaining != null) result.recoveryCodesRemaining = recoveryCodesRemaining;
    return result;
  }

  GetMfaStatusResponse._();

  factory GetMfaStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetMfaStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMfaStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..pPM<MfaMethodStatus>(2, _omitFieldNames ? '' : 'methods', subBuilder: MfaMethodStatus.create)
    ..aI(3, _omitFieldNames ? '' : 'recoveryCodesRemaining')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMfaStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMfaStatusResponse copyWith(void Function(GetMfaStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetMfaStatusResponse)) as GetMfaStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMfaStatusResponse create() => GetMfaStatusResponse._();
  @$core.override
  GetMfaStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetMfaStatusResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMfaStatusResponse>(create);
  static GetMfaStatusResponse? _defaultInstance;

  /// Whether MFA is enabled
  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  /// Configured MFA methods
  @$pb.TagNumber(2)
  $pb.PbList<MfaMethodStatus> get methods => $_getList(1);

  /// Number of unused recovery codes remaining
  @$pb.TagNumber(3)
  $core.int get recoveryCodesRemaining => $_getIZ(2);
  @$pb.TagNumber(3)
  set recoveryCodesRemaining($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecoveryCodesRemaining() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecoveryCodesRemaining() => $_clearField(3);
}

/// Status of a configured MFA method
class MfaMethodStatus extends $pb.GeneratedMessage {
  factory MfaMethodStatus({
    MfaMethod? method,
    $core.bool? enabled,
    $core.String? hint,
    $2.Timestamp? configuredAt,
  }) {
    final result = create();
    if (method != null) result.method = method;
    if (enabled != null) result.enabled = enabled;
    if (hint != null) result.hint = hint;
    if (configuredAt != null) result.configuredAt = configuredAt;
    return result;
  }

  MfaMethodStatus._();

  factory MfaMethodStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaMethodStatus.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaMethodStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<MfaMethod>(1, _omitFieldNames ? '' : 'method', enumValues: MfaMethod.values)
    ..aOB(2, _omitFieldNames ? '' : 'enabled')
    ..aOS(3, _omitFieldNames ? '' : 'hint')
    ..aOM<$2.Timestamp>(4, _omitFieldNames ? '' : 'configuredAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaMethodStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaMethodStatus copyWith(void Function(MfaMethodStatus) updates) =>
      super.copyWith((message) => updates(message as MfaMethodStatus)) as MfaMethodStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaMethodStatus create() => MfaMethodStatus._();
  @$core.override
  MfaMethodStatus createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaMethodStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaMethodStatus>(create);
  static MfaMethodStatus? _defaultInstance;

  @$pb.TagNumber(1)
  MfaMethod get method => $_getN(0);
  @$pb.TagNumber(1)
  set method(MfaMethod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get enabled => $_getBF(1);
  @$pb.TagNumber(2)
  set enabled($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEnabled() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnabled() => $_clearField(2);

  /// Masked hint for this method
  @$pb.TagNumber(3)
  $core.String get hint => $_getSZ(2);
  @$pb.TagNumber(3)
  set hint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHint() => $_has(2);
  @$pb.TagNumber(3)
  void clearHint() => $_clearField(3);

  /// When this method was configured
  @$pb.TagNumber(4)
  $2.Timestamp get configuredAt => $_getN(3);
  @$pb.TagNumber(4)
  set configuredAt($2.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasConfiguredAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfiguredAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.Timestamp ensureConfiguredAt() => $_ensure(3);
}

/// Request to set up MFA
class SetupMfaRequest extends $pb.GeneratedMessage {
  factory SetupMfaRequest({
    MfaMethod? method,
    $core.String? identifier,
  }) {
    final result = create();
    if (method != null) result.method = method;
    if (identifier != null) result.identifier = identifier;
    return result;
  }

  SetupMfaRequest._();

  factory SetupMfaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetupMfaRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetupMfaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<MfaMethod>(1, _omitFieldNames ? '' : 'method', enumValues: MfaMethod.values)
    ..aOS(2, _omitFieldNames ? '' : 'identifier')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetupMfaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetupMfaRequest copyWith(void Function(SetupMfaRequest) updates) =>
      super.copyWith((message) => updates(message as SetupMfaRequest)) as SetupMfaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetupMfaRequest create() => SetupMfaRequest._();
  @$core.override
  SetupMfaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetupMfaRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetupMfaRequest>(create);
  static SetupMfaRequest? _defaultInstance;

  /// Method to set up
  @$pb.TagNumber(1)
  MfaMethod get method => $_getN(0);
  @$pb.TagNumber(1)
  set method(MfaMethod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  /// For SMS/Email: the phone/email to use (must be verified)
  @$pb.TagNumber(2)
  $core.String get identifier => $_getSZ(1);
  @$pb.TagNumber(2)
  set identifier($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIdentifier() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentifier() => $_clearField(2);
}

/// MFA setup response
class SetupMfaResponse extends $pb.GeneratedMessage {
  factory SetupMfaResponse({
    $core.String? secret,
    $core.String? provisioningUri,
    $core.String? maskedDestination,
    $core.String? setupToken,
    $2.Timestamp? expiresAt,
  }) {
    final result = create();
    if (secret != null) result.secret = secret;
    if (provisioningUri != null) result.provisioningUri = provisioningUri;
    if (maskedDestination != null) result.maskedDestination = maskedDestination;
    if (setupToken != null) result.setupToken = setupToken;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  SetupMfaResponse._();

  factory SetupMfaResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetupMfaResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetupMfaResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'secret')
    ..aOS(2, _omitFieldNames ? '' : 'provisioningUri')
    ..aOS(3, _omitFieldNames ? '' : 'maskedDestination')
    ..aOS(4, _omitFieldNames ? '' : 'setupToken')
    ..aOM<$2.Timestamp>(5, _omitFieldNames ? '' : 'expiresAt', subBuilder: $2.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetupMfaResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetupMfaResponse copyWith(void Function(SetupMfaResponse) updates) =>
      super.copyWith((message) => updates(message as SetupMfaResponse)) as SetupMfaResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetupMfaResponse create() => SetupMfaResponse._();
  @$core.override
  SetupMfaResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetupMfaResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetupMfaResponse>(create);
  static SetupMfaResponse? _defaultInstance;

  /// For TOTP: base32-encoded secret
  @$pb.TagNumber(1)
  $core.String get secret => $_getSZ(0);
  @$pb.TagNumber(1)
  set secret($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSecret() => $_has(0);
  @$pb.TagNumber(1)
  void clearSecret() => $_clearField(1);

  /// For TOTP: otpauth:// URI for QR code generation
  @$pb.TagNumber(2)
  $core.String get provisioningUri => $_getSZ(1);
  @$pb.TagNumber(2)
  set provisioningUri($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProvisioningUri() => $_has(1);
  @$pb.TagNumber(2)
  void clearProvisioningUri() => $_clearField(2);

  /// For SMS/Email: masked destination where code was sent
  @$pb.TagNumber(3)
  $core.String get maskedDestination => $_getSZ(2);
  @$pb.TagNumber(3)
  set maskedDestination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaskedDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaskedDestination() => $_clearField(3);

  /// Setup token to correlate with `ConfirmMfaSetup`
  @$pb.TagNumber(4)
  $core.String get setupToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set setupToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSetupToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearSetupToken() => $_clearField(4);

  /// Setup expires at
  @$pb.TagNumber(5)
  $2.Timestamp get expiresAt => $_getN(4);
  @$pb.TagNumber(5)
  set expiresAt($2.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.Timestamp ensureExpiresAt() => $_ensure(4);
}

/// Confirm MFA setup
class ConfirmMfaSetupRequest extends $pb.GeneratedMessage {
  factory ConfirmMfaSetupRequest({
    $core.String? setupToken,
    $core.String? code,
  }) {
    final result = create();
    if (setupToken != null) result.setupToken = setupToken;
    if (code != null) result.code = code;
    return result;
  }

  ConfirmMfaSetupRequest._();

  factory ConfirmMfaSetupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfirmMfaSetupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmMfaSetupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'setupToken')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmMfaSetupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmMfaSetupRequest copyWith(void Function(ConfirmMfaSetupRequest) updates) =>
      super.copyWith((message) => updates(message as ConfirmMfaSetupRequest)) as ConfirmMfaSetupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmMfaSetupRequest create() => ConfirmMfaSetupRequest._();
  @$core.override
  ConfirmMfaSetupRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfirmMfaSetupRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmMfaSetupRequest>(create);
  static ConfirmMfaSetupRequest? _defaultInstance;

  /// Setup token from `SetupMfaReply`
  @$pb.TagNumber(1)
  $core.String get setupToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set setupToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSetupToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearSetupToken() => $_clearField(1);

  /// Verification code
  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);
}

enum ConfirmMfaSetupResponse_Result { success, error, notSet }

/// MFA setup result
class ConfirmMfaSetupResponse extends $pb.GeneratedMessage {
  factory ConfirmMfaSetupResponse({
    MfaSetupSuccess? success,
    MfaSetupError? error,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (error != null) result.error = error;
    return result;
  }

  ConfirmMfaSetupResponse._();

  factory ConfirmMfaSetupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfirmMfaSetupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, ConfirmMfaSetupResponse_Result> _ConfirmMfaSetupResponse_ResultByTag = {
    1: ConfirmMfaSetupResponse_Result.success,
    2: ConfirmMfaSetupResponse_Result.error,
    0: ConfirmMfaSetupResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConfirmMfaSetupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<MfaSetupSuccess>(1, _omitFieldNames ? '' : 'success', subBuilder: MfaSetupSuccess.create)
    ..aOM<MfaSetupError>(2, _omitFieldNames ? '' : 'error', subBuilder: MfaSetupError.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmMfaSetupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmMfaSetupResponse copyWith(void Function(ConfirmMfaSetupResponse) updates) =>
      super.copyWith((message) => updates(message as ConfirmMfaSetupResponse)) as ConfirmMfaSetupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmMfaSetupResponse create() => ConfirmMfaSetupResponse._();
  @$core.override
  ConfirmMfaSetupResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfirmMfaSetupResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConfirmMfaSetupResponse>(create);
  static ConfirmMfaSetupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  ConfirmMfaSetupResponse_Result whichResult() => _ConfirmMfaSetupResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MfaSetupSuccess get success => $_getN(0);
  @$pb.TagNumber(1)
  set success(MfaSetupSuccess value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
  @$pb.TagNumber(1)
  MfaSetupSuccess ensureSuccess() => $_ensure(0);

  @$pb.TagNumber(2)
  MfaSetupError get error => $_getN(1);
  @$pb.TagNumber(2)
  set error(MfaSetupError value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasError() => $_has(1);
  @$pb.TagNumber(2)
  void clearError() => $_clearField(2);
  @$pb.TagNumber(2)
  MfaSetupError ensureError() => $_ensure(1);
}

/// Recovery codes (only returned on first MFA enrollment, display once!)
class MfaSetupSuccess extends $pb.GeneratedMessage {
  factory MfaSetupSuccess({
    $core.Iterable<$core.String>? recoveryCodes,
  }) {
    final result = create();
    if (recoveryCodes != null) result.recoveryCodes.addAll(recoveryCodes);
    return result;
  }

  MfaSetupSuccess._();

  factory MfaSetupSuccess.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaSetupSuccess.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaSetupSuccess',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'recoveryCodes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaSetupSuccess clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaSetupSuccess copyWith(void Function(MfaSetupSuccess) updates) =>
      super.copyWith((message) => updates(message as MfaSetupSuccess)) as MfaSetupSuccess;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaSetupSuccess create() => MfaSetupSuccess._();
  @$core.override
  MfaSetupSuccess createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaSetupSuccess getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaSetupSuccess>(create);
  static MfaSetupSuccess? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get recoveryCodes => $_getList(0);
}

class MfaSetupError extends $pb.GeneratedMessage {
  factory MfaSetupError({
    $core.String? message,
    $core.String? code,
  }) {
    final result = create();
    if (message != null) result.message = message;
    if (code != null) result.code = code;
    return result;
  }

  MfaSetupError._();

  factory MfaSetupError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaSetupError.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaSetupError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'message')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaSetupError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaSetupError copyWith(void Function(MfaSetupError) updates) =>
      super.copyWith((message) => updates(message as MfaSetupError)) as MfaSetupError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaSetupError create() => MfaSetupError._();
  @$core.override
  MfaSetupError createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaSetupError getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaSetupError>(create);
  static MfaSetupError? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get message => $_getSZ(0);
  @$pb.TagNumber(1)
  set message($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMessage() => $_has(0);
  @$pb.TagNumber(1)
  void clearMessage() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);
}

/// Disable MFA request
class DisableMfaRequest extends $pb.GeneratedMessage {
  factory DisableMfaRequest({
    MfaMethod? method,
    $core.String? password,
  }) {
    final result = create();
    if (method != null) result.method = method;
    if (password != null) result.password = password;
    return result;
  }

  DisableMfaRequest._();

  factory DisableMfaRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DisableMfaRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DisableMfaRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<MfaMethod>(1, _omitFieldNames ? '' : 'method', enumValues: MfaMethod.values)
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisableMfaRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DisableMfaRequest copyWith(void Function(DisableMfaRequest) updates) =>
      super.copyWith((message) => updates(message as DisableMfaRequest)) as DisableMfaRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DisableMfaRequest create() => DisableMfaRequest._();
  @$core.override
  DisableMfaRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DisableMfaRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DisableMfaRequest>(create);
  static DisableMfaRequest? _defaultInstance;

  /// Method to disable (or all if not specified)
  @$pb.TagNumber(1)
  MfaMethod get method => $_getN(0);
  @$pb.TagNumber(1)
  set method(MfaMethod value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMethod() => $_has(0);
  @$pb.TagNumber(1)
  void clearMethod() => $_clearField(1);

  /// Current password for verification (OWASP: verify identity for sensitive ops)
  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

/// Request to list sessions
class ListSessionsRequest extends $pb.GeneratedMessage {
  factory ListSessionsRequest({
    $core.String? refreshToken,
  }) {
    final result = create();
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  ListSessionsRequest._();

  factory ListSessionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSessionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSessionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsRequest copyWith(void Function(ListSessionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSessionsRequest)) as ListSessionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest create() => ListSessionsRequest._();
  @$core.override
  ListSessionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSessionsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSessionsRequest>(create);
  static ListSessionsRequest? _defaultInstance;

  /// Current refresh token to identify which session is active
  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);
}

/// Response for listing sessions
class ListSessionsResponse extends $pb.GeneratedMessage {
  factory ListSessionsResponse({
    $core.Iterable<SessionInfo>? sessions,
  }) {
    final result = create();
    if (sessions != null) result.sessions.addAll(sessions);
    return result;
  }

  ListSessionsResponse._();

  factory ListSessionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSessionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSessionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..pPM<SessionInfo>(1, _omitFieldNames ? '' : 'sessions', subBuilder: SessionInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsResponse copyWith(void Function(ListSessionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSessionsResponse)) as ListSessionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse create() => ListSessionsResponse._();
  @$core.override
  ListSessionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSessionsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSessionsResponse>(create);
  static ListSessionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SessionInfo> get sessions => $_getList(0);
}

/// Session information returned to clients
class SessionInfo extends $pb.GeneratedMessage {
  factory SessionInfo({
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? deviceType,
    $core.String? clientVersion,
    $core.String? ipAddress,
    $core.String? ipCountry,
    $2.Timestamp? createdAt,
    $2.Timestamp? lastSeenAt,
    $2.Timestamp? expiresAt,
    $core.bool? isCurrent,
    $core.String? ipCreatedBy,
    $core.int? activityCount,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientVersion != null) result.clientVersion = clientVersion;
    if (ipAddress != null) result.ipAddress = ipAddress;
    if (ipCountry != null) result.ipCountry = ipCountry;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastSeenAt != null) result.lastSeenAt = lastSeenAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (isCurrent != null) result.isCurrent = isCurrent;
    if (ipCreatedBy != null) result.ipCreatedBy = ipCreatedBy;
    if (activityCount != null) result.activityCount = activityCount;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  SessionInfo._();

  factory SessionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SessionInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SessionInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..aOS(2, _omitFieldNames ? '' : 'deviceName')
    ..aOS(3, _omitFieldNames ? '' : 'deviceType')
    ..aOS(4, _omitFieldNames ? '' : 'clientVersion')
    ..aOS(5, _omitFieldNames ? '' : 'ipAddress')
    ..aOS(6, _omitFieldNames ? '' : 'ipCountry')
    ..aOM<$2.Timestamp>(7, _omitFieldNames ? '' : 'createdAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(8, _omitFieldNames ? '' : 'lastSeenAt', subBuilder: $2.Timestamp.create)
    ..aOM<$2.Timestamp>(9, _omitFieldNames ? '' : 'expiresAt', subBuilder: $2.Timestamp.create)
    ..aOB(10, _omitFieldNames ? '' : 'isCurrent')
    ..aOS(11, _omitFieldNames ? '' : 'ipCreatedBy')
    ..aI(12, _omitFieldNames ? '' : 'activityCount')
    ..m<$core.String, $core.String>(13, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'SessionInfo.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('auth'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SessionInfo copyWith(void Function(SessionInfo) updates) =>
      super.copyWith((message) => updates(message as SessionInfo)) as SessionInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SessionInfo create() => SessionInfo._();
  @$core.override
  SessionInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SessionInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SessionInfo>(create);
  static SessionInfo? _defaultInstance;

  /// Unique device identifier
  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);

  /// Human-readable device name
  @$pb.TagNumber(2)
  $core.String get deviceName => $_getSZ(1);
  @$pb.TagNumber(2)
  set deviceName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeviceName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeviceName() => $_clearField(2);

  /// Device type: 'mobile', 'tablet', 'desktop', 'web', 'unknown'
  @$pb.TagNumber(3)
  $core.String get deviceType => $_getSZ(2);
  @$pb.TagNumber(3)
  set deviceType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDeviceType() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeviceType() => $_clearField(3);

  /// App version
  @$pb.TagNumber(4)
  $core.String get clientVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set clientVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasClientVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearClientVersion() => $_clearField(4);

  /// Last seen IP address (may be masked for privacy)
  @$pb.TagNumber(5)
  $core.String get ipAddress => $_getSZ(4);
  @$pb.TagNumber(5)
  set ipAddress($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIpAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearIpAddress() => $_clearField(5);

  /// ISO 3166-1 alpha-2 country code
  @$pb.TagNumber(6)
  $core.String get ipCountry => $_getSZ(5);
  @$pb.TagNumber(6)
  set ipCountry($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIpCountry() => $_has(5);
  @$pb.TagNumber(6)
  void clearIpCountry() => $_clearField(6);

  /// Session creation timestamp
  @$pb.TagNumber(7)
  $2.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($2.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.Timestamp ensureCreatedAt() => $_ensure(6);

  /// Last activity timestamp
  @$pb.TagNumber(8)
  $2.Timestamp get lastSeenAt => $_getN(7);
  @$pb.TagNumber(8)
  set lastSeenAt($2.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastSeenAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastSeenAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $2.Timestamp ensureLastSeenAt() => $_ensure(7);

  /// Session expiration timestamp
  @$pb.TagNumber(9)
  $2.Timestamp get expiresAt => $_getN(8);
  @$pb.TagNumber(9)
  set expiresAt($2.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasExpiresAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearExpiresAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $2.Timestamp ensureExpiresAt() => $_ensure(8);

  /// True if this is the current session
  @$pb.TagNumber(10)
  $core.bool get isCurrent => $_getBF(9);
  @$pb.TagNumber(10)
  set isCurrent($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsCurrent() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsCurrent() => $_clearField(10);

  /// IP address at session creation
  @$pb.TagNumber(11)
  $core.String get ipCreatedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set ipCreatedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIpCreatedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearIpCreatedBy() => $_clearField(11);

  /// Number of token refreshes (activity indicator)
  @$pb.TagNumber(12)
  $core.int get activityCount => $_getIZ(11);
  @$pb.TagNumber(12)
  set activityCount($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasActivityCount() => $_has(11);
  @$pb.TagNumber(12)
  void clearActivityCount() => $_clearField(12);

  /// Session metadata (user agent, fingerprint, etc.)
  @$pb.TagNumber(13)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(12);
}

/// Request to revoke a specific session by `device_id`
class RevokeSessionRequest extends $pb.GeneratedMessage {
  factory RevokeSessionRequest({
    $core.String? deviceId,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    return result;
  }

  RevokeSessionRequest._();

  factory RevokeSessionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeSessionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeSessionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'deviceId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionRequest copyWith(void Function(RevokeSessionRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeSessionRequest)) as RevokeSessionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeSessionRequest create() => RevokeSessionRequest._();
  @$core.override
  RevokeSessionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeSessionRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeSessionRequest>(create);
  static RevokeSessionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get deviceId => $_getSZ(0);
  @$pb.TagNumber(1)
  set deviceId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => $_clearField(1);
}

class RevokeOtherSessionsRequest extends $pb.GeneratedMessage {
  factory RevokeOtherSessionsRequest() => create();

  RevokeOtherSessionsRequest._();

  factory RevokeOtherSessionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeOtherSessionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeOtherSessionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeOtherSessionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeOtherSessionsRequest copyWith(void Function(RevokeOtherSessionsRequest) updates) =>
      super.copyWith((message) => updates(message as RevokeOtherSessionsRequest)) as RevokeOtherSessionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeOtherSessionsRequest create() => RevokeOtherSessionsRequest._();
  @$core.override
  RevokeOtherSessionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeOtherSessionsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeOtherSessionsRequest>(create);
  static RevokeOtherSessionsRequest? _defaultInstance;
}

/// Response for revoking multiple sessions
class RevokeSessionsResponse extends $pb.GeneratedMessage {
  factory RevokeSessionsResponse({
    $core.int? revokedCount,
  }) {
    final result = create();
    if (revokedCount != null) result.revokedCount = revokedCount;
    return result;
  }

  RevokeSessionsResponse._();

  factory RevokeSessionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeSessionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeSessionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'revokedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionsResponse copyWith(void Function(RevokeSessionsResponse) updates) =>
      super.copyWith((message) => updates(message as RevokeSessionsResponse)) as RevokeSessionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeSessionsResponse create() => RevokeSessionsResponse._();
  @$core.override
  RevokeSessionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeSessionsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeSessionsResponse>(create);
  static RevokeSessionsResponse? _defaultInstance;

  /// Number of sessions revoked
  @$pb.TagNumber(1)
  $core.int get revokedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set revokedCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRevokedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearRevokedCount() => $_clearField(1);
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
