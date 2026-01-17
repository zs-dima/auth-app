import 'package:json_annotation/json_annotation.dart';

class IntConverter implements JsonConverter<int, Object?> {
  const IntConverter();

  @override
  int fromJson(Object? value) => //
      switch (value) {
    final String text => int.tryParse(text) ?? 0,
    final num v => v.toInt(),
    _ => 0,
  };

  @override
  Object toJson(int value) => value.toString();
}
