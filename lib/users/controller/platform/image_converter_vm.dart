import 'dart:typed_data';

import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:flutter/services.dart';

Future<(Uint8List?, String)> toWebPBytes(
  ImageInfo originalImage, {
  bool cover = true,
  double quality = 0.3,
  int width = 200,
  int height = 200,
  String mime = 'image/webp',
}) async => (originalImage.image, originalImage.mimeType);
