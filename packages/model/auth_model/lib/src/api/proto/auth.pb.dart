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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/struct.pb.dart' as $3;

import 'auth.pbenum.dart';
import 'core.pb.dart' as $2;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'auth.pbenum.dart';

/// Unified authentication request supporting multiple identifier types
class AuthenticateRequest extends $pb.GeneratedMessage {
  factory AuthenticateRequest({
    $core.String? identifier,
    IdentifierType? identifierType,
    $core.String? password,
    $2.UUID? installationId,
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
    ..aOM<$2.UUID>(4, _omitFieldNames ? '' : 'installationId', subBuilder: $2.UUID.create)
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

  /// Unique installation/app instance ID
  @$pb.TagNumber(4)
  $2.UUID get installationId => $_getN(3);
  @$pb.TagNumber(4)
  set installationId($2.UUID value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasInstallationId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInstallationId() => $_clearField(4);
  @$pb.TagNumber(4)
  $2.UUID ensureInstallationId() => $_ensure(3);

  /// Client/device information for session (stored in sessions table)
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

/// Register a new user account
class SignUpRequest extends $pb.GeneratedMessage {
  factory SignUpRequest({
    $core.String? identifier,
    IdentifierType? identifierType,
    $core.String? password,
    $core.String? displayName,
    $2.UUID? installationId,
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
    ..aOM<$2.UUID>(5, _omitFieldNames ? '' : 'installationId', subBuilder: $2.UUID.create)
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

  /// Display name
  @$pb.TagNumber(4)
  $core.String get displayName => $_getSZ(3);
  @$pb.TagNumber(4)
  set displayName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDisplayName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDisplayName() => $_clearField(4);

  /// Installation ID for immediate session
  @$pb.TagNumber(5)
  $2.UUID get installationId => $_getN(4);
  @$pb.TagNumber(5)
  set installationId($2.UUID value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasInstallationId() => $_has(4);
  @$pb.TagNumber(5)
  void clearInstallationId() => $_clearField(5);
  @$pb.TagNumber(5)
  $2.UUID ensureInstallationId() => $_ensure(4);

  /// Client info for session
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

  /// Locale (BCP 47, e.g., "en-US")
  @$pb.TagNumber(7)
  $core.String get locale => $_getSZ(6);
  @$pb.TagNumber(7)
  set locale($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLocale() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocale() => $_clearField(7);

  /// Timezone (IANA, e.g., "America/New_York")
  @$pb.TagNumber(8)
  $core.String get timezone => $_getSZ(7);
  @$pb.TagNumber(8)
  set timezone($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTimezone() => $_has(7);
  @$pb.TagNumber(8)
  void clearTimezone() => $_clearField(8);
}

/// Authentication result
/// Returns tokens on success, or MFA challenge if second factor required
class AuthResult extends $pb.GeneratedMessage {
  factory AuthResult({
    AuthStatus? status,
    AuthInfo? authInfo,
    MfaChallenge? mfaChallenge,
    $core.String? message,
    LockoutInfo? lockoutInfo,
  }) {
    final result = create();
    if (status != null) result.status = status;
    if (authInfo != null) result.authInfo = authInfo;
    if (mfaChallenge != null) result.mfaChallenge = mfaChallenge;
    if (message != null) result.message = message;
    if (lockoutInfo != null) result.lockoutInfo = lockoutInfo;
    return result;
  }

  AuthResult._();

  factory AuthResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthResult.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aE<AuthStatus>(1, _omitFieldNames ? '' : 'status', enumValues: AuthStatus.values)
    ..aOM<AuthInfo>(2, _omitFieldNames ? '' : 'authInfo', subBuilder: AuthInfo.create)
    ..aOM<MfaChallenge>(3, _omitFieldNames ? '' : 'mfaChallenge', subBuilder: MfaChallenge.create)
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..aOM<LockoutInfo>(5, _omitFieldNames ? '' : 'lockoutInfo', subBuilder: LockoutInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthResult copyWith(void Function(AuthResult) updates) =>
      super.copyWith((message) => updates(message as AuthResult)) as AuthResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthResult create() => AuthResult._();
  @$core.override
  AuthResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthResult>(create);
  static AuthResult? _defaultInstance;

  /// Status of authentication attempt
  @$pb.TagNumber(1)
  AuthStatus get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(AuthStatus value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  /// Populated on AUTH_STATUS_SUCCESS
  @$pb.TagNumber(2)
  AuthInfo get authInfo => $_getN(1);
  @$pb.TagNumber(2)
  set authInfo(AuthInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAuthInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearAuthInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  AuthInfo ensureAuthInfo() => $_ensure(1);

  /// Populated on AUTH_STATUS_MFA_REQUIRED
  @$pb.TagNumber(3)
  MfaChallenge get mfaChallenge => $_getN(2);
  @$pb.TagNumber(3)
  set mfaChallenge(MfaChallenge value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMfaChallenge() => $_has(2);
  @$pb.TagNumber(3)
  void clearMfaChallenge() => $_clearField(3);
  @$pb.TagNumber(3)
  MfaChallenge ensureMfaChallenge() => $_ensure(2);

  /// Message for user (generic per OWASP - prevent enumeration)
  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

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
}

/// Account lockout information
class LockoutInfo extends $pb.GeneratedMessage {
  factory LockoutInfo({
    $core.int? retryAfterSeconds,
    $core.int? failedAttempts,
    $core.int? maxAttempts,
    $fixnum.Int64? lockedUntil,
  }) {
    final result = create();
    if (retryAfterSeconds != null) result.retryAfterSeconds = retryAfterSeconds;
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
    ..aI(1, _omitFieldNames ? '' : 'retryAfterSeconds')
    ..aI(2, _omitFieldNames ? '' : 'failedAttempts')
    ..aI(3, _omitFieldNames ? '' : 'maxAttempts')
    ..aInt64(4, _omitFieldNames ? '' : 'lockedUntil')
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

  /// Seconds until account is unlocked
  @$pb.TagNumber(1)
  $core.int get retryAfterSeconds => $_getIZ(0);
  @$pb.TagNumber(1)
  set retryAfterSeconds($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRetryAfterSeconds() => $_has(0);
  @$pb.TagNumber(1)
  void clearRetryAfterSeconds() => $_clearField(1);

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

  /// Lockout timestamp (Unix millis), 0 if not locked
  @$pb.TagNumber(4)
  $fixnum.Int64 get lockedUntil => $_getI64(3);
  @$pb.TagNumber(4)
  set lockedUntil($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLockedUntil() => $_has(3);
  @$pb.TagNumber(4)
  void clearLockedUntil() => $_clearField(4);
}

/// MFA challenge - returned when second factor is required
class MfaChallenge extends $pb.GeneratedMessage {
  factory MfaChallenge({
    $core.String? challengeToken,
    $core.Iterable<MfaMethodInfo>? availableMethods,
    $fixnum.Int64? expiresAt,
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
    ..aInt64(3, _omitFieldNames ? '' : 'expiresAt')
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

  /// Challenge expiration (Unix millis) - typically 5 minutes
  @$pb.TagNumber(3)
  $fixnum.Int64 get expiresAt => $_getI64(2);
  @$pb.TagNumber(3)
  set expiresAt($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExpiresAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearExpiresAt() => $_clearField(3);
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

/// Full authentication info returned on successful auth
class AuthInfo extends $pb.GeneratedMessage {
  factory AuthInfo({
    $2.UUID? userId,
    $core.String? displayName,
    UserRole? userRole,
    $core.String? refreshToken,
    $core.String? accessToken,
    $core.String? email,
    $core.String? phone,
    $core.bool? emailVerified,
    $core.bool? phoneVerified,
    $core.bool? mfaEnabled,
    $core.Iterable<OAuthProvider>? linkedProviders,
    UserStatus? status,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (displayName != null) result.displayName = displayName;
    if (userRole != null) result.userRole = userRole;
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (accessToken != null) result.accessToken = accessToken;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (emailVerified != null) result.emailVerified = emailVerified;
    if (phoneVerified != null) result.phoneVerified = phoneVerified;
    if (mfaEnabled != null) result.mfaEnabled = mfaEnabled;
    if (linkedProviders != null) result.linkedProviders.addAll(linkedProviders);
    if (status != null) result.status = status;
    return result;
  }

  AuthInfo._();

  factory AuthInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AuthInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuthInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aE<UserRole>(3, _omitFieldNames ? '' : 'userRole', enumValues: UserRole.values)
    ..aOS(4, _omitFieldNames ? '' : 'refreshToken')
    ..aOS(5, _omitFieldNames ? '' : 'accessToken')
    ..aOS(6, _omitFieldNames ? '' : 'email')
    ..aOS(7, _omitFieldNames ? '' : 'phone')
    ..aOB(8, _omitFieldNames ? '' : 'emailVerified')
    ..aOB(9, _omitFieldNames ? '' : 'phoneVerified')
    ..aOB(10, _omitFieldNames ? '' : 'mfaEnabled')
    ..pc<OAuthProvider>(11, _omitFieldNames ? '' : 'linkedProviders', $pb.PbFieldType.KE,
        valueOf: OAuthProvider.valueOf,
        enumValues: OAuthProvider.values,
        defaultEnumValue: OAuthProvider.OAUTH_PROVIDER_UNSPECIFIED)
    ..aE<UserStatus>(12, _omitFieldNames ? '' : 'status', enumValues: UserStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AuthInfo copyWith(void Function(AuthInfo) updates) =>
      super.copyWith((message) => updates(message as AuthInfo)) as AuthInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuthInfo create() => AuthInfo._();
  @$core.override
  AuthInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AuthInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuthInfo>(create);
  static AuthInfo? _defaultInstance;

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
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  UserRole get userRole => $_getN(2);
  @$pb.TagNumber(3)
  set userRole(UserRole value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUserRole() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserRole() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get refreshToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set refreshToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRefreshToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearRefreshToken() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get accessToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set accessToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAccessToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearAccessToken() => $_clearField(5);

  /// User's email
  @$pb.TagNumber(6)
  $core.String get email => $_getSZ(5);
  @$pb.TagNumber(6)
  set email($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEmail() => $_has(5);
  @$pb.TagNumber(6)
  void clearEmail() => $_clearField(6);

  /// User's phone (E.164 format)
  @$pb.TagNumber(7)
  $core.String get phone => $_getSZ(6);
  @$pb.TagNumber(7)
  set phone($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPhone() => $_has(6);
  @$pb.TagNumber(7)
  void clearPhone() => $_clearField(7);

  /// Email verification status
  @$pb.TagNumber(8)
  $core.bool get emailVerified => $_getBF(7);
  @$pb.TagNumber(8)
  set emailVerified($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEmailVerified() => $_has(7);
  @$pb.TagNumber(8)
  void clearEmailVerified() => $_clearField(8);

  /// Phone verification status
  @$pb.TagNumber(9)
  $core.bool get phoneVerified => $_getBF(8);
  @$pb.TagNumber(9)
  set phoneVerified($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPhoneVerified() => $_has(8);
  @$pb.TagNumber(9)
  void clearPhoneVerified() => $_clearField(9);

  /// Whether MFA is enabled for this account
  @$pb.TagNumber(10)
  $core.bool get mfaEnabled => $_getBF(9);
  @$pb.TagNumber(10)
  set mfaEnabled($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMfaEnabled() => $_has(9);
  @$pb.TagNumber(10)
  void clearMfaEnabled() => $_clearField(10);

  /// Linked OAuth providers
  @$pb.TagNumber(11)
  $pb.PbList<OAuthProvider> get linkedProviders => $_getList(10);

  /// Account status
  @$pb.TagNumber(12)
  UserStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(UserStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);
}

/// Client information sent with authentication requests
class ClientInfo extends $pb.GeneratedMessage {
  factory ClientInfo({
    $core.String? deviceId,
    $core.String? deviceName,
    $core.String? deviceType,
    $core.String? clientVersion,
    $3.Struct? metadata,
  }) {
    final result = create();
    if (deviceId != null) result.deviceId = deviceId;
    if (deviceName != null) result.deviceName = deviceName;
    if (deviceType != null) result.deviceType = deviceType;
    if (clientVersion != null) result.clientVersion = clientVersion;
    if (metadata != null) result.metadata = metadata;
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
    ..aOM<$3.Struct>(5, _omitFieldNames ? '' : 'metadata', subBuilder: $3.Struct.create)
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

  /// Additional metadata (device_model, os_info, fingerprint, etc.)
  @$pb.TagNumber(5)
  $3.Struct get metadata => $_getN(4);
  @$pb.TagNumber(5)
  set metadata($3.Struct value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasMetadata() => $_has(4);
  @$pb.TagNumber(5)
  void clearMetadata() => $_clearField(5);
  @$pb.TagNumber(5)
  $3.Struct ensureMetadata() => $_ensure(4);
}

class RequestVerificationRequest extends $pb.GeneratedMessage {
  factory RequestVerificationRequest({
    VerificationType? verificationType,
  }) {
    final result = create();
    if (verificationType != null) result.verificationType = verificationType;
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
    ..aE<VerificationType>(1, _omitFieldNames ? '' : 'verificationType', enumValues: VerificationType.values)
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
  VerificationType get verificationType => $_getN(0);
  @$pb.TagNumber(1)
  set verificationType(VerificationType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVerificationType() => $_has(0);
  @$pb.TagNumber(1)
  void clearVerificationType() => $_clearField(1);
}

class ConfirmVerificationRequest extends $pb.GeneratedMessage {
  factory ConfirmVerificationRequest({
    $core.String? token,
    VerificationType? verificationType,
  }) {
    final result = create();
    if (token != null) result.token = token;
    if (verificationType != null) result.verificationType = verificationType;
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
    ..aE<VerificationType>(2, _omitFieldNames ? '' : 'verificationType', enumValues: VerificationType.values)
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
  VerificationType get verificationType => $_getN(1);
  @$pb.TagNumber(2)
  set verificationType(VerificationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasVerificationType() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerificationType() => $_clearField(2);
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
class OAuthUrlReply extends $pb.GeneratedMessage {
  factory OAuthUrlReply({
    $core.String? authorizationUrl,
    $core.String? state,
  }) {
    final result = create();
    if (authorizationUrl != null) result.authorizationUrl = authorizationUrl;
    if (state != null) result.state = state;
    return result;
  }

  OAuthUrlReply._();

  factory OAuthUrlReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OAuthUrlReply.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OAuthUrlReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'authorizationUrl')
    ..aOS(2, _omitFieldNames ? '' : 'state')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OAuthUrlReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OAuthUrlReply copyWith(void Function(OAuthUrlReply) updates) =>
      super.copyWith((message) => updates(message as OAuthUrlReply)) as OAuthUrlReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OAuthUrlReply create() => OAuthUrlReply._();
  @$core.override
  OAuthUrlReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static OAuthUrlReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OAuthUrlReply>(create);
  static OAuthUrlReply? _defaultInstance;

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
    $2.UUID? installationId,
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
    ..aOM<$2.UUID>(3, _omitFieldNames ? '' : 'installationId', subBuilder: $2.UUID.create)
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
  $2.UUID get installationId => $_getN(2);
  @$pb.TagNumber(3)
  set installationId($2.UUID value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInstallationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstallationId() => $_clearField(3);
  @$pb.TagNumber(3)
  $2.UUID ensureInstallationId() => $_ensure(2);

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

/// Linked OAuth providers response
class LinkedProvidersReply extends $pb.GeneratedMessage {
  factory LinkedProvidersReply({
    $core.Iterable<LinkedProvider>? providers,
  }) {
    final result = create();
    if (providers != null) result.providers.addAll(providers);
    return result;
  }

  LinkedProvidersReply._();

  factory LinkedProvidersReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LinkedProvidersReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LinkedProvidersReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..pPM<LinkedProvider>(1, _omitFieldNames ? '' : 'providers', subBuilder: LinkedProvider.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkedProvidersReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LinkedProvidersReply copyWith(void Function(LinkedProvidersReply) updates) =>
      super.copyWith((message) => updates(message as LinkedProvidersReply)) as LinkedProvidersReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LinkedProvidersReply create() => LinkedProvidersReply._();
  @$core.override
  LinkedProvidersReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LinkedProvidersReply getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LinkedProvidersReply>(create);
  static LinkedProvidersReply? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LinkedProvider> get providers => $_getList(0);
}

class LinkedProvider extends $pb.GeneratedMessage {
  factory LinkedProvider({
    OAuthProvider? provider,
    $core.String? providerUserId,
    $core.String? email,
    $fixnum.Int64? linkedAt,
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
    ..aInt64(4, _omitFieldNames ? '' : 'linkedAt')
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
  $fixnum.Int64 get linkedAt => $_getI64(3);
  @$pb.TagNumber(4)
  set linkedAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLinkedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearLinkedAt() => $_clearField(4);
}

/// MFA status for current user
class MfaStatusReply extends $pb.GeneratedMessage {
  factory MfaStatusReply({
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

  MfaStatusReply._();

  factory MfaStatusReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaStatusReply.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaStatusReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..pPM<MfaMethodStatus>(2, _omitFieldNames ? '' : 'methods', subBuilder: MfaMethodStatus.create)
    ..aI(3, _omitFieldNames ? '' : 'recoveryCodesRemaining')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaStatusReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaStatusReply copyWith(void Function(MfaStatusReply) updates) =>
      super.copyWith((message) => updates(message as MfaStatusReply)) as MfaStatusReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaStatusReply create() => MfaStatusReply._();
  @$core.override
  MfaStatusReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaStatusReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaStatusReply>(create);
  static MfaStatusReply? _defaultInstance;

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
    $fixnum.Int64? configuredAt,
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
    ..aInt64(4, _omitFieldNames ? '' : 'configuredAt')
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

  /// When this method was configured (Unix millis)
  @$pb.TagNumber(4)
  $fixnum.Int64 get configuredAt => $_getI64(3);
  @$pb.TagNumber(4)
  set configuredAt($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfiguredAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfiguredAt() => $_clearField(4);
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
class SetupMfaReply extends $pb.GeneratedMessage {
  factory SetupMfaReply({
    $core.String? secret,
    $core.String? provisioningUri,
    $core.String? maskedDestination,
    $core.String? setupToken,
    $fixnum.Int64? expiresAt,
  }) {
    final result = create();
    if (secret != null) result.secret = secret;
    if (provisioningUri != null) result.provisioningUri = provisioningUri;
    if (maskedDestination != null) result.maskedDestination = maskedDestination;
    if (setupToken != null) result.setupToken = setupToken;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  SetupMfaReply._();

  factory SetupMfaReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetupMfaReply.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetupMfaReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'secret')
    ..aOS(2, _omitFieldNames ? '' : 'provisioningUri')
    ..aOS(3, _omitFieldNames ? '' : 'maskedDestination')
    ..aOS(4, _omitFieldNames ? '' : 'setupToken')
    ..aInt64(5, _omitFieldNames ? '' : 'expiresAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetupMfaReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetupMfaReply copyWith(void Function(SetupMfaReply) updates) =>
      super.copyWith((message) => updates(message as SetupMfaReply)) as SetupMfaReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetupMfaReply create() => SetupMfaReply._();
  @$core.override
  SetupMfaReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetupMfaReply getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetupMfaReply>(create);
  static SetupMfaReply? _defaultInstance;

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

  /// Setup token to correlate with ConfirmMfaSetup
  @$pb.TagNumber(4)
  $core.String get setupToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set setupToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSetupToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearSetupToken() => $_clearField(4);

  /// Setup expires at (Unix millis)
  @$pb.TagNumber(5)
  $fixnum.Int64 get expiresAt => $_getI64(4);
  @$pb.TagNumber(5)
  set expiresAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpiresAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiresAt() => $_clearField(5);
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

  /// Setup token from SetupMfaReply
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

/// MFA setup result
class MfaSetupResult extends $pb.GeneratedMessage {
  factory MfaSetupResult({
    $core.bool? success,
    $core.Iterable<$core.String>? recoveryCodes,
    $core.String? errorMessage,
  }) {
    final result = create();
    if (success != null) result.success = success;
    if (recoveryCodes != null) result.recoveryCodes.addAll(recoveryCodes);
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  MfaSetupResult._();

  factory MfaSetupResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MfaSetupResult.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MfaSetupResult',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..pPS(2, _omitFieldNames ? '' : 'recoveryCodes')
    ..aOS(3, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaSetupResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MfaSetupResult copyWith(void Function(MfaSetupResult) updates) =>
      super.copyWith((message) => updates(message as MfaSetupResult)) as MfaSetupResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MfaSetupResult create() => MfaSetupResult._();
  @$core.override
  MfaSetupResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MfaSetupResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MfaSetupResult>(create);
  static MfaSetupResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  /// Recovery codes (only returned on first MFA enrollment, display once!)
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get recoveryCodes => $_getList(1);

  /// Error message if failed
  @$pb.TagNumber(3)
  $core.String get errorMessage => $_getSZ(2);
  @$pb.TagNumber(3)
  set errorMessage($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasErrorMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearErrorMessage() => $_clearField(3);
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

/// Set password (admin only - bypasses verification)
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
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

  /// Target user ID (required)
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

  /// New password
  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

class RefreshTokenRequest extends $pb.GeneratedMessage {
  factory RefreshTokenRequest({
    $core.String? refreshToken,
  }) {
    final result = create();
    if (refreshToken != null) result.refreshToken = refreshToken;
    return result;
  }

  RefreshTokenRequest._();

  factory RefreshTokenRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokenRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshTokenRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenRequest copyWith(void Function(RefreshTokenRequest) updates) =>
      super.copyWith((message) => updates(message as RefreshTokenRequest)) as RefreshTokenRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest create() => RefreshTokenRequest._();
  @$core.override
  RefreshTokenRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshTokenRequest>(create);
  static RefreshTokenRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);
}

class RefreshTokenReply extends $pb.GeneratedMessage {
  factory RefreshTokenReply({
    $core.String? refreshToken,
    $core.String? accessToken,
  }) {
    final result = create();
    if (refreshToken != null) result.refreshToken = refreshToken;
    if (accessToken != null) result.accessToken = accessToken;
    return result;
  }

  RefreshTokenReply._();

  factory RefreshTokenReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RefreshTokenReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RefreshTokenReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'refreshToken')
    ..aOS(2, _omitFieldNames ? '' : 'accessToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RefreshTokenReply copyWith(void Function(RefreshTokenReply) updates) =>
      super.copyWith((message) => updates(message as RefreshTokenReply)) as RefreshTokenReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RefreshTokenReply create() => RefreshTokenReply._();
  @$core.override
  RefreshTokenReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RefreshTokenReply getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RefreshTokenReply>(create);
  static RefreshTokenReply? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get refreshToken => $_getSZ(0);
  @$pb.TagNumber(1)
  set refreshToken($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRefreshToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearRefreshToken() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get accessToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set accessToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccessToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccessToken() => $_clearField(2);
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
    $fixnum.Int64? createdAt,
    $fixnum.Int64? lastSeenAt,
    $fixnum.Int64? expiresAt,
    $core.bool? isCurrent,
    $core.String? ipCreatedBy,
    $core.int? activityCount,
    $3.Struct? metadata,
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
    if (metadata != null) result.metadata = metadata;
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
    ..aInt64(7, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(8, _omitFieldNames ? '' : 'lastSeenAt')
    ..aInt64(9, _omitFieldNames ? '' : 'expiresAt')
    ..aOB(10, _omitFieldNames ? '' : 'isCurrent')
    ..aOS(11, _omitFieldNames ? '' : 'ipCreatedBy')
    ..aI(12, _omitFieldNames ? '' : 'activityCount')
    ..aOM<$3.Struct>(13, _omitFieldNames ? '' : 'metadata', subBuilder: $3.Struct.create)
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

  /// Session creation timestamp (Unix millis)
  @$pb.TagNumber(7)
  $fixnum.Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAt($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);

  /// Last activity timestamp (Unix millis)
  @$pb.TagNumber(8)
  $fixnum.Int64 get lastSeenAt => $_getI64(7);
  @$pb.TagNumber(8)
  set lastSeenAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLastSeenAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastSeenAt() => $_clearField(8);

  /// Session expiration timestamp (Unix millis)
  @$pb.TagNumber(9)
  $fixnum.Int64 get expiresAt => $_getI64(8);
  @$pb.TagNumber(9)
  set expiresAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasExpiresAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearExpiresAt() => $_clearField(9);

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
  $3.Struct get metadata => $_getN(12);
  @$pb.TagNumber(13)
  set metadata($3.Struct value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasMetadata() => $_has(12);
  @$pb.TagNumber(13)
  void clearMetadata() => $_clearField(13);
  @$pb.TagNumber(13)
  $3.Struct ensureMetadata() => $_ensure(12);
}

/// Response for listing sessions
class ListSessionsReply extends $pb.GeneratedMessage {
  factory ListSessionsReply({
    $core.Iterable<SessionInfo>? sessions,
  }) {
    final result = create();
    if (sessions != null) result.sessions.addAll(sessions);
    return result;
  }

  ListSessionsReply._();

  factory ListSessionsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSessionsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSessionsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..pPM<SessionInfo>(1, _omitFieldNames ? '' : 'sessions', subBuilder: SessionInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSessionsReply copyWith(void Function(ListSessionsReply) updates) =>
      super.copyWith((message) => updates(message as ListSessionsReply)) as ListSessionsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSessionsReply create() => ListSessionsReply._();
  @$core.override
  ListSessionsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSessionsReply getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSessionsReply>(create);
  static ListSessionsReply? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SessionInfo> get sessions => $_getList(0);
}

/// Request to revoke a specific session by device_id
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

/// Response for revoking multiple sessions
class RevokeSessionsReply extends $pb.GeneratedMessage {
  factory RevokeSessionsReply({
    $core.int? revokedCount,
  }) {
    final result = create();
    if (revokedCount != null) result.revokedCount = revokedCount;
    return result;
  }

  RevokeSessionsReply._();

  factory RevokeSessionsReply.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RevokeSessionsReply.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RevokeSessionsReply',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'revokedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionsReply clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RevokeSessionsReply copyWith(void Function(RevokeSessionsReply) updates) =>
      super.copyWith((message) => updates(message as RevokeSessionsReply)) as RevokeSessionsReply;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RevokeSessionsReply create() => RevokeSessionsReply._();
  @$core.override
  RevokeSessionsReply createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RevokeSessionsReply getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RevokeSessionsReply>(create);
  static RevokeSessionsReply? _defaultInstance;

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

class LoadUsersInfoRequest extends $pb.GeneratedMessage {
  factory LoadUsersInfoRequest({
    $2.UUID? userId,
    $core.Iterable<$2.UUID>? userIds,
    $core.Iterable<$core.String>? statuses,
  }) {
    final result = create();
    if (userId != null) result.userId = userId;
    if (userIds != null) result.userIds.addAll(userIds);
    if (statuses != null) result.statuses.addAll(statuses);
    return result;
  }

  LoadUsersInfoRequest._();

  factory LoadUsersInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LoadUsersInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LoadUsersInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'userId', subBuilder: $2.UUID.create)
    ..pPM<$2.UUID>(2, _omitFieldNames ? '' : 'userIds', subBuilder: $2.UUID.create)
    ..pPS(3, _omitFieldNames ? '' : 'statuses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadUsersInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LoadUsersInfoRequest copyWith(void Function(LoadUsersInfoRequest) updates) =>
      super.copyWith((message) => updates(message as LoadUsersInfoRequest)) as LoadUsersInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LoadUsersInfoRequest create() => LoadUsersInfoRequest._();
  @$core.override
  LoadUsersInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LoadUsersInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LoadUsersInfoRequest>(create);
  static LoadUsersInfoRequest? _defaultInstance;

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

  /// Optional: filter by status
  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get statuses => $_getList(2);
}

/// User info for listings
class UserInfo extends $pb.GeneratedMessage {
  factory UserInfo({
    $2.UUID? id,
    $core.String? name,
    $core.String? email,
    UserRole? role,
    $core.bool? deleted,
    $core.String? phone,
    $core.bool? emailVerified,
    $core.bool? phoneVerified,
    $core.bool? mfaEnabled,
    UserStatus? status,
    $core.Iterable<OAuthProvider>? linkedProviders,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (role != null) result.role = role;
    if (deleted != null) result.deleted = deleted;
    if (phone != null) result.phone = phone;
    if (emailVerified != null) result.emailVerified = emailVerified;
    if (phoneVerified != null) result.phoneVerified = phoneVerified;
    if (mfaEnabled != null) result.mfaEnabled = mfaEnabled;
    if (status != null) result.status = status;
    if (linkedProviders != null) result.linkedProviders.addAll(linkedProviders);
    return result;
  }

  UserInfo._();

  factory UserInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aE<UserRole>(4, _omitFieldNames ? '' : 'role', enumValues: UserRole.values)
    ..aOB(5, _omitFieldNames ? '' : 'deleted')
    ..aOS(6, _omitFieldNames ? '' : 'phone')
    ..aOB(7, _omitFieldNames ? '' : 'emailVerified')
    ..aOB(8, _omitFieldNames ? '' : 'phoneVerified')
    ..aOB(9, _omitFieldNames ? '' : 'mfaEnabled')
    ..aE<UserStatus>(10, _omitFieldNames ? '' : 'status', enumValues: UserStatus.values)
    ..pc<OAuthProvider>(11, _omitFieldNames ? '' : 'linkedProviders', $pb.PbFieldType.KE,
        valueOf: OAuthProvider.valueOf,
        enumValues: OAuthProvider.values,
        defaultEnumValue: OAuthProvider.OAUTH_PROVIDER_UNSPECIFIED)
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
  UserRole get role => $_getN(3);
  @$pb.TagNumber(4)
  set role(UserRole value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get deleted => $_getBF(4);
  @$pb.TagNumber(5)
  set deleted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeleted() => $_clearField(5);

  /// Phone number (if set)
  @$pb.TagNumber(6)
  $core.String get phone => $_getSZ(5);
  @$pb.TagNumber(6)
  set phone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPhone() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhone() => $_clearField(6);

  /// Email verified status
  @$pb.TagNumber(7)
  $core.bool get emailVerified => $_getBF(6);
  @$pb.TagNumber(7)
  set emailVerified($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEmailVerified() => $_has(6);
  @$pb.TagNumber(7)
  void clearEmailVerified() => $_clearField(7);

  /// Phone verified status
  @$pb.TagNumber(8)
  $core.bool get phoneVerified => $_getBF(7);
  @$pb.TagNumber(8)
  set phoneVerified($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPhoneVerified() => $_has(7);
  @$pb.TagNumber(8)
  void clearPhoneVerified() => $_clearField(8);

  /// MFA enabled
  @$pb.TagNumber(9)
  $core.bool get mfaEnabled => $_getBF(8);
  @$pb.TagNumber(9)
  set mfaEnabled($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMfaEnabled() => $_has(8);
  @$pb.TagNumber(9)
  void clearMfaEnabled() => $_clearField(9);

  /// Account status
  @$pb.TagNumber(10)
  UserStatus get status => $_getN(9);
  @$pb.TagNumber(10)
  set status(UserStatus value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasStatus() => $_has(9);
  @$pb.TagNumber(10)
  void clearStatus() => $_clearField(10);

  /// Linked OAuth providers
  @$pb.TagNumber(11)
  $pb.PbList<OAuthProvider> get linkedProviders => $_getList(10);
}

/// User details
class User extends $pb.GeneratedMessage {
  factory User({
    $2.UUID? id,
    $core.String? name,
    $core.String? email,
    UserRole? role,
    $core.bool? deleted,
    $core.String? phone,
    $core.String? status,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (role != null) result.role = role;
    if (deleted != null) result.deleted = deleted;
    if (phone != null) result.phone = phone;
    if (status != null) result.status = status;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aE<UserRole>(4, _omitFieldNames ? '' : 'role', enumValues: UserRole.values)
    ..aOB(5, _omitFieldNames ? '' : 'deleted')
    ..aOS(6, _omitFieldNames ? '' : 'phone')
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(9, _omitFieldNames ? '' : 'updatedAt')
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
  UserRole get role => $_getN(3);
  @$pb.TagNumber(4)
  set role(UserRole value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get deleted => $_getBF(4);
  @$pb.TagNumber(5)
  set deleted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDeleted() => $_has(4);
  @$pb.TagNumber(5)
  void clearDeleted() => $_clearField(5);

  /// Phone number
  @$pb.TagNumber(6)
  $core.String get phone => $_getSZ(5);
  @$pb.TagNumber(6)
  set phone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPhone() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhone() => $_clearField(6);

  /// Account status
  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  /// Created timestamp
  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);

  /// Updated timestamp
  @$pb.TagNumber(9)
  $fixnum.Int64 get updatedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set updatedAt($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdatedAt() => $_clearField(9);
}

class UserId extends $pb.GeneratedMessage {
  factory UserId({
    $2.UUID? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  UserId._();

  factory UserId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UserId.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UserId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UserId copyWith(void Function(UserId) updates) => super.copyWith((message) => updates(message as UserId)) as UserId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UserId create() => UserId._();
  @$core.override
  UserId createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UserId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UserId>(create);
  static UserId? _defaultInstance;

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
}

/// Create user request
class CreateUserRequest extends $pb.GeneratedMessage {
  factory CreateUserRequest({
    $2.UUID? id,
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    $core.String? password,
    UserRole? role,
    $core.bool? deleted,
    $core.String? locale,
    $core.String? timezone,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (password != null) result.password = password;
    if (role != null) result.role = role;
    if (deleted != null) result.deleted = deleted;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aOS(5, _omitFieldNames ? '' : 'password')
    ..aE<UserRole>(6, _omitFieldNames ? '' : 'role', enumValues: UserRole.values)
    ..aOB(7, _omitFieldNames ? '' : 'deleted')
    ..aOS(8, _omitFieldNames ? '' : 'locale')
    ..aOS(9, _omitFieldNames ? '' : 'timezone')
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

  /// Display name
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// Email (optional if phone is provided)
  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  /// Phone in E.164 format (optional if email is provided)
  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  /// Password (optional for OAuth-only accounts)
  @$pb.TagNumber(5)
  $core.String get password => $_getSZ(4);
  @$pb.TagNumber(5)
  set password($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPassword() => $_has(4);
  @$pb.TagNumber(5)
  void clearPassword() => $_clearField(5);

  /// User role
  @$pb.TagNumber(6)
  UserRole get role => $_getN(5);
  @$pb.TagNumber(6)
  set role(UserRole value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRole() => $_has(5);
  @$pb.TagNumber(6)
  void clearRole() => $_clearField(6);

  /// Soft-deleted flag
  @$pb.TagNumber(7)
  $core.bool get deleted => $_getBF(6);
  @$pb.TagNumber(7)
  set deleted($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDeleted() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeleted() => $_clearField(7);

  /// Locale (BCP 47)
  @$pb.TagNumber(8)
  $core.String get locale => $_getSZ(7);
  @$pb.TagNumber(8)
  set locale($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLocale() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocale() => $_clearField(8);

  /// Timezone (IANA)
  @$pb.TagNumber(9)
  $core.String get timezone => $_getSZ(8);
  @$pb.TagNumber(9)
  set timezone($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTimezone() => $_has(8);
  @$pb.TagNumber(9)
  void clearTimezone() => $_clearField(9);
}

/// Update user request
class UpdateUserRequest extends $pb.GeneratedMessage {
  factory UpdateUserRequest({
    $2.UUID? id,
    $core.String? name,
    $core.String? email,
    $core.String? phone,
    UserRole? role,
    $core.bool? deleted,
    $core.String? status,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (role != null) result.role = role;
    if (deleted != null) result.deleted = deleted;
    if (status != null) result.status = status;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOM<$2.UUID>(1, _omitFieldNames ? '' : 'id', subBuilder: $2.UUID.create)
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'email')
    ..aOS(4, _omitFieldNames ? '' : 'phone')
    ..aE<UserRole>(5, _omitFieldNames ? '' : 'role', enumValues: UserRole.values)
    ..aOB(6, _omitFieldNames ? '' : 'deleted')
    ..aOS(7, _omitFieldNames ? '' : 'status')
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
  $2.UUID get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($2.UUID value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
  @$pb.TagNumber(1)
  $2.UUID ensureId() => $_ensure(0);

  /// Display name
  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  /// Email
  @$pb.TagNumber(3)
  $core.String get email => $_getSZ(2);
  @$pb.TagNumber(3)
  set email($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmail() => $_clearField(3);

  /// Phone
  @$pb.TagNumber(4)
  $core.String get phone => $_getSZ(3);
  @$pb.TagNumber(4)
  set phone($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhone() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhone() => $_clearField(4);

  /// User role
  @$pb.TagNumber(5)
  UserRole get role => $_getN(4);
  @$pb.TagNumber(5)
  set role(UserRole value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasRole() => $_has(4);
  @$pb.TagNumber(5)
  void clearRole() => $_clearField(5);

  /// Soft-deleted flag
  @$pb.TagNumber(6)
  $core.bool get deleted => $_getBF(5);
  @$pb.TagNumber(6)
  set deleted($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeleted() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeleted() => $_clearField(6);

  /// Account status (admin only)
  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
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
class AvatarUploadUrl extends $pb.GeneratedMessage {
  factory AvatarUploadUrl({
    $core.String? uploadUrl,
    $fixnum.Int64? expiresIn,
  }) {
    final result = create();
    if (uploadUrl != null) result.uploadUrl = uploadUrl;
    if (expiresIn != null) result.expiresIn = expiresIn;
    return result;
  }

  AvatarUploadUrl._();

  factory AvatarUploadUrl.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AvatarUploadUrl.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AvatarUploadUrl',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uploadUrl')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'expiresIn', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AvatarUploadUrl clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AvatarUploadUrl copyWith(void Function(AvatarUploadUrl) updates) =>
      super.copyWith((message) => updates(message as AvatarUploadUrl)) as AvatarUploadUrl;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AvatarUploadUrl create() => AvatarUploadUrl._();
  @$core.override
  AvatarUploadUrl createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AvatarUploadUrl getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AvatarUploadUrl>(create);
  static AvatarUploadUrl? _defaultInstance;

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
  $fixnum.Int64 get expiresIn => $_getI64(1);
  @$pb.TagNumber(2)
  set expiresIn($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasExpiresIn() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiresIn() => $_clearField(2);
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'auth'), createEmptyInstance: create)
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

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
