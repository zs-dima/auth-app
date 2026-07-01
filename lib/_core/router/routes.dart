import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/account/widget/profile_screen.dart';
import 'package:auth_app/authentication/widget/auth_recovery_confirm_screen.dart';
import 'package:auth_app/authentication/widget/auth_recovery_start_screen.dart';
import 'package:auth_app/authentication/widget/signin_screen.dart';
import 'package:auth_app/authentication/widget/signup_screen.dart';
import 'package:auth_app/developer/widget/developer_screen.dart';
import 'package:auth_app/settings/widget/settings_dialog.dart';
import 'package:auth_app/settings/widget/settings_widget.dart';
import 'package:auth_app/users/users_scope.dart';
import 'package:auth_app/users/users_screen.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  signup('signup', title: 'Sign-Up'),
  authRecoveryStart('auth-recovery', title: 'Forgot Password'),
  authRecoveryConfirm('auth-reset', title: 'Reset Password'),
  emailVerified('email-verified', title: 'Email Verified'),

  home('home', title: Config.appName),
  profile('profile', title: 'Profile'),
  developer('developer', title: 'Developer'),

  settings('settings', title: 'Settings'),
  settingsDialog('settings-dialog', title: 'Settings')
  ;

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    signin || emailVerified => const SignInScreen(),
    signup => const SignUpScreen(),
    authRecoveryStart => const AuthRecoveryStartScreen(),
    authRecoveryConfirm => switch (state.arguments[RouteNode.token] ?? node.arguments[RouteNode.token]) {
      final String token when !token.isNullOrSpace => AuthRecoveryConfirmScreen(
        token: token,
        lang: state.arguments[RouteNode.lang] ?? node.arguments[RouteNode.lang],
      ),
      _ => const SignInScreen(),
    },

    home => const UsersScope(child: UsersScreen()),
    profile => const ProfileScreen(),
    developer => const DeveloperScreen(),

    settings => const SettingsWidget(),
    // Routes.developer => const DeveloperScreen(),
    settingsDialog => const SettingsDialog(),
  };
}

abstract final class RouteNode {
  static const String continueUrl = 'continue';
  static const String token = 'token';
  static const String status = 'status';
  static const String success = 'success';
  static const String code = 'code';
  static const String lang = 'lang';
  static const String user = 'user';
}

/// Reads a required `int` router argument, throwing an explicit [ArgumentError] (instead of an
/// opaque null-deref / cast error) when it is missing or malformed — e.g. a hand-edited deep link.
int _requireIntArg(String? raw, String key) {
  if (raw == null) throw ArgumentError('Missing router argument "$key" for type int');
  final value = int.tryParse(raw);
  if (value == null) throw ArgumentError('Router argument "$key" is not a valid int: "$raw"');
  return value;
}

/// Reads a required `bool` router argument, throwing an explicit [ArgumentError] when missing/invalid.
bool _requireBoolArg(String? raw, String key) {
  if (raw == null) throw ArgumentError('Missing router argument "$key" for type bool');
  final value = bool.tryParse(raw);
  if (value == null) throw ArgumentError('Router argument "$key" is not a valid bool: "$raw"');
  return value;
}

/// Reads a required `String` router argument, throwing an explicit [ArgumentError] when missing.
String _requireStringArg(String? raw, String key) {
  if (raw == null) throw ArgumentError('Missing router argument "$key" for type String');
  return raw;
}

extension OctopusNodeX on OctopusNode {
  T get<T>(String key) => switch (T) {
    const (int) => _requireIntArg(arguments[key], key) as T,
    const (bool) => _requireBoolArg(arguments[key], key) as T,
    const (String) => _requireStringArg(arguments[key], key) as T,
    const (List<int>) => (arguments[key]?.split(',').map(int.tryParse).nonNulls.toList() ?? const <int>[]) as T,
    _ => throw ArgumentError('Unsupported router Node type $T'),
  };

  T? tryGet<T>(String key) {
    final argument = arguments[key];
    if (argument == null) return null;

    return switch (T) {
      const (int) => int.tryParse(argument) as T?,
      const (bool) => bool.tryParse(argument) as T?,
      const (String) => argument as T?,
      _ => throw ArgumentError('Unsupported router Node type $T'),
    };
  }
}

extension OctopusStateX on OctopusState {
  T get<T>(String key) => switch (T) {
    const (int) => _requireIntArg(arguments[key], key) as T,
    const (bool) => _requireBoolArg(arguments[key], key) as T,
    const (String) => _requireStringArg(arguments[key], key) as T,
    const (List<int>) => (arguments[key]?.split(',').map(int.tryParse).nonNulls.toList() ?? const <int>[]) as T,
    _ => throw ArgumentError('Unsupported router Node type $T'),
  };

  T? tryGet<T>(String key) {
    final argument = arguments[key];
    if (argument == null) return null;

    return switch (T) {
      const (int) => int.tryParse(argument) as T?,
      const (bool) => bool.tryParse(argument) as T?,
      const (String) => argument as T?,
      _ => throw ArgumentError('Unsupported router Node type $T'),
    };
  }
}
