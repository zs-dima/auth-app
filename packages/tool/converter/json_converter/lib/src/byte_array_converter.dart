import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class ByteArrayJsonConverter implements JsonConverter<Uint8List, List<Object>> {
  const ByteArrayJsonConverter();

  @override
  Uint8List fromJson(List<Object>? json) => .fromList(json == null ? <int>[] : json.cast<int>());

  @override
  List<int> toJson(Uint8List list) => List<int>.of(list);
}
