import 'dart:async';

import 'package:auth_app/_core/app.dart';
import 'package:auth_app/users/controller/users_avatars_controller.dart';
import 'package:auth_model/auth_model.dart';
import 'package:core_tool/core_tool.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef PhotoCallback = void Function(Uint8List? avatar);

class PhotoEditWidget extends StatefulWidget {
  const PhotoEditWidget({
    super.key,
    required this.user,
    required this.onPhotoChanged,
    this.userPhoto,
  });

  final IUserInfo user;
  final PhotoCallback onPhotoChanged;
  final Uint8List? userPhoto;

  @override
  State<PhotoEditWidget> createState() => _PhotoEditWidgetState();
}

class _PhotoEditWidgetState extends State<PhotoEditWidget> {
  late UserAvatar _userAvatar;
  late final UsersAvatarsController _avatarController;
  StreamSubscription? _userAvatarSubscription;

  @override
  void initState() {
    super.initState();

    _avatarController = context.dependencies.avatarController;
    final userAvatar = widget.userPhoto == null
        ? _avatarController.state.avatar(widget.user.id)
        : UserAvatar(userId: widget.user.id, avatar: widget.userPhoto, loaded: true);
    _userAvatar = userAvatar ?? UserAvatar.empty.copyWith(userId: widget.user.id);

    if (userAvatar == null) {
      _avatarController.loadAvatar(widget.user.id, reload: false);
    } else if (widget.userPhoto == null) {
      widget.onPhotoChanged(_userAvatar.avatar);
    }

    _userAvatarSubscription =
        _avatarController //
            .toStream()
            .where((i) => i is UsersAvatarsLoadedState)
            .map((state) => state.avatar(widget.user.id))
            .where((state) => state != null)
            .distinct()
            .listen((avatar) {
              if (!mounted) return;
              setState(() => _userAvatar = avatar!);
              widget.onPhotoChanged(_userAvatar.avatar);
            });
  }

  Future<void> _uploadPhoto() async {
    final image = await FilePicker.platform.pickFiles(
      type: kIsWeb ? FileType.custom : FileType.image,
      allowMultiple: false,
      allowedExtensions: ['png', 'jpg'],
      withData: true,
    );

    if (image == null || image.count == 0) {
      return;
    }

    if (!mounted) return;
    setState(() {
      _userAvatar = _userAvatar.copyWith(avatar: image.files.firstOrNull?.bytes);
      widget.onPhotoChanged(_userAvatar.avatar);
    });
  }

  void _deletePhoto() {
    setState(() {
      _userAvatar = _userAvatar.copyWith(avatar: null);
      widget.onPhotoChanged(_userAvatar.avatar);
    });
  }

  @override
  void dispose() {
    _userAvatarSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: SizedBox.square(
        dimension: 140,
        child: switch (_userAvatar) {
          // TODO: Add blurhash placeholder.
          _ when !_userAvatar.loaded => const Center(child: CircularProgressIndicator()),
          _ when _userAvatar.avatar.isNullOrEmpty => Center(
            child: TextButton(
              onPressed: _uploadPhoto,
              child: const Text('Upload photo'),
            ),
          ),
          _ => Stack(
            children: [
              Positioned.fill(
                child: Image.memory(
                  _userAvatar.avatar!,
                  fit: BoxFit.contain,
                  semanticLabel: 'User photo',
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background.withAlpha(170),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.upload),
                        color: theme.colorScheme.onBackground,
                        onPressed: _uploadPhoto,
                        tooltip: 'Upload photo',
                      ),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: theme.colorScheme.onBackground,
                        onPressed: _deletePhoto,
                        tooltip: 'Delete photo',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}
