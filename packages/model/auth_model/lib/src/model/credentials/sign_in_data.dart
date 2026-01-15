import 'package:auth_model/src/model/credentials/auth_result.dart';
import 'package:meta/meta.dart';

/// Sign-in data interface.
abstract interface class ISignInData {
  /// User identifier (email or phone).
  String get identifier;

  /// Identifier type (email or phone).
  IdentifierType get identifierType;

  /// Password.
  String get password;
}

/// Sign-in data implementation.
@immutable
final class SignInData implements ISignInData {
  const SignInData({
    required this.identifier,
    required this.password,
    this.identifierType = IdentifierType.email,
  });

  /// Creates sign-in data with email.
  const SignInData.email({
    required String email,
    required this.password,
  }) : identifier = email,
       identifierType = IdentifierType.email;

  /// Creates sign-in data with phone.
  const SignInData.phone({
    required String phone,
    required this.password,
  }) : identifier = phone,
       identifierType = IdentifierType.phone;

  @override
  final String identifier;

  @override
  final IdentifierType identifierType;

  @override
  final String password;
}

/// Sign-up data for new account registration.
@immutable
final class SignUpData implements ISignInData {
  const SignUpData({
    required this.identifier,
    required this.password,
    required this.displayName,
    this.identifierType = IdentifierType.email,
    this.locale,
    this.timezone,
  });

  /// Creates sign-up data with email.
  const SignUpData.email({
    required String email,
    required this.password,
    required this.displayName,
    this.locale,
    this.timezone,
  }) : identifier = email,
       identifierType = IdentifierType.email;

  /// Creates sign-up data with phone.
  const SignUpData.phone({
    required String phone,
    required this.password,
    required this.displayName,
    this.locale,
    this.timezone,
  }) : identifier = phone,
       identifierType = IdentifierType.phone;

  @override
  final String identifier;

  @override
  final IdentifierType identifierType;

  @override
  final String password;

  /// Display name.
  final String displayName;

  /// Locale (BCP 47, e.g., "en-US").
  final String? locale;

  /// Timezone (IANA, e.g., "America/New_York").
  final String? timezone;
}
