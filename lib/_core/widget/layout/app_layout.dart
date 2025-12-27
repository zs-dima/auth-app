import 'package:auth_app/_core/widget/common_actions.dart';
import 'package:auth_app/_core/widget/layout/progress_overlay.dart';
import 'package:auth_app/authentication/widget/authentication_scope.dart';
import 'package:auth_app/users/widget/user_avatar_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';

class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
    this.actions,
  });

  final String title;
  final Widget child;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = AuthenticationScope.userOf(context);

    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: currentUser is AuthenticatedUser
            ? Tooltip(
                message: currentUser.userInfo.name,
                child: UserAvatarWidget(
                  user: currentUser.userInfo,
                  size: 15,
                ),
              )
            : null,
        title: Text(
          title,
          style: theme.textTheme.headlineMedium,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: actions ?? CommonActions(),
        // [
        //   IconButton(
        //     icon: const Icon(Icons.settings),
        //     onPressed: () {
        //       HapticFeedback.mediumImpact().ignore();
        //       settingsDialog(context);
        //     },
        //   ),
        //   SizedBox(width: theme.paddings.small.top),
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () {
        //       HapticFeedback.mediumImpact().ignore();
        //       AuthenticationScope.controllerOf(context).signOut();
        //     },
        //   ),
        //   SizedBox(width: theme.paddings.medium.top),
        // ],
      ),
      body: ProgressOverlay(
        child: child,
      ),
    );
  }
}
