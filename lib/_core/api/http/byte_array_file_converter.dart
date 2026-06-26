import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class ByteArrayFileJsonConverter implements JsonConverter<Uint8List?, List<int>?> {
  const ByteArrayFileJsonConverter();

  @override
  Uint8List? fromJson(List<int>? json) => json == null ? null : .fromList(json);

  @override
  List<int>? toJson(Uint8List? object) => object?.toList();
}
