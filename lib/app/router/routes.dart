import 'package:auth_app/core/constant/config.dart';
import 'package:auth_app/feature/account/widget/profile_screen.dart';
import 'package:auth_app/feature/authentication/widget/signin_screen.dart';
import 'package:auth_app/feature/authentication/widget/signup_screen.dart';
import 'package:auth_app/feature/developer/widget/developer_screen.dart';
import 'package:auth_app/feature/settings/settings_dialog.dart';
import 'package:auth_app/feature/users/users_scope.dart';
import 'package:auth_app/feature/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

enum Routes with OctopusRoute {
  signin('signin', title: 'Sign-In'),
  signup('signup', title: 'Sign-Up'),
  home('home', title: Config.appName),
  profile('profile', title: 'Profile'),
  developer('developer', title: 'Developer'),
  settingsDialog('settings-dialog', title: 'Settings');

  const Routes(this.name, {this.title});

  @override
  final String name;

  @override
  final String? title;

  @override
  Widget builder(BuildContext context, OctopusState state, OctopusNode node) => switch (this) {
        Routes.signin => const SignInScreen(),
        Routes.signup => const SignUpScreen(),
        Routes.home => const UsersScope(child: UsersScreen()),
        Routes.profile => const ProfileScreen(),
        Routes.developer => const DeveloperScreen(),
        Routes.settingsDialog => const SettingsDialog(),
      };
}
