import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

// class ByteArrayFileJsonConverter implements JsonConverter<Uint8List?, MultipartFile?> {
//   const ByteArrayFileJsonConverter();

//   @override
//   Uint8List? fromJson(MultipartFile? json) => null;

//   @override
//   MultipartFile? toJson(Uint8List? bytes) =>
//       bytes == null ? null : MultipartFile.fromBytes('image', bytes, filename: 'image.png'); // TODO
// }

class ByteArrayFileJsonConverter implements JsonConverter<Uint8List?, List<int>?> {
  const ByteArrayFileJsonConverter();

  @override
  Uint8List? fromJson(List<int>? json) => json == null ? null : Uint8List.fromList(json);

  @override
  List<int>? toJson(Uint8List? object) => object?.toList();
}
