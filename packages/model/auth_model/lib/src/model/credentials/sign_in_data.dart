import 'package:meta/meta.dart';

abstract interface class ISignInData {
  String get login;
  String get password;
}

@immutable
final class SignInData implements ISignInData {
  const SignInData({required this.login, required this.password});

  /// Login.
  @override
  final String login;

  /// Password.
  @override
  final String password;
}
