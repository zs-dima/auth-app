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

class UserEditWidget extends StatefulWidget {
  const UserEditWidget({
    super.key,
    required this.user,
    this.createNewUser = false,
    required this.usersController,
  });

  final User user;
  final bool createNewUser;

  final UsersController usersController;

  @override
  State createState() => _UserEditWidgetState();
}

class _UserEditWidgetState extends State<UserEditWidget> {
  final _formKey = GlobalKey<FormState>();
  late User _user;
  Uint8List? _userAvatar;
  String? _password;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Future<void> _saveUser() async {
    HapticFeedback.mediumImpact().ignore();

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      // TODO: Demo
      // if (_user.id.toUpperCase() == '${GUID}'.toUpperCase()) {
      //   context.showInfo('User editor disabled in Demo. User ${_user.name}');
      //   if (mounted) Navigator.of(context).pop();
      //   return;
      // }

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = ThemeScope.of(context).theme;

    final isPhone = appTheme.size.isPhone;

    final defaultMediumPaddings = ThemePaddings.defaultMedium.medium;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (isPhone)
            Padding(
              padding: defaultMediumPaddings.copyWith(bottom: 0, left: 8),
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
                      padding: isPhone ? EdgeInsets.zero : defaultMediumPaddings,
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
                                  validator: (value) => Validators.isValidEmail(value) ? null : 'Email required',
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
                          if (!isPhone) ...[
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
                  onPressed: _saveUser,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: defaultMediumPaddings,
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
