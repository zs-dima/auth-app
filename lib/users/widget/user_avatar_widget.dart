import 'package:auth_app/_core/core.dart';
import 'package:auth_model/auth_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

    final avatarCache = context.dependencies.avatarCache;

    return ListenableBuilder(
      listenable: avatarCache,
      builder: (context, _) {
        final avatarUrl = avatarCache.getUrl(user.id);
        final avatarVersion = avatarCache.getVersion(user.id);

        return _AvatarCircle(
          key: ValueKey('${user.id}_$avatarVersion'),
          avatarUrl: avatarUrl,
          initials: initials,
          size: size,
          backgroundColor: _getBackgroundColor(initials),
          onPressed: onPressed,
        );
      },
    );
  }
}

class _AvatarCircle extends StatefulWidget {
  const _AvatarCircle({
    super.key,
    required this.avatarUrl,
    required this.initials,
    required this.size,
    required this.backgroundColor,
    this.onPressed,
  });

  final String? avatarUrl;
  final String initials;
  final int size;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  @override
  State<_AvatarCircle> createState() => _AvatarCircleState();
}

class _AvatarCircleState extends State<_AvatarCircle> {
  bool _imageLoadFailed = false;

  @override
  void didUpdateWidget(_AvatarCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      _imageLoadFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showImage = widget.avatarUrl != null && !_imageLoadFailed;

    return GestureDetector(
      onTap: widget.onPressed,
      child: CircleAvatar(
        radius: widget.size.toDouble(),
        backgroundColor: widget.backgroundColor,
        foregroundImage: showImage ? NetworkImage(widget.avatarUrl!) : null,
        onForegroundImageError: showImage
            ? (_, __) => SchedulerBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _imageLoadFailed = true);
                })
            : null,
        child: Text(
          widget.initials,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
