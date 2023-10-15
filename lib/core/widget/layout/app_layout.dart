import 'package:auth_app/app/theme/extension/theme_sizes.dart';
import 'package:auth_app/core/widget/layout/progress_overlay.dart';
import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/settings/settings_dialog.dart';
import 'package:auth_app/feature/users/widget/user_avatar_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? floatingActionButton;

  const AppLayout({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = AuthScope.userOf(context);

    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              HapticFeedback.mediumImpact().ignore();
              settingsDialog(context);
            },
          ),
          SizedBox(width: theme.paddings.small.top),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              HapticFeedback.mediumImpact().ignore();
              AuthScope.of(context).signOut();
            },
          ),
          SizedBox(width: theme.paddings.medium.top),
        ],
      ),
      body: ProgressOverlay(
        child: child,
      ),
    );
  }
}
