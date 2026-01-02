import 'package:auth_app/_core/generated/resources/assets.gen.dart';
import 'package:auth_app/_core/message/extension/message_toast.dart';
import 'package:auth_app/_core/router/routes.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/impersonation/controller/impersonate_controller.dart';
import 'package:auth_app/impersonation/impersonate_scope.dart';
import 'package:auth_app/impersonation/widget/impersonate_user_dialog.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:octopus/octopus.dart';

class UserAvatarMenuWidget extends StatelessWidget {
  const UserAvatarMenuWidget({super.key});

  static String _getInitials(String name) {
    if (name.isEmpty) return 'NN';
    final names = name.split(' ');
    var initials = '';
    if (names.length > 1) {
      initials = names.first[0] + names.last[0];
    } else if (names.length == 1) {
      initials = names.first[0];
    }
    return initials.toUpperCase();
  }

  static Color _getIconColor(String initials) {
    // Use the ASCII value of the initials letters to get consistent color
    final value = initials.codeUnitAt(0) + (initials.length > 1 ? initials.codeUnitAt(1) : 0);
    return Colors.primaries[value % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    final authUser = AuthenticationScope.userInfoOf(context);

    final authenticated = authUser.id != UserIdX.empty;
    if (!authenticated) return const SizedBox.shrink();

    return StateConsumer<ImpersonateController, ImpersonateState>(
      controller: context.impersonation().controller,
      buildWhen: (previous, current) => previous != current,
      builder: (context, impersonateState, child) {
        final currentUser = impersonateState.user;

        final impersonate = authUser.id != currentUser.id;
        final userName = impersonate ? '${authUser.name} > ${currentUser.name}' : currentUser.name;

        final initials = _getInitials(currentUser.name.trim());

        return PopupMenuButton<String>(
          enabled: authenticated,
          offset: const Offset(0.0, 50.0),
          tooltip: userName,
          itemBuilder: (context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              enabled: false,
              height: 10.0,
              padding: .zero,
              child: Center(
                child: Text(
                  userName,
                  maxLines: 1,
                  overflow: .ellipsis,
                  softWrap: true,
                ),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Profile',
              child: ListTile(
                leading: Icon(Icons.person_outline_rounded),
                title: Text('Your profile', overflow: .ellipsis, maxLines: 1),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'Settings',
              child: ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings', overflow: .ellipsis, maxLines: 1),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'Users',
              child: ListTile(
                leading: Icon(Icons.group_outlined),
                title: Text('Users', overflow: .ellipsis, maxLines: 1),
              ),
            ),
            // if (authUser.role == UserRole.admin)
            //   PopupMenuItem<String>(
            //     value: 'Impersonate',
            //     child: ListTile(
            //       leading:
            //           impersonate ? const Icon(Icons.group_off_outlined) : const Icon(Icons.group_outlined),
            //       title: Text(
            //         impersonate ? 'Stop impersonate' : 'Impersonate',
            //         overflow: TextOverflow.ellipsis,
            //         maxLines: 1,
            //       ),
            //     ),
            //   ),
            // PopupMenuItem<String>(
            //   value: 'Version',
            //   child: ListTile(
            //     leading: const Icon(Icons.info_outline_rounded),
            //     title: Text(
            //       'Version: ${context.dependencies.environment.version}',
            //       overflow: TextOverflow.ellipsis,
            //       maxLines: 1,
            //     ),
            //   ),
            // ),
            const PopupMenuDivider(),

            const PopupMenuItem<String>(
              value: 'Logout',
              child: ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Logout', overflow: .ellipsis, maxLines: 1),
              ),
            ),
          ],
          onSelected: (menuId) async {
            switch (menuId) {
              case 'Impersonate':
                if (impersonate) {
                  context.impersonation().impersonate(authUser);
                } else {
                  impersonateUserDialog(context, authUser: authUser);
                }
                break;

              case 'Profile':
                await Octopus.maybeOf(context)?.setState(
                  (state) => state
                    ..removeByName(Routes.profile.name)
                    ..add(Routes.profile.node()),
                );
                break;

              // case 'Settings':
              //   await Octopus.maybeOf(context)?.setState(
              //     (state) => state
              //       ..removeByName(Routes.settings.name)
              //       ..add(Routes.settings.node()),
              //   );
              //   break;

              // case 'Logout':
              //   await showLogOutDialog(context);
              //   break;

              case 'Version':
                final data = await rootBundle.loadString(Assets.environment);

                if (context.mounted) context.showInfo(data);
                break;
            }
          },
          child: true
              ? AnimatedSwitcher(
                  duration: Durations.extralong1,
                  child: CircleAvatar(
                    key: ValueKey(currentUser.email),
                    radius: 14.0,
                    foregroundColor: Colors.white,
                    backgroundColor: _getIconColor(initials),
                    child: Text(initials, style: const TextStyle(fontSize: 12.0)),
                  ),
                )
              // ignore: dead_code
              : SizedBox(
                  height: 45.0,
                  width: 150.0,
                  child: Row(
                    crossAxisAlignment: .center,
                    mainAxisSize: .min,
                    children: [
                      const SizedBox(width: 7.0),
                      AnimatedSwitcher(
                        duration: Durations.extralong1,
                        child: CircleAvatar(
                          key: ValueKey(currentUser.email),
                          radius: 12,
                          foregroundColor: Colors.white,
                          backgroundColor: _getIconColor(initials),
                          child: Text(initials, style: const TextStyle(fontSize: 12.0)),
                        ),
                      ),
                      /*StateConsumer<UsersAvatarsController, UsersAvatarsState>(
                  controller: _avatarController,
                  buildWhen: (previous, current) => previous.avatar(user.id) != current.avatar(user.id),
                  builder: (_, avatarState, __) {
                    final avatarLength = avatarState.avatar(user.id)?.avatar?.length ?? 0;
                    return AnimatedSwitcher(
                      duration: Durations.extralong1,
                      child: CircleAvatar(
                          key: ValueKey('${currentUser.email}${userAvatarState.avatarLoaded}'),
                        radius: 15.0,
                        backgroundColor: _getIconColor(initials),
                        backgroundImage: avatarState.mapAvatar<ImageProvider>(
                          user,
                          avatar: MemoryImage.new,
                          blurhash: (blurhash) => BlurHashImage(
                            blurhash,
                            decodingWidth: widget.size,
                            decodingHeight: widget.size,
                          ),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: avatarLength == 0 ? Text(initials) : const SizedBox.expand(),
                          onPressed: widget.onPressed,
                        ),
                      ),
                    );
                  },
                ),*/
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Text(
                          userName,
                          maxLines: 1,
                          overflow: .ellipsis,
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 3.0),
                      // const Icon(AppIcons.chevronDown, size: 14.0), // Icons.arrow_drop_down, size: 16.0
                      const SizedBox(width: 3.0),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
