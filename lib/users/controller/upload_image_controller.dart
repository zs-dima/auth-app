import 'dart:async';
import 'dart:ui' as ui;

import 'package:auth_app/_core/message/user_facing_error.dart';
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

final class UploadImageController extends StateController<UploadImageState> with SequentialControllerHandler {
  UploadImageController({
    ImageInfo imageInfo = .empty,
  }) : super(
         initialState: UploadImageState.loading(imageInfo),
       ) {
    // Initialize dimensions for provided data
    final url = imageInfo.url;
    final image = imageInfo.image;
    final sizeFuture = (image != null)
        ? _getMemoryImageDimensions(image)
        : (url.isNotEmpty ? _getNetworkImageDimensions(url) : null);
    if (sizeFuture != null) {
      Future.delayed(.zero, () async {
        final size = await sizeFuture;
        // A late probe result must not overwrite a user action.
        if (state is! UploadImageLoadingState) return;
        // LOADING, not loaded: only user actions may reach the upload/delete subscription.
        setState(
          size == null && url.isNotEmpty
              ? const UploadImageState.loading(.empty)
              : UploadImageState.loading(
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
    error: (error, stackTrace) async {
      reportFailure('Image | setImage | failed', error, stackTrace: stackTrace, caption: 'Error on setImage');
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
    error: (error, stackTrace) async {
      reportFailure('Image | setUrl | failed', error, stackTrace: stackTrace, caption: 'Error on setUrl');
    },
    name: 'setUrl',
  );

  void clean() => handle(
    () async {
      setState(const UploadImageState.loaded(.empty));
    },
    error: (error, stackTrace) async {
      reportFailure('Image | clean | failed', error, stackTrace: stackTrace, caption: 'Error on clean');
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
    } on Object catch (e, s) {
      // A file the platform codec cannot decode is the user's file, not our defect: it is
      // reported and shown, and it does not become a crash-reporter issue.
      reportFailure(
        'Image | dimensions | failed',
        e,
        stackTrace: s,
        caption: 'Error getting image dimensions',
        level: .warn,
      );
      return Size.zero;
    }
  }

  // Get dimensions from network image
  static Future<Size?> _getNetworkImageDimensions(String url) async {
    if (url.isEmpty) return Size.zero;

    try {
      final imageProvider = NetworkImage(url);
      final stream = imageProvider.resolve(.empty);
      final completer = Completer<Size>();

      final listener = ImageStreamListener(
        (info, _) {
          try {
            if (completer.isCompleted) return;
            completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
          } finally {
            info.dispose();
          }
        },
        onError: (error, stackTrace) {
          if (completer.isCompleted) return;
          completer.completeError(error, stackTrace);
        },
      );

      stream.addListener(listener);

      try {
        return await completer.future;
      } finally {
        stream.removeListener(listener);
      }
    } on Object {
      // Broken/unauthorized image URL: dimensions are a nicety — degrade to null silently.
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
