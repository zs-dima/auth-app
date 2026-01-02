import 'dart:async';
import 'dart:ui' as ui;

import 'package:auth_app/_core/message/controller/app_message_controller_mixin.dart';
import 'package:auth_app/_core/message/controller/message_controller.dart';
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_image_controller.freezed.dart';

@freezed
sealed class UploadImageState with _$UploadImageState {
  const factory UploadImageState.loading({
    @Default('') String url,
    Uint8List? image,
    Size? size,
  }) = UploadImageLoadingState;
  const factory UploadImageState.loaded({
    @Default('') String url,
    Uint8List? image,
    Size? size,
  }) = UploadImageLoadedState;
}

final class UploadImageController extends StateController<UploadImageState>
    with SequentialControllerHandler, AppMessageControllerMixin {
  UploadImageController({
    required AppMessageController messageController,
    String url = '',
    Uint8List? image,
  }) : super(
         initialState: UploadImageState.loading(url: url, image: image),
       ) {
    this.messageController = messageController;

    // Initialize dimensions for provided data
    final sizeFuture = (image != null)
        ? _getMemoryImageDimensions(image)
        : (url.isNotEmpty ? _getNetworkImageDimensions(url) : null);
    if (sizeFuture != null) {
      Future.delayed(.zero, () async {
        final size = await sizeFuture;
        setState(UploadImageState.loaded(url: url, image: image, size: size));
      });
    }
  }

  // void setDimensions(double? width, double? height) => handle(
  //   () async {
  //     setState(
  //       state is UploadImageLoadedState
  //           ? UploadImageState.loaded(url: state.url, image: state.image, width: width, height: height)
  //           : UploadImageState.loading(url: state.url, image: state.image, width: width, height: height),
  //     );
  //   },
  //   error: (error, stackTrace) {
  //     setError('Error setting dimensions', error, stackTrace);
  //     Error.throwWithStackTrace(error, stackTrace);
  //   },
  //   name: 'setDimensions',
  // );

  void setImage(Uint8List? image) => handle(
    () async {
      if (image == null) return setState(const UploadImageState.loaded());

      final size = await _getMemoryImageDimensions(image);

      setState(UploadImageState.loaded(image: image, size: size));
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
      if (link == state.url) return;

      final size = await _getNetworkImageDimensions(link);
      if (size == .zero) return;

      setState(UploadImageState.loaded(url: link, size: size));
    },
    error: (error, stackTrace) {
      setError('Error on setUrl', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    name: 'setUrl',
  );

  void clean() => handle(
    () async {
      setState(const UploadImageState.loaded());
    },
    error: (error, stackTrace) {
      setError('Error on clean', error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    },
    name: 'clean',
  );

  // Get dimensions from in-memory image data
  Future<Size> _getMemoryImageDimensions(Uint8List imageData) async {
    try {
      // Use compute for better performance with large images
      final dimensions = await compute(_decodeImageDimensions, imageData);
      return Size(dimensions.width, dimensions.height);

      // Decode image on main isolate (Flutter's image codec registry is not available in background isolates)
      // final codec = await ui.instantiateImageCodec(imageData);
      // final frameInfo = await codec.getNextFrame();
      // final image = frameInfo.image;

      // final size = Size(image.width.toDouble(), image.height.toDouble());

      // // Clean up resources
      // image.dispose();
      // codec.dispose();

      // return size;
    } catch (e) {
      setError('Error getting image dimensions', e, .current);
      return Size.zero;
    }
  }

  // Get dimensions from network image
  static Future<Size> _getNetworkImageDimensions(String url) async {
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
      return Size.zero;
    }
  }

  // void createUploadImage() => handle(
  //       () async {
  //         setProgressStarted();

  //         final result = await _repository.createUploadImage(state.UploadImage);
  //         setMessage('UploadImage successfully saved', Colors.green[700]);

  //         setState(UploadImageState.created(result));
  //         setState(UploadImageState.loaded(result));
  //       },
  //       error: (error, stackTrace) {
  //         setError('Error on saving UploadImage', error, stackTrace);
  //         Error.throwWithStackTrace(error, stackTrace);
  //       },
  //       done: () async {
  //         setProgressDone();
  //       },
  //       name: 'createUploadImage',
  //     );

  // void updateUploadImage() => handle(
  //       () async {
  //         setProgressStarted();

  //         final result = await _repository.updateUploadImage(state.UploadImage);
  //         setMessage('UploadImage successfully saved', Colors.green[700]);

  //         setState(UploadImageState.updated(result));
  //         setState(UploadImageState.loaded(result));
  //       },
  //       error: (error, stackTrace) {
  //         setError('Error on saving UploadImage', error, stackTrace);
  //         Error.throwWithStackTrace(error, stackTrace);
  //       },
  //       done: () async {
  //         setProgressDone();
  //       },
  //       name: 'updateUploadImage',
  //     );
}

// Static helper method to run in isolate for better performance
Future<({double height, double width})> _decodeImageDimensions(
  Uint8List imageData,
) async {
  final codec = await ui.instantiateImageCodec(imageData);
  final frameInfo = await codec.getNextFrame();
  final image = frameInfo.image;

  final width = image.width.toDouble();
  final height = image.height.toDouble();

  // Clean up resources
  image.dispose();
  codec.dispose();

  return (width: width, height: height);
}
