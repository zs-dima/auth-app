import 'package:json_annotation/json_annotation.dart';

class DoubleConverter implements JsonConverter<double, Object?> {
  const DoubleConverter();

  @override
  double fromJson(Object? value) => //
      switch (value) {
    final String text => double.tryParse(text) ?? 0.0,
    final num v => v.toDouble(),
    _ => 0,
  };

  @override
  Object toJson(double value) => value.toString();
}
