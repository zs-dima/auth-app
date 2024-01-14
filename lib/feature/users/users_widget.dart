import 'package:auth_app/core/widget/shadow_widget.dart';
import 'package:auth_app/feature/authentication/widget/authentication_scope.dart';
import 'package:auth_app/feature/users/controller/users_controller.dart';
import 'package:auth_app/feature/users/edit/user_edit_dialog.dart';
import 'package:auth_app/feature/users/user_tile_widget.dart';
import 'package:auth_app/feature/users/users_scope.dart';
import 'package:auth_app/feature/users/widget/filter_users_widget.dart';
import 'package:auth_app/feature/users/widget/user_list_header.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';

class UsersWidget extends StatefulWidget {
  const UsersWidget({super.key});

  @override
  State createState() => _UsersWidgetState();
}

class _UsersWidgetState extends State<UsersWidget> {
  UsersController? _usersController;
  IUserInfo? _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = AuthenticationScope.userOf(context).maybeCast<AuthenticatedUser>()?.userInfo;

    if (_currentUser != user) {
      _currentUser = user;
    }

    final usersController = context.users(listen: true).controller;
    if (_usersController != usersController) {
      _usersController = usersController;
    }
  }

  @override
  void dispose() {
    _usersController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ShadowWidget(
      child: Column(
        children: [
          ShadowWidget(
            child: FilterUsersWidget(
              onChanged: _usersController!.filterUsers,
            ),
          ),
          Expanded(
            child: StateConsumer<UsersController, UsersState>(
              controller: _usersController,
              builder: (_, state, __) {
                final allUsers = state.users;

                if (allUsers.isEmpty) {
                  return state is UsersLoadedState //
                      ? const Center(child: Text('No users found'))
                      : const Center(child: CircularProgressIndicator());
                }

                final userRoles = [
                  if (allUsers.any((u) => u.role == UserRole.administrator)) UserRole.administrator,
                  if (allUsers.any((u) => u.role == UserRole.user)) UserRole.user,
                ];
                return RefreshIndicator(
                  onRefresh: () async {
                    if (_currentUser == null) return;
                    _usersController?.loadUsers(_currentUser!.id);
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: ScrollController(),
                    slivers: [
                      // SliverOverlapInjector(
                      //   handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      // ),
                      ...userRoles.map((userRole) {
                        final users = allUsers.where((i) => i.role == userRole).toList();

                        return SliverMainAxisGroup(
                          slivers: [
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: UserListHeaderDelegate(userRole.name),
                            ),
                            SliverFixedExtentList(
                              itemExtent: 50,
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext ctx, int index) {
                                  final user = users[index];

                                  return InkWell(
                                    key: ValueKey('user_tile_${user.id}'),
                                    mouseCursor: SystemMouseCursors.click,
                                    onTap: () => editUserDialog(ctx, user),
                                    child: UserTileWidget(
                                      user: user,
                                      tileColor: index.isEven //
                                          ? colorScheme.primary.withOpacity(0.1)
                                          : colorScheme.background,
                                    ),
                                  );
                                },
                                childCount: users.length,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
