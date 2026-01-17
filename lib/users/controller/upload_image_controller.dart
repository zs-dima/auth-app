import 'dart:async';
import 'dart:ui' as ui;

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ui/ui.dart';

part 'upload_image_controller.freezed.dart';

@freezed
sealed class ImageInfo with _$ImageInfo {
  static const empty = ImageInfo();

  const factory ImageInfo({
    @Default('') String url,
    Uint8List? image,
    Size? size,
    @Default('') String mimeType,
  }) = _ImageInfo;
}

@freezed
sealed class UploadImageState with _$UploadImageState {
  const factory UploadImageState.loading(ImageInfo imageInfo) = UploadImageLoadingState;
  const factory UploadImageState.loaded(ImageInfo imageInfo) = UploadImageLoadedState;
}

final class UploadImageController extends StateController<UploadImageState>
    with SequentialControllerHandler, AppMessageControllerMixin {
  UploadImageController({
    required AppMessageController messageController,
    ImageInfo imageInfo = .empty,
  }) : super(
         initialState: UploadImageState.loading(imageInfo),
       ) {
    this.messageController = messageController;

    // Initialize dimensions for provided data
    final url = imageInfo.url;
    final image = imageInfo.image;
    final sizeFuture = (image != null)
        ? _getMemoryImageDimensions(image)
        : (url.isNotEmpty ? _getNetworkImageDimensions(url) : null);
    if (sizeFuture != null) {
      Future.delayed(.zero, () async {
        final size = await sizeFuture;
        setState(
          size == null && url.isNotEmpty
              ? const UploadImageState.loaded(.empty)
              : UploadImageState.loaded(
                  ImageInfo(
                    url: size == null ? '' : url,
                    image: image,
                    size: size,
                    mimeType: imageInfo.mimeType,
                  ),
                ),
        );
      });
    }
  }

  void setImage(Uint8List? image, String mimeType) => handle(
    () async {
      if (image == null) return setState(const UploadImageState.loaded(.empty));

      final size = await _getMemoryImageDimensions(image);

      setState(UploadImageState.loaded(ImageInfo(image: image, size: size, mimeType: mimeType)));
    },
    error: (error, stackTrace) {
      setError('Error on setImage', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    name: 'setImage',
  );

  void setUrl(String url) => handle(
    () async {
      final uri = Uri.tryParse(url);

      final isCompleteUrl =
          uri != null &&
          uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty &&
          uri.host.contains('.') &&
          uri.host.split('.').last.length >= 2;

      if (!isCompleteUrl) return;

      final link = '$uri';
      if (link == state.imageInfo.url) return;

      final size = await _getNetworkImageDimensions(link);
      if (size == .zero) return;

      setState(
        UploadImageState.loaded(ImageInfo(url: link, size: size, mimeType: url.split('.').last.fileExtToMimeType)),
      );
    },
    error: (error, stackTrace) {
      setError('Error on setUrl', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    name: 'setUrl',
  );

  void clean() => handle(
    () async {
      setState(const UploadImageState.loaded(.empty));
    },
    error: (error, stackTrace) {
      setError('Error on clean', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    name: 'clean',
  );

  /// Decodes image dimensions.
  /// Web: uses compute (runs in same context, not a real isolate).
  /// Native: decodes on main thread (image codec unavailable in background isolates).
  Future<Size> _getMemoryImageDimensions(Uint8List imageData) async {
    try {
      if (kIsWeb) {
        final dimensions = await compute(_decodeImageDimensions, imageData);
        return Size(dimensions.width, dimensions.height);
      }
      // Native: decode on main thread (fast enough, codec unavailable in isolates)
      final codec = await ui.instantiateImageCodec(imageData);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      codec.dispose();
      return size;
    } catch (e) {
      setError('Error getting image dimensions', e, .current);
      return Size.zero;
    }
  }

  // Get dimensions from network image
  static Future<Size?> _getNetworkImageDimensions(String url) async {
    if (url.isEmpty) return Size.zero;

    try {
      final imageProvider = NetworkImage(url);
      final stream = imageProvider.resolve(.empty);
      final completer = Completer<ui.Image>();

      final listener = ImageStreamListener(
        (info, _) {
          completer.complete(info.image);
        },
        onError: completer.completeError,
      );

      stream.addListener(listener);

      try {
        final image = await completer.future;
        return Size(image.width.toDouble(), image.height.toDouble());
        // setDimensions(image.width.toDouble(), image.height.toDouble());
      } finally {
        stream.removeListener(listener);
      }
    } catch (e) {
      // setError('Error getting network image dimensions', e, StackTrace.current);
      return null;
    }
  }
}

/// Top-level function for background isolate image decoding (web only).
Future<({double height, double width})> _decodeImageDimensions(Uint8List imageData) async {
  final codec = await ui.instantiateImageCodec(imageData);
  final frameInfo = await codec.getNextFrame();
  final image = frameInfo.image;

  final width = image.width.toDouble();
  final height = image.height.toDouble();

  image.dispose();
  codec.dispose();

  return (width: width, height: height);
}
