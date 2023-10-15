import 'package:auth_app/app/app.dart';
import 'package:auth_app/app/theme/extension/theme_sizes.dart';
import 'package:auth_app/app/theme/widget/theme_scope.dart';
import 'package:auth_app/core/widget/form/switch_form_field.dart';
import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/users/bloc/users_avatars_bloc.dart';
import 'package:auth_app/feature/users/edit/photo_edit_widget.dart';
import 'package:auth_app/feature/users/users_scope.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ui_tool/ui_tool.dart';

class EditUserWidget extends StatefulWidget {
  final User user;
  final bool createNewUser;

  final UsersController usersController;

  const EditUserWidget({
    super.key,
    required this.user,
    this.createNewUser = false,
    required this.usersController,
  });

  @override
  State createState() => _EditUserWidgetState();
}

class _EditUserWidgetState extends State<EditUserWidget> {
  final _formKey = GlobalKey<FormState>();
  late User _user;
  Uint8List? _userAvatar;
  String? _password;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = ThemeScope.of(context).theme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (appTheme.size.isPhone)
            Padding(
              padding: ThemePaddings.defaultMedium.medium.copyWith(bottom: 0, left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchFormField(
                    'Deleted',
                    value: _user.deleted,
                    onChanged: (value) => setState(() => _user = _user.copyWith(deleted: value)),
                  ),
                  const Spacer(),
                  PhotoEditWidget(
                    user: _user,
                    userPhoto: _userAvatar,
                    photoCallback: (photo) => _userAvatar = photo,
                  ),
                ],
              ),
            ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: SizedBox(
                    width: 640,
                    child: Padding(
                      padding: appTheme.size.isPhone ? EdgeInsets.zero : ThemePaddings.defaultMedium.medium,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.person_outlined),
                                    labelText: 'Name',
                                  ),
                                  initialValue: _user.name,
                                  validator: (value) => value.isNullOrSpace ? 'Name required' : null,
                                  onSaved: (value) => setState(() => _user = _user.copyWith(name: '$value')),
                                  autocorrect: false,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.mail_outlined),
                                    labelText: 'Email',
                                  ),
                                  initialValue: _user.email,
                                  validator: (value) => !Validators.isValidEmail(value) ? 'Email required' : null,
                                  onSaved: (value) => setState(() => _user = _user.copyWith(email: '$value')),
                                  autocorrect: false,
                                ),
                                const SizedBox(height: 20),
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                    prefixIcon: Icon(Icons.shield_outlined),
                                  ),
                                  value: _user.role,
                                  validator: (role) => role == null ? 'User role required' : null,
                                  onSaved: (value) =>
                                      setState(() => _user = _user.copyWith(role: value ?? UserRole.user)),
                                  onChanged: (role) {},
                                  items: [
                                    UserRole.administrator,
                                    UserRole.user,
                                  ]
                                      .map(
                                        (role) => DropdownMenuItem<UserRole>(
                                          value: role,
                                          child: Text(role.name),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 20),
                                if (widget.createNewUser)
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.lock_outlined),
                                      labelText: 'Password',
                                    ),
                                    obscureText: true,
                                    validator: (value) => widget.createNewUser && !Validators.isValidPassword(value)
                                        ? 'Password must be at least 5 characters long'
                                        : null,
                                    onSaved: (value) => setState(() => _password = value),
                                    autocorrect: false,
                                  )
                                else
                                  // TODO: implement password change
                                  TextButton(
                                    child: const Text('Change password'),
                                    onPressed: () {
                                      HapticFeedback.mediumImpact().ignore();
                                      context.showInfo('Disabled for the demo version');
                                    },
                                  ),
                              ],
                            ),
                          ),
                          if (!appTheme.size.isPhone) ...[
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 140,
                              child: Column(
                                children: [
                                  PhotoEditWidget(
                                    user: _user,
                                    userPhoto: _userAvatar,
                                    photoCallback: (photo) => _userAvatar = photo,
                                  ),
                                  const SizedBox(height: 16),
                                  SwitchFormField(
                                    'Deleted',
                                    value: _user.deleted,
                                    onChanged: (value) => setState(() => _user = _user.copyWith(deleted: value)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    HapticFeedback.mediumImpact().ignore();

                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState!.save();
                      if (widget.createNewUser) {
                        await widget.usersController.createUser(_user, _password!);
                        widget.usersController.savePhoto(_user.id, _userAvatar);
                      } else {
                        final avatar = context.auth(listen: false).avatarBloc.state.avatar(_user.id)?.avatar;
                        await widget.usersController.updateUser(_user);
                        if (_userAvatar != avatar) {
                          widget.usersController.savePhoto(_user.id, _userAvatar);
                        }
                      }
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: ThemePaddings.defaultMedium.medium,
                child: SizedBox(
                  width: 120,
                  child: OutlinedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      HapticFeedback.mediumImpact().ignore();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
