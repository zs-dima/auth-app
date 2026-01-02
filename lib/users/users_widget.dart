import 'package:auth_app/_core/widget/shadow_widget.dart';
import 'package:auth_app/authentication/authentication_scope.dart';
import 'package:auth_app/users/controller/users_controller.dart';
import 'package:auth_app/users/edit/user_edit_dialog.dart';
import 'package:auth_app/users/user_tile_widget.dart';
import 'package:auth_app/users/users_scope.dart';
import 'package:auth_app/users/widget/filter_users_widget.dart';
import 'package:auth_app/users/widget/user_list_header.dart';
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
  UserId? _currentUserId;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userId = AuthenticationScope.userOf(context).maybeCast<AuthenticatedUser>()?.userId;

    if (_currentUserId != userId) {
      _currentUserId = userId;
    }

    final usersController = context.users(listen: true).controller;
    if (_usersController != usersController) {
      _usersController = usersController;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

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
                  return state
                          is UsersLoadedState //
                      ? const Center(child: Text('No users found'))
                      : const Center(child: CircularProgressIndicator());
                }

                final userRoles = [
                  if (allUsers.any((u) => u.role == .administrator)) UserRole.administrator,
                  if (allUsers.any((u) => u.role == .user)) UserRole.user,
                ];
                return RefreshIndicator(
                  onRefresh: () async {
                    if (_currentUserId == null) return;
                    _usersController?.loadUsers(_currentUserId!);
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
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
                                (ctx, index) {
                                  final user = users[index];

                                  return InkWell(
                                    key: ValueKey('user_tile_${user.id}'),
                                    mouseCursor: SystemMouseCursors.click,
                                    onTap: () => editUserDialog(ctx, user),
                                    child: UserTileWidget(
                                      user: user,
                                      tileColor:
                                          index
                                              .isEven //
                                          ? colorScheme.primary.withValues(alpha: 0.1)
                                          : colorScheme.surface,
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
