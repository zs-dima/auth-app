import 'dart:async';

import 'package:auth_app/_core/core.dart';
import 'package:auth_app/_core/theme/extension/theme_sizes.dart';
import 'package:auth_app/_core/widget/form/switch_form_field.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/users/controller/avatar_cache.dart';
import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:auth_app/users/edit/image_edit_widget.dart';
import 'package:auth_app/users/users_scope.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:ui/ui.dart';

class UserEditWidget extends StatefulWidget {
  const UserEditWidget({
    super.key,
    required this.user,
    this.createNewUser = false,
    required this.usersController,
  });

  final User user;
  final bool createNewUser;

  final IUsersController usersController;

  @override
  State createState() => _UserEditWidgetState();
}

class _UserEditWidgetState extends State<UserEditWidget> {
  final _formKey = GlobalKey<FormState>();
  late User _user;

  String? _password;
  UploadImageController? _imageController;

  StreamSubscription<UploadImageState>? _imageSubscription;

  late AvatarCache _avatarCache;

  @override
  void initState() {
    super.initState();
    _user = widget.user;

    _avatarCache = context.dependencies.avatarCache;

    _imageController = UploadImageController(
      messageController: context.dependencies.messageController,
      url: _avatarCache.getUrl(_user.id),
    );

    _imageSubscription = _imageController?.toStream().skip(1).whereType<UploadImageLoadedState>().listen(
      (state) async {
        if (!mounted) return;

        final image = state.image;

        // Only delete if both image and url are empty (user explicitly cleared)
        if (image == null && state.url.isEmpty) {
          await context.users().deleteUserAvatar(_user.id);
          _avatarCache.invalidate(_user.id);
          return;
        }

        // Upload new avatar if image bytes are provided
        if (image != null) {
          await _uploadAvatarToS3(_user.id, image);
        }
      },
    );
  }

  /// Upload avatar to S3 using presigned URL workflow.
  Future<void> _uploadAvatarToS3(UserId userId, Uint8List imageData) async {
    final usersController = context.users();

    // 1. Get presigned upload URL from server
    final uploadInfo = await usersController.getAvatarUploadUrl(
      userId,
      'image/webp', // Content type
      imageData.length,
    );

    if (uploadInfo == null) return;

    // 2. Upload directly to S3 using presigned URL
    try {
      final response = await http.put(
        Uri.parse(uploadInfo.uploadUrl),
        headers: {'Content-Type': 'image/webp'},
        body: imageData,
      );

      if (response.statusCode != 200) {
        if (mounted) context.showError('Failed to upload avatar to S3.');
        return;
      }

      _avatarCache.invalidate(userId);
    } on Exception catch (e) {
      if (mounted) context.showError('Failed to upload avatar: $e');
      return;
    }

    // 3. Confirm upload with server
    await usersController.confirmAvatarUpload(userId);
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
      } else {
        await widget.usersController.updateUser(_user);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _imageSubscription?.cancel();
    _imageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appTheme = SettingsScope.themeOf(context).theme;

    final isPhone = appTheme.size.isPhone;

    final defaultMediumPaddings = ThemePaddings.defaultMedium.medium;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (isPhone)
            Padding(
              padding: defaultMediumPaddings.copyWith(bottom: 0.0, left: 8.0),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  SwitchFormField(
                    'Deleted',
                    value: _user.deleted,
                    onChanged: (value) => setState(() => _user = _user.copyWith(deleted: value)),
                  ),
                  const Spacer(),
                  ImageEditWidget(
                    controller: _imageController,
                    width: 140.0,
                    height: 140.0,
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
                    width: 640.0,
                    child: Padding(
                      padding: isPhone ? EdgeInsets.zero : defaultMediumPaddings,
                      child: Row(
                        crossAxisAlignment: .start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
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
                                const SizedBox(height: 20.0),
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
                                const SizedBox(height: 20.0),
                                DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Role',
                                    prefixIcon: Icon(Icons.shield_outlined),
                                  ),
                                  initialValue: _user.role,
                                  validator: (role) => role == null ? 'User role required' : null,
                                  onSaved: (value) => setState(() => _user = _user.copyWith(role: value ?? .user)),
                                  onChanged: (role) {},
                                  items:
                                      [
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
                                const SizedBox(height: 20.0),
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
                            const SizedBox(width: 20.0),
                            SizedBox(
                              width: 140.0,
                              child: Column(
                                spacing: 16.0,
                                children: [
                                  ImageEditWidget(
                                    controller: _imageController,
                                    width: 140.0,
                                    height: 140.0,
                                  ),
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
          const SizedBox(height: 30.0),
          Row(
            mainAxisAlignment: .end,
            children: [
              SizedBox(
                width: 120.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: _saveUser,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: .bold),
                  ),
                ),
              ),
              Padding(
                padding: defaultMediumPaddings,
                child: SizedBox(
                  width: 120.0,
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
