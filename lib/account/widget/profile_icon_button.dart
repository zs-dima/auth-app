import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/users/widget/user_avatar_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

/// {@template profile_icon_button}
/// ProfileIconButton widget
/// {@endtemplate}
class ProfileIconButton extends StatelessWidget {
  /// {@macro profile_icon_button}
  const ProfileIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthenticationScope.userOf(context);
    final authUser = AuthenticationScope.userInfoOf(context);
    return currentUser is AuthenticatedUser
        ? Tooltip(
            message: authUser.name,
            child: UserAvatarWidget(
              user: authUser,
              size: 15,
              onPressed: () {
                Octopus.maybeOf(context)?.setState(
                  (state) => state
                    ..removeByName(Routes.profile.name)
                    ..add(Routes.profile.node()),
                );
                HapticFeedback.mediumImpact().ignore();
              },
            ),
          )
        : const SizedBox.shrink();
  }
}
