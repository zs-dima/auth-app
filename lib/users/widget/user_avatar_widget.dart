import 'package:auth_app/authentication/authenticated_scope.dart';
import 'package:auth_app/users/controller/avatar_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:control/control.dart';
import 'package:flutter/material.dart';

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
    required this.user,
    required this.size,
    this.onPressed,
  });

  final IUserInfo user;
  final int size;
  final VoidCallback? onPressed;

  String _getInitials(String name) {
    final names = name.split(' ').where((n) => n.isNotEmpty).toList();
    if (names.isEmpty) return '';
    if (names.length > 1) return '${names.first[0]}${names.last[0]}'.toUpperCase();
    return names.first[0].toUpperCase();
  }

  Color _getBackgroundColor(String initials) {
    if (initials.isEmpty) return Colors.primaries.first;
    final value = initials.codeUnitAt(0) + (initials.length > 1 ? initials.codeUnitAt(1) : 0);
    return Colors.primaries[value % Colors.primaries.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(user.name);

    final avatarController = AuthenticatedScope.avatarControllerOf(context);

    return StateConsumer<AvatarController, AvatarState>(
      controller: avatarController,
      builder: (_, state, __) {
        // Null once the avatar is known to be missing — the initials then render without any request.
        final avatarUrl = avatarController.getUrl(user.id);
        return _AvatarCircle(
          key: ValueKey(avatarUrl),
          avatarUrl: avatarUrl,
          initials: initials,
          size: size,
          backgroundColor: _getBackgroundColor(initials),
          onImageError: (error) => avatarController.recordLoadError(user.id, error),
          onPressed: onPressed,
        );
      },
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    super.key,
    required this.avatarUrl,
    required this.initials,
    required this.size,
    required this.backgroundColor,
    required this.onImageError,
    this.onPressed,
  });

  final String? avatarUrl;
  final String initials;
  final int size;
  final Color backgroundColor;
  final ValueChanged<Object> onImageError;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final diameter = size * 2.0;

    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: size.toDouble(),
        backgroundColor: backgroundColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(initials, style: const TextStyle(color: Colors.white)),
            // Covers the initials once decoded, so a failed load simply leaves them visible.
            // `errorBuilder` — not `foregroundImage` — registers the image stream listener with
            // `reportErrors: false`, so the 404 of a user without an avatar never reaches
            // `FlutterError` (and Sentry), not even when this tile is disposed mid-request.
            if (avatarUrl case final url?)
              ClipOval(
                child: Image(
                  image: NetworkImage(url),
                  width: diameter,
                  height: diameter,
                  fit: .cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, error, __) {
                    onImageError(error);
                    return const SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
