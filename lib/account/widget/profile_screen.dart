import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/_core/widget/form/form_placeholder.dart';
import 'package:auth_app/_core/widget/scaffold_padding.dart';
import 'package:auth_app/_core/widget/text_placeholder.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/authentication/widget/layout/log_out_button.dart';
import 'package:auth_model/auth_model.dart';
import 'package:octopus/octopus.dart';
import 'package:ui/ui.dart';

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
            padding: ScaffoldPadding.of(context).copyWith(top: 16.0, bottom: 16.0),
            sliver: SliverList.list(
              children: <Widget>[
                Padding(
                  padding: const .all(16.0),
                  child: Row(
                    spacing: 16.0,
                    crossAxisAlignment: .center,
                    children: <Widget>[
                      Shimmer(
                        size: const Size(128.0, 128.0),
                        highlight: Colors.grey[400]!,
                        background: Colors.grey[100]!,
                        radius: const .circular(42.0),
                      ),
                      Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .start,
                        children: <Widget>[
                          TextPlaceholder(height: 16.0, width: 64.0),
                          const SizedBox(height: 12.0),
                          Padding(
                            padding: const .only(left: 8.0),
                            child: TextPlaceholder(height: 14.0, width: 100.0),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const .only(left: 8.0),
                            child: TextPlaceholder(height: 14.0, width: 128.0),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const .only(left: 8.0),
                            child: TextPlaceholder(height: 14.0, width: 72.0),
                          ),
                          const SizedBox(height: 8.0),
                          Padding(
                            padding: const .only(left: 8.0),
                            child: TextPlaceholder(height: 14.0, width: 92.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16.0),
                SizedBox(
                  height: 68.0,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    shape: const RoundedRectangleBorder(
                      borderRadius: .all(.circular(16.0)),
                    ),
                    isThreeLine: false,
                    title: const Text(
                      'Name',
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: TextStyle(
                        fontWeight: .bold,
                        fontSize: 14.0,
                        height: 1.0,
                      ),
                    ),
                    subtitle: Text(
                      AuthenticationScope.userInfoOf(context).name,
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: const TextStyle(
                        height: 1.0,
                      ),
                    ),
                    trailing: const LogOutButton(),
                  ),
                ),
                const SizedBox(width: 16.0),
                SizedBox(
                  height: 68.0,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.settings)),
                    shape: const RoundedRectangleBorder(
                      borderRadius: .all(.circular(16.0)),
                    ),
                    isThreeLine: false,
                    title: const Text(
                      'Settings',
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: TextStyle(
                        fontWeight: .bold,
                        fontSize: 14.0,
                        height: 1.0,
                      ),
                    ),
                    subtitle: const Text(
                      'Change your settings',
                      maxLines: 1,
                      overflow: .ellipsis,
                      style: TextStyle(
                        height: 1.0,
                      ),
                    ),
                    onTap: () => context.octopus.push(Routes.settings),
                  ),
                ),
                const SizedBox(height: 24.0),
                const FormPlaceholder(title: false),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
