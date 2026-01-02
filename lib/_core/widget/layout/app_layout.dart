import 'package:auth_app/_core/widget/common_actions.dart';
import 'package:auth_app/_core/widget/layout/progress_overlay.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/users/widget/user_avatar_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:ui/ui.dart';

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
    final currentUser = AuthenticationScope.userOf(context);
    final authUser = AuthenticationScope.userInfoOf(context);

    return Scaffold(
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: switch (currentUser) {
          AuthenticatedUser() => Tooltip(
            message: authUser.name,
            child: UserAvatarWidget(
              user: authUser,
              size: 15,
            ),
          ),
          _ => null,
        },
        title: AppText.headlineMedium(
          title,
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
