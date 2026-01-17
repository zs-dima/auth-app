import 'package:auth_app/_core/theme/extension/theme_sizes.dart';
import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/users/edit/user_edit_widget.dart';
import 'package:auth_app/users/users_scope.dart';
import 'package:auth_model/auth_model.dart';
import 'package:ui/ui.dart';

void editUserDialog(
  BuildContext context,
  User user, {
  bool createNewUser = false,
}) => showDialog(
  context: context,
  barrierDismissible: false,
  builder: (ctx) {
    final theme = Theme.of(ctx);
    final colorScheme = theme.colorScheme;
    final appTheme = SettingsScope.themeOf(context).theme;

    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: .all(.circular(8.0))),
      insetPadding:
          appTheme
              .size
              .isPhone //
          ? .zero
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      titlePadding: EdgeInsets.zero,
      title: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: const .vertical(top: .circular(8.0)),
          color: colorScheme.primary,
        ),
        child: Padding(
          padding: theme.paddings.tiny,
          child: AppText.bodyLarge(
            createNewUser //
                ? 'Create new user'
                : 'Edit ${user.name}',
            color: colorScheme.onPrimary,
            fontWeight: .bold,
            overflow: .ellipsis,
            textAlign: .center,
            maxLines: 1,
          ),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: .maxFinite,
        child: UserEditWidget(
          user: user,
          createNewUser: createNewUser,
          usersController: context.users(),
        ),
      ),
    );
  },
);
