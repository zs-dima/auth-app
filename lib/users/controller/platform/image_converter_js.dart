import 'dart:js_interop';
import 'dart:typed_data';

import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:web/web.dart' as web;

Future<(Uint8List?, String)> toWebPBytes(
  ImageInfo originalImage, {
  bool cover = true,
  double quality = 0.3,
  int width = 400,
  int height = 400,
  String mime = 'image/webp',
}) async {
  final originalMime = originalImage.mimeType;
  final input = originalImage.image;
  if (input == null) return (null, originalMime);
  if (originalMime == mime && input.lengthInBytes < 2500) {
    return (input, mime); // Already optimized WebP
  }

  final blob = web.Blob(
    <JSAny>[input.toJS].toJS,
    web.BlobPropertyBag(type: originalMime),
  );
  final bmp = await web.window.createImageBitmap(blob).toDart;

  final canvas = web.OffscreenCanvas(width, height);
  final ctx = canvas.getContext('2d') as web.OffscreenCanvasRenderingContext2D?;
  if (ctx == null) return (null, originalMime);

  final sw = bmp.width.toDouble(), sh = bmp.height.toDouble();
  final tw = width.toDouble(), th = height.toDouble();

  // Calculate scale to maintain aspect ratio
  // cover: fill entire canvas (may crop), contain: fit inside canvas (may letterbox)
  final scaleX = tw / sw, scaleY = th / sh;
  final scale = cover ? (scaleX > scaleY ? scaleX : scaleY) : (scaleX < scaleY ? scaleX : scaleY);

  final dw = sw * scale, dh = sh * scale;
  final dx = (tw - dw) / 2, dy = (th - dh) / 2;

  ctx.drawImage(bmp, 0, 0, sw, sh, dx, dy, dw, dh);

  final out = await canvas.convertToBlob(web.ImageEncodeOptions(type: mime, quality: quality)).toDart;
  final buf = await out.arrayBuffer().toDart;
  return (Uint8List.view(buf.toDart), out.type);
}
