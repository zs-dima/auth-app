import 'package:auth_app/feature/auth/auth_scope.dart';
import 'package:auth_app/feature/users/bloc/users_avatars_bloc.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class UserAvatarWidget extends StatefulWidget {
  const UserAvatarWidget({
    super.key,
    required this.user,
    required this.size,
  });

  final IUserInfo user;
  final int size;

  @override
  State<UserAvatarWidget> createState() => _UserAvatarWidgetState();
}

class _UserAvatarWidgetState extends State<UserAvatarWidget> {
  late final UsersAvatarsBloc _avatarBloc;

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
  void initState() {
    super.initState();

    _avatarBloc = context.auth(listen: false).avatarBloc;
    if (_avatarBloc.state.avatar(widget.user.id) == null) {
      _avatarBloc.add(UsersAvatarsEvent.loadAvatar(widget.user.id, reload: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initials = _getInitials(user.name);

    return BlocBuilder<UsersAvatarsBloc, UsersAvatarsState>(
      bloc: _avatarBloc,
      buildWhen: (previous, current) => previous.avatar(user.id) != current.avatar(user.id),
      builder: (_, avatarState) {
        final avatarLength = avatarState.avatar(user.id)?.avatar?.length ?? 0;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: CircleAvatar(
            key: ValueKey('${widget.key}${widget.user.id}$avatarLength'),
            radius: widget.size.toDouble(),
            backgroundColor: _getIconColor(initials),
            backgroundImage: avatarState.map<ImageProvider>(
              user,
              avatar: MemoryImage.new,
              blurhash: (blurhash) => BlurHashImage(
                blurhash,
                decodingWidth: widget.size,
                decodingHeight: widget.size,
              ),
            ),
            child: avatarLength == 0 ? Text(initials) : null,
          ),
        );
      },
    );
  }
}
