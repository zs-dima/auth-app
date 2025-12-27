import 'package:auth_app/app/router/routes.dart';
import 'package:auth_app/_core/widget/form/form_placeholder.dart';
import 'package:auth_app/_core/widget/scaffold_padding.dart';
import 'package:auth_app/_core/widget/shimmer.dart';
import 'package:auth_app/_core/widget/text_placeholder.dart';
import 'package:auth_app/feature/authentication/widget/authentication_scope.dart';
import 'package:auth_app/feature/authentication/widget/log_out_button.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template profile_screen}
/// ProfileScreen widget.
/// {@endtemplate}
class ProfileScreen extends StatelessWidget {
  /// {@macro profile_screen}
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthenticationScope.userOf(context);
    if (currentUser is! AuthenticatedUser) return const SizedBox.shrink();

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            title: Text('Profile'),
            pinned: true,
            floating: true,
            snap: true,
          ),
          SliverPadding(
            padding: ScaffoldPadding.of(context).copyWith(top: 16, bottom: 16),
            sliver: SliverList.list(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Shimmer(
                        size: const Size(128, 128),
                        color: Colors.grey[400],
                        backgroundColor: Colors.grey[100],
                        cornerRadius: 42,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextPlaceholder(height: 16, width: 64),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextPlaceholder(height: 14, width: 100),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextPlaceholder(height: 14, width: 128),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextPlaceholder(height: 14, width: 72),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: TextPlaceholder(height: 14, width: 92),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 68,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    isThreeLine: false,
                    title: const Text(
                      'Name',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1,
                      ),
                    ),
                    subtitle: Text(
                      currentUser.userInfo.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1,
                      ),
                    ),
                    trailing: const LogOutButton(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 68,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.settings)),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(16),
                      ),
                    ),
                    isThreeLine: false,
                    title: const Text(
                      'Settings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1,
                      ),
                    ),
                    subtitle: const Text(
                      'Change your settings',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        height: 1,
                      ),
                    ),
                    onTap: () => context.octopus.push(Routes.settingsDialog),
                  ),
                ),
                const SizedBox(height: 24),
                const FormPlaceholder(title: false),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
