import 'package:auth_app/_core/app.dart';
import 'package:auth_app/users/controller/users_avatars_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class UserAvatarWidget extends StatefulWidget {
  const UserAvatarWidget({
    super.key,
    required this.user,
    required this.size,
    this.onPressed,
  });

  final IUserInfo user;
  final int size;
  final VoidCallback? onPressed;

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  late final UsersAvatarsController _avatarController;

  @override
  void initState() {
    super.initState();

    _avatarController = context.dependencies.avatarController;
    if (_avatarController.state.avatar(widget.user.id) == null) {
      _avatarController.loadAvatar(widget.user.id, reload: false);
    }
  }

  String _getInitials(String name) {
    final names = name.split(' ');
    var initials = '';
    if (names.length > 1) {
      initials = names.first[0] + names.last[0];
    } else if (names.length == 1) {
      initials = names.first[0];
    }
    return initials.toUpperCase();
  }

  Color _getIconColor(String initials) {
    // Use the ASCII value of the initials letters to get consistent color
    final value = initials.codeUnitAt(0) + (initials.length > 1 ? initials.codeUnitAt(1) : 0);
    return Colors.primaries[value % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = _getInitials(user.name);

    return StateConsumer<UsersAvatarsController, UsersAvatarsState>(
      controller: _avatarController,
      buildWhen: (previous, current) => previous.avatar(user.id) != current.avatar(user.id),
      builder: (_, avatarState, __) {
        final avatarLength = avatarState.avatar(user.id)?.avatar?.length ?? 0;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: CircleAvatar(
            key: ValueKey('${widget.key}${widget.user.id}$avatarLength'),
            radius: widget.size.toDouble(),
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
    );
  }
}
