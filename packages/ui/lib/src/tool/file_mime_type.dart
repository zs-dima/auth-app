extension PlatformFileExtensions on String {
  String get fileExtToMimeType {
    final extension = toLowerCase();

    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'tiff' || 'tif' => 'image/tiff',
      'webp' => 'image/webp',
      'svg' => 'image/svg+xml',
      'bmp' => 'image/bmp',
      'ico' => 'image/vnd.microsoft.icon',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'avi' => 'video/x-msvideo',
      'flv' => 'video/x-flv',
      'mkv' => 'video/x-matroska',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      'mpeg' => 'video/mpeg',
      'ogg' => 'video/ogg',
      'ts' => 'video/mp2t',
      'webm' => 'video/webm',
      'wmv' => 'video/x-ms-wmv',

      _ => '',
    };
  }

  String get fileExtFromMimeType {
    final mimeType = toLowerCase();

    return switch (mimeType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/gif' => 'gif',
      'image/tiff' => 'tiff',
      'image/webp' => 'webp',
      'image/svg+xml' => 'svg',
      'image/bmp' => 'bmp',
      'image/vnd.microsoft.icon' => 'ico',
      'image/heic' => 'heic',
      'image/heif' => 'heif',
      'video/x-msvideo' => 'avi',
      'video/x-flv' => 'flv',
      'video/x-matroska' => 'mkv',
      'video/mp4' => 'mp4',
      'video/quicktime' => 'mov',
      'video/x-m4v' => 'm4v',
      'video/mpeg' => 'mpeg',
      'video/ogg' => 'ogg',
      'video/mp2t' => 'ts',
      'video/webm' => 'webm',
      'video/x-ms-wmv' => 'wmv',

      _ => '',
    };
  }
}
