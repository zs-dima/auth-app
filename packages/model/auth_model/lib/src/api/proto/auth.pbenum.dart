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

/// Type of identifier for authentication
/// Maps to DB: `users.email` (email domain), `users.phone` (`phone_e164` domain)
class IdentifierType extends $pb.ProtobufEnum {
  static const IdentifierType IDENTIFIER_TYPE_UNSPECIFIED =
      IdentifierType._(0, _omitEnumNames ? '' : 'IDENTIFIER_TYPE_UNSPECIFIED');
  static const IdentifierType IDENTIFIER_TYPE_EMAIL =
      IdentifierType._(1, _omitEnumNames ? '' : 'IDENTIFIER_TYPE_EMAIL');
  static const IdentifierType IDENTIFIER_TYPE_PHONE =
      IdentifierType._(2, _omitEnumNames ? '' : 'IDENTIFIER_TYPE_PHONE');

  static const $core.List<IdentifierType> values = <IdentifierType>[
    IDENTIFIER_TYPE_UNSPECIFIED,
    IDENTIFIER_TYPE_EMAIL,
    IDENTIFIER_TYPE_PHONE,
  ];

  static final $core.List<IdentifierType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static IdentifierType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IdentifierType._(super.value, super.name);
}

/// OAuth providers - matches DB enum: oauth_provider
class OAuthProvider extends $pb.ProtobufEnum {
  static const OAuthProvider OAUTH_PROVIDER_UNSPECIFIED =
      OAuthProvider._(0, _omitEnumNames ? '' : 'OAUTH_PROVIDER_UNSPECIFIED');
  static const OAuthProvider OAUTH_PROVIDER_GOOGLE = OAuthProvider._(1, _omitEnumNames ? '' : 'OAUTH_PROVIDER_GOOGLE');
  static const OAuthProvider OAUTH_PROVIDER_GITHUB = OAuthProvider._(2, _omitEnumNames ? '' : 'OAUTH_PROVIDER_GITHUB');
  static const OAuthProvider OAUTH_PROVIDER_MICROSOFT =
      OAuthProvider._(3, _omitEnumNames ? '' : 'OAUTH_PROVIDER_MICROSOFT');
  static const OAuthProvider OAUTH_PROVIDER_APPLE = OAuthProvider._(4, _omitEnumNames ? '' : 'OAUTH_PROVIDER_APPLE');
  static const OAuthProvider OAUTH_PROVIDER_FACEBOOK =
      OAuthProvider._(5, _omitEnumNames ? '' : 'OAUTH_PROVIDER_FACEBOOK');

  static const $core.List<OAuthProvider> values = <OAuthProvider>[
    OAUTH_PROVIDER_UNSPECIFIED,
    OAUTH_PROVIDER_GOOGLE,
    OAUTH_PROVIDER_GITHUB,
    OAUTH_PROVIDER_MICROSOFT,
    OAUTH_PROVIDER_APPLE,
    OAUTH_PROVIDER_FACEBOOK,
  ];

  static final $core.List<OAuthProvider?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static OAuthProvider? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const OAuthProvider._(super.value, super.name);
}

/// Authentication result status
class AuthStatus extends $pb.ProtobufEnum {
  static const AuthStatus AUTH_STATUS_UNSPECIFIED = AuthStatus._(0, _omitEnumNames ? '' : 'AUTH_STATUS_UNSPECIFIED');
  static const AuthStatus AUTH_STATUS_SUCCESS = AuthStatus._(1, _omitEnumNames ? '' : 'AUTH_STATUS_SUCCESS');
  static const AuthStatus AUTH_STATUS_MFA_REQUIRED = AuthStatus._(2, _omitEnumNames ? '' : 'AUTH_STATUS_MFA_REQUIRED');
  static const AuthStatus AUTH_STATUS_FAILED = AuthStatus._(3, _omitEnumNames ? '' : 'AUTH_STATUS_FAILED');
  static const AuthStatus AUTH_STATUS_LOCKED = AuthStatus._(4, _omitEnumNames ? '' : 'AUTH_STATUS_LOCKED');
  static const AuthStatus AUTH_STATUS_SUSPENDED = AuthStatus._(5, _omitEnumNames ? '' : 'AUTH_STATUS_SUSPENDED');
  static const AuthStatus AUTH_STATUS_PENDING = AuthStatus._(6, _omitEnumNames ? '' : 'AUTH_STATUS_PENDING');

  static const $core.List<AuthStatus> values = <AuthStatus>[
    AUTH_STATUS_UNSPECIFIED,
    AUTH_STATUS_SUCCESS,
    AUTH_STATUS_MFA_REQUIRED,
    AUTH_STATUS_FAILED,
    AUTH_STATUS_LOCKED,
    AUTH_STATUS_SUSPENDED,
    AUTH_STATUS_PENDING,
  ];

  static final $core.List<AuthStatus?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 6);
  static AuthStatus? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AuthStatus._(super.value, super.name);
}

/// Verification type for email/phone
class VerificationType extends $pb.ProtobufEnum {
  static const VerificationType VERIFICATION_TYPE_UNSPECIFIED =
      VerificationType._(0, _omitEnumNames ? '' : 'VERIFICATION_TYPE_UNSPECIFIED');
  static const VerificationType VERIFICATION_TYPE_EMAIL =
      VerificationType._(1, _omitEnumNames ? '' : 'VERIFICATION_TYPE_EMAIL');
  static const VerificationType VERIFICATION_TYPE_PHONE =
      VerificationType._(2, _omitEnumNames ? '' : 'VERIFICATION_TYPE_PHONE');

  static const $core.List<VerificationType> values = <VerificationType>[
    VERIFICATION_TYPE_UNSPECIFIED,
    VERIFICATION_TYPE_EMAIL,
    VERIFICATION_TYPE_PHONE,
  ];

  static final $core.List<VerificationType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static VerificationType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const VerificationType._(super.value, super.name);
}

/// MFA method types - extensible for future methods
class MfaMethod extends $pb.ProtobufEnum {
  static const MfaMethod MFA_METHOD_UNSPECIFIED = MfaMethod._(0, _omitEnumNames ? '' : 'MFA_METHOD_UNSPECIFIED');
  static const MfaMethod MFA_METHOD_TOTP = MfaMethod._(1, _omitEnumNames ? '' : 'MFA_METHOD_TOTP');
  static const MfaMethod MFA_METHOD_SMS = MfaMethod._(2, _omitEnumNames ? '' : 'MFA_METHOD_SMS');
  static const MfaMethod MFA_METHOD_EMAIL = MfaMethod._(3, _omitEnumNames ? '' : 'MFA_METHOD_EMAIL');
  static const MfaMethod MFA_METHOD_RECOVERY_CODE = MfaMethod._(4, _omitEnumNames ? '' : 'MFA_METHOD_RECOVERY_CODE');

  static const $core.List<MfaMethod> values = <MfaMethod>[
    MFA_METHOD_UNSPECIFIED,
    MFA_METHOD_TOTP,
    MFA_METHOD_SMS,
    MFA_METHOD_EMAIL,
    MFA_METHOD_RECOVERY_CODE,
  ];

  static final $core.List<MfaMethod?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static MfaMethod? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MfaMethod._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
