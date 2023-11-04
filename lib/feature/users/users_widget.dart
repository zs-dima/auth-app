import 'package:auth_app/core/widget/layout/app_layout.dart';
import 'package:auth_app/core/widget/shadow_widget.dart';
import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/users/bloc/users_bloc.dart';
import 'package:auth_app/feature/users/edit/user_edit_dialog.dart';
import 'package:auth_app/feature/users/user_tile_widget.dart';
import 'package:auth_app/feature/users/users_scope.dart';
import 'package:auth_app/feature/users/widget/user_list_header.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class UsersWidget extends StatefulWidget {
  const UsersWidget({super.key});

  @override
  State createState() => _UsersWidgetState();
}

class _UsersWidgetState extends State<UsersWidget> {
  UsersBloc? _usersBloc;
  IUserInfo? _currentUser;

  FocusNode? _searchPartFocus;
  TextEditingController? _searchPartController;

  @override
  void initState() {
    super.initState();

    _searchPartFocus = FocusNode();
    _searchPartController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = AuthScope.userOf(context).maybeCast<AuthenticatedUser>()?.userInfo;

    if (_currentUser != user) {
      _currentUser = user;
    }

    final usersBloc = context.users(listen: true).bloc;
    if (_usersBloc != usersBloc) {
      _usersBloc = usersBloc;
    }
  }

  @override
  void dispose() {
    _searchPartFocus?.dispose();
    _searchPartController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppLayout(
      title: 'Users',
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Create new user',
        heroTag: 'create_user',
        onPressed: () {
          HapticFeedback.mediumImpact().ignore();
          editUserDialog(
            context,
            User.empty.copyWith(id: const Uuid().v4()),
            createNewUser: true,
          );
        },
        label: Text(
          'Create user',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        icon: Icon(Icons.add, color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
      ),
      child: ShadowWidget(
        child: Column(
          children: [
            ShadowWidget(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: TextField(
                  focusNode: _searchPartFocus,
                  controller: _searchPartController,
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact().ignore();
                        _searchPartFocus!.unfocus();
                        _searchPartController!.clear();
                        _usersBloc!.add(const UsersEvent.filterUsers(''));
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  onChanged: (v) => _usersBloc!.add(UsersEvent.filterUsers(v)),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<UsersBloc, UsersState>(
                bloc: _usersBloc,
                builder: (_, state) {
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
                      _usersBloc?.add(UsersEvent.loadUsers(userId: _currentUser!.id));
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: ScrollController(),
                      slivers: userRoles.map((userRole) {
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
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
