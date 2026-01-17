import 'package:auth_app/_core/widget/common_actions.dart';
import 'package:auth_app/_core/widget/layout/app_layout.dart';
import 'package:auth_app/users/edit/user_edit_dialog.dart';
import 'package:auth_app/users/users_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppLayout(
      title: 'Users',
      actions: CommonActions(),
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
      child: const UsersWidget(),
    );
  }
}
