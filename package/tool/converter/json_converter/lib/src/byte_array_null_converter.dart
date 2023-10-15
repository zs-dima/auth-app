// ignore_for_file: avoid-dynamic

import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class ByteArrayNullJsonConverter implements JsonConverter<Uint8List?, List<dynamic>> {
  const ByteArrayNullJsonConverter();

  @override
  Uint8List? fromJson(List<dynamic>? json) {
    if (json == null) return null;
    final data = json.cast<int>();
    if (data.isEmpty) return null;

    return Uint8List.fromList(data);
  }

  @override
  List<int> toJson(Uint8List? list) => list == null ? <int>[] : List<int>.from(list);
}
