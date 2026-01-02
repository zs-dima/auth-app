import 'package:auth_model/auth_model.dart';
import 'package:flutter/foundation.dart';

/// Simple per-user avatar cache invalidation.
class AvatarCache extends ChangeNotifier {
  static const String s3Url = 'http://he708j1a449.sn.mynetname.net:9000/auth-avatars';

  final Map<UserId, int> _versions = {};

  /// Get version for a user.
  int getVersion(UserId userId) => _versions[userId] ?? 0;

  /// Invalidate specific user's avatar.
  void invalidate(UserId userId) {
    _versions[userId] = getVersion(userId) + 1;
    notifyListeners();
  }

  /// Get avatar URL with cache-busting version.
  String getUrl(UserId userId) {
    if (userId.isEmpty) return '';

    final version = _versions[userId] ?? 0;
    return '$s3Url/users/$userId/avatar.webp?v=$version';
  }
}
