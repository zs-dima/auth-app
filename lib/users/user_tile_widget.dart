import 'package:auth_app/settings/settings_scope.dart';
import 'package:auth_app/users/widget/user_avatar_widget.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';

class UserTileWidget extends StatelessWidget {
  const UserTileWidget({
    super.key,
    required this.user,
    this.tileColor,
  });

  final User user;
  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    final appTheme = SettingsScope.themeOf(context).theme;

    final userTextStyle = user.deleted
        ? TextStyle(
            decoration: TextDecoration.lineThrough,
            color: DefaultTextStyle.of(context).style.color?.withOpacity(0.5),
          )
        : null;

    return Tooltip(
      message: '${user.deleted ? 'Deleted ' : ''}${user.role.name} ${user.name}',
      waitDuration: const Duration(milliseconds: 700),
      child: ListTile(
        mouseCursor: SystemMouseCursors.click,
        tileColor: tileColor,
        leading: UserAvatarWidget(
          user: user,
          size: 17,
        ),
        trailing: const Icon(Icons.edit),
        subtitle: appTheme.size.isPhone
            ? Text(
                user.email,
                style: userTextStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : null,
        title: appTheme.size.isPhone
            ? Text(
                user.name,
                style: userTextStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FixedColumnWidth(150),
                },
                children: [
                  TableRow(
                    children: [
                      Text(
                        user.name,
                        style: userTextStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        user.email,
                        style: userTextStyle,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        user.role.name,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
