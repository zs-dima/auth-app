import 'package:json_annotation/json_annotation.dart';

class DoubleNullConverter implements JsonConverter<double?, Object?> {
  const DoubleNullConverter();

  @override
  double? fromJson(Object? value) => //
      switch (value) {
    final String text => double.tryParse(text),
    final num v => v.toDouble(),
    _ => null,
  };

  @override
  Object? toJson(double? value) => value?.toString();
}
