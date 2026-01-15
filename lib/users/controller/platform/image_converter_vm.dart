import 'dart:typed_data';

import 'package:auth_app/_core/log/logger.dart';
import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:fast_image/fast_image.dart';

Future<(Uint8List?, String)> toWebPBytes(
  ImageInfo originalImage, {
  bool cover = true,
  double quality = 0.3,
  int width = 200,
  int height = 200,
  String mime = 'image/webp',
}) async {
  final input = originalImage.image;
  if (input == null) return (null, originalImage.mimeType);
  if (originalImage.mimeType == mime && input.lengthInBytes < 2500) {
    return (input, mime); // Already optimized WebP
  }

  final stopwatch = Stopwatch()..start();

  final fastImage = FastImage.fromMemory(input);
  FastImage? resizedImage;
  try {
    resizedImage = cover ? fastImage.resizeToFit(width, height) : fastImage.resize(width, height);
  } finally {
    fastImage.dispose();
  }

  Uint8List? upscaledBytes;
  try {
    upscaledBytes = resizedImage.encode(.WebP);
  } finally {
    resizedImage.dispose();
  }

  logger.i('Image converted to WebP in ${stopwatch.elapsedMilliseconds} ms');
  stopwatch.stop();

  return (upscaledBytes, mime);
}

// Future<(Uint8List?, String)> toWebPBytes(
//   ImageInfo originalImage, {
//   bool cover = true,
//   double quality = 0.3,
//   int width = 200,
//   int height = 200,
//   String mime = 'image/webp',
// }) async => (originalImage.image, originalImage.mimeType);

// imagekit_ffi
// import 'package:imagekit_ffi/imagekit_ffi.dart';

// Future<(Uint8List?, String)> toWebPBytes(
//   ImageInfo originalImage, {
//   bool cover = true,
//   double quality = 0.3,
//   int width = 400,
//   int height = 400,
//   String mime = 'image/webp',
// }) async {
//   final input = originalImage.image;
//   if (input == null) return (null, originalImage.mimeType);
//   if (originalImage.mimeType == mime && input.lengthInBytes < 2500) {
//     return (input, mime); // Already optimized WebP
//   }

//   // Decode to RGBA pixels using Flutter's codec
//   final codec = await ui.instantiateImageCodec(input, targetWidth: width, targetHeight: height);
//   final frame = await codec.getNextFrame();
//   final image = frame.image;
//   final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
//   final pixels = byteData?.buffer.asUint8List();
//   final w = image.width, h = image.height;
//   image.dispose();
//   codec.dispose();

//   if (pixels == null) return (null, originalImage.mimeType);

//   // Encode to WebP
//   final webp = WebpKit().encode(
//     pixels,
//     w,
//     h,
//     pixelFormat: .rgba,
//     quality: (quality * 100).round().clamp(1, 100),
//   );

//   return (webp, mime);
// }
