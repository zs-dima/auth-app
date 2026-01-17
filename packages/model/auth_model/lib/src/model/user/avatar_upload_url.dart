import 'package:meta/meta.dart';

/// Response containing presigned URL for direct S3 avatar upload.
@immutable
class AvatarUploadUrl {
  const AvatarUploadUrl({
    required this.uploadUrl,
    required this.expiresIn,
  });

  /// Presigned PUT URL for S3 upload.
  final String uploadUrl;

  /// URL expiration in seconds.
  final int expiresIn;
}
