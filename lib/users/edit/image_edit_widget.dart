import 'dart:async';

import 'package:auth_app/initialization/widget/inherited_dependencies.dart';
import 'package:auth_app/users/controller/upload_image_controller.dart';
import 'package:control/control.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:ui/ui.dart' hide ImageInfo;

typedef ImageCallback = void Function(String url, Uint8List? image);

class ImageEditWidget extends StatefulWidget {
  const ImageEditWidget({
    super.key,
    // this.onImageChanged,
    this.controller,
    this.width,
    this.height,
    this.label,
  });

  // final ImageCallback? onImageChanged;
  final UploadImageController? controller;

  /// If non-null, requires the child to have exactly this width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  final double? height;

  final String? label;

  @override
  State<ImageEditWidget> createState() => _ImageEditWidgetState();
}

class _ImageEditWidgetState extends State<ImageEditWidget> {
  late UploadImageController _imageController;

  late TextEditingController _urlController;

  late bool _dragOver = false;

  static const List<FileFormat> _imageFormats = [
    Formats.jpeg,
    Formats.png,
    Formats.gif,
    Formats.tiff,
    Formats.webp,
    Formats.svg,
    Formats.bmp,
    Formats.ico,
    Formats.heic,
    Formats.heif,
  ];

  @override
  void initState() {
    super.initState();

    _imageController =
        widget.controller ?? UploadImageController(messageController: context.dependencies.messageController);
    _urlController = TextEditingController(text: _imageController.state.imageInfo.url);
  }

  Future<void> _uploadImage() async {
    final image = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select an image',
      type: kIsWeb ? .custom : .image,
      allowMultiple: false, // allow multiple files to be selected
      allowedExtensions: [..._imageFormats.map((e) => e.providerFormat.fileExtFromMimeType)],
      withData: true, // bytes for web/mobile preview
      lockParentWindow: false,
      readSequential: false,
      withReadStream: false,
    );

    if (image == null || image.count == 0) return;

    if (!mounted) return;
    final file = image.files.firstOrNull;
    if (file == null) return;

    final mimeType = file.extension!.fileExtToMimeType;
    _setImage(file.bytes, mimeType);
  }

  void _setImage(Uint8List? image, String mimeType) {
    _imageController.setImage(image, mimeType);
    _urlController.text = '';
  }

  void _urlImage(String url) {
    _imageController.setUrl(url);
  }

  void _deleteImage() {
    _imageController.clean();
    _urlController.text = '';
  }

  @override
  void dispose() {
    _urlController.dispose();
    if (widget.controller == null) _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DropRegion(
        formats: _imageFormats,
        hitTestBehavior: .opaque,
        onDropOver: (event) {
          final item = event.session.items.first;
          // event.session.allowedOperations.contains(DropOperation.copy)
          return _imageFormats.any(item.canProvide) ? DropOperation.copy : DropOperation.forbidden;
        },
        onDropEnter: (event) => setState(() => _dragOver = true),
        onDropLeave: (event) => setState(() => _dragOver = false),
        onPerformDrop: (event) async {
          // Called when user dropped the item.
          final item = event.session.items.first;

          // data reader is available now
          final reader = item.dataReader!;
          final format = reader.getFormats(_imageFormats).firstOrNull as FileFormat?;
          if (format == null) return;

          reader.getFile(
            format,
            (file) async {
              final image = await file.readAll();
              final mimeType = format.providerFormat;
              _setImage(image, mimeType);
            },
            onError: (error) => debugPrint('Error reading value $error'),
          );
        },
        child: StateConsumer<UploadImageController, UploadImageState>(
          controller: _imageController,
          builder: (_, state, __) => switch (state.imageInfo.image) {
            // _ when !_imageState.loaded => const Center(child: CircularProgressIndicator()),
            _ when state.imageInfo.image == null && state.imageInfo.url.isEmpty => Card(
              clipBehavior: .antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: const .all(.circular(8)),
                side: _dragOver
                    ? BorderSide(
                        color: Colors.red.withAlpha(100),
                        width: 1.5,
                      )
                    : .none,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _uploadImage,
                    child: Text(widget.label ?? 'Upload an image'),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const .only(
                      left: 12,
                      right: 12,
                      bottom: 12,
                    ),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'or enter the URL of your image',
                      ),
                      controller: _urlController,
                      // onChanged: (value) => _url = value,
                      autocorrect: false,
                      onFieldSubmitted: _urlImage,
                      onChanged: _urlImage,
                      // onTapOutside: (event) => _urlImage(_urlController.text),
                    ),
                  ),
                ],
              ),
            ),
            _ => Stack(
              children: [
                if (state.imageInfo.image != null)
                  Positioned.fill(
                    child: ClipRRect(
                      clipBehavior: .antiAlias,
                      borderRadius: const .all(
                        .circular(8),
                      ),
                      child: Image.memory(
                        state.imageInfo.image!,
                        fit: .contain,
                        semanticLabel: 'Image',
                      ),
                    ),
                  ),
                if (state.imageInfo.image == null && state.imageInfo.url.isNotEmpty)
                  Positioned.fill(
                    child: ClipRRect(
                      clipBehavior: .antiAlias,
                      borderRadius: const .all(
                        .circular(8),
                      ),
                      child: Image.network(
                        state.imageInfo.url,
                        fit: .contain,
                        semanticLabel: 'Image',
                      ),
                    ),
                  ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withAlpha(170),
                      borderRadius: const .all(
                        .circular(5),
                      ),
                    ),
                    child: Row(
                      spacing: 1.0,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.upload),
                          color: theme.colorScheme.onSurface,
                          onPressed: _uploadImage,
                          tooltip: 'Upload an image file',
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.cloud_upload_outlined),
                        //   color: theme.colorScheme.onSurface,
                        //   onPressed: _uploadImage,
                        //   tooltip: 'Upload an image from URL',
                        // ),
                        // const SizedBox(width: 1),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: theme.colorScheme.onSurface,
                          onPressed: _deleteImage,
                          tooltip: 'Delete the image',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          },
        ),
      ),
    );
  }
}
