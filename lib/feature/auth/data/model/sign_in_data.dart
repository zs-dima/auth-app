import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';

@immutable
final class SignInData implements ISignInData {
  const SignInData({
    required this.login,
    required this.password,
    required this.installationId,
  });

  @override
  final String login;
  @override
  final String password;
  @override
  final String installationId;

  static final RegExp _loginValidator = RegExp(
    r'\@|[A-Z]|[a-z]|[0-9]|\.|\-|\_|\+',
    caseSensitive: false,
    multiLine: false,
  );
  String? isValidLogin() {
    if (login.isEmpty) return 'Login is required';
    if (login.length < 4) return 'Login is too short';
    if (login.length > 64) return 'Login is too long';
    if (!_loginValidator.hasMatch(login)) return 'Login is invalid';
    return null;
  }

  String? isValidPassword() {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 3) return 'Password is too short';
    if (password.length > 64) return 'Password is too long';
    return null;
  }
}
