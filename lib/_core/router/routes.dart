import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
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

  Widget _emailVerified(BuildContext context, OctopusNode node) {
    final status = node.get<String>(RouteNode.status);
    if (status == 'success') {
      context.showInfo('Your email has been successfully verified.');
    } else {
      final code = node.get<String>(RouteNode.code);
      final msg = switch (code) {
        'invalid_token' => 'The verification link is invalid. Please request a new verification email.',
        'expired_token' => 'The verification link has expired. Please request a new verification email.',
        'internal_error' => 'An internal error occurred during email verification. Please try again later.',
        _ => 'Email verification failed.',
      };
      context.showError(msg);
    }
    return const SignInScreen();
  }

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    signin => const SignInScreen(),
    signup => const SignUpScreen(),
    authRecoveryStart => const AuthRecoveryStartScreen(),
    authRecoveryConfirm => AuthRecoveryConfirmScreen(
      token: node.get<String>(RouteNode.token),
      lang: node.get<String>(RouteNode.lang),
    ),
    emailVerified => _emailVerified(context, node),

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
  static const String code = 'code';
  static const String lang = 'lang';
  static const String user = 'user';

  const RouteNode._();
}

extension OctopusNodeX on OctopusNode {
  T get<T>(String key) => switch (T) {
    const (int) => int.tryParse(arguments[key]!) as T,
    const (bool) => bool.tryParse(arguments[key]!) as T,
    const (String) => arguments[key] as T,
    const (List<int>) => arguments[key]?.split(',').map(int.tryParse).nonNulls.toList() as T,
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
