import 'package:auth_app/_core/constant/config.dart';
import 'package:auth_app/account/widget/profile_screen.dart';
import 'package:auth_app/authentication/widget/signin_screen.dart';
import 'package:auth_app/authentication/widget/signup_screen.dart';
import 'package:auth_app/developer/widget/developer_screen.dart';
import 'package:auth_app/settings/settings_dialog.dart';
import 'package:auth_app/users/users_scope.dart';
import 'package:auth_app/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  signup('signup', title: 'Sign-Up'),
  forgotPassword('forgot-password', title: 'Forgot Password'),
  home('home', title: Config.appName),
  profile('profile', title: 'Profile'),
  developer('developer', title: 'Developer'),
  settingsDialog('settings-dialog', title: 'Settings')
  ;

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
    signin => const SignInScreen(),
    signup => const SignUpScreen(),
    forgotPassword => const SignInScreen(), // TODO
    home => const UsersScope(child: UsersScreen()),
    profile => const ProfileScreen(),
    developer => const DeveloperScreen(),
    settingsDialog => const SettingsDialog(),
  };
}
