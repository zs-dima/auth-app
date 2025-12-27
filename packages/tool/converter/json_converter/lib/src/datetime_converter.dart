import 'dart:convert';

import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

class DateTimeJsonConverter implements JsonConverter<DateTime, int> {
  const DateTimeJsonConverter();

  @override
  int toJson(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

  @override
  DateTime fromJson(int fromSql) => DateTime.fromMillisecondsSinceEpoch(fromSql * 1000, isUtc: true);
}

/// A [Converter] that converts between a [DateTime] and a [String] in the
/// ISO 8601 format.
///
/// You should prefer using this codec instead of [DateTime.toIso8601String].
class DateTimeJsonCodec extends Codec<DateTime, String> implements JsonConverter<DateTime, String> {
  @literal
  const DateTimeJsonCodec();

  @override
  Converter<DateTime, String> get encoder => const DateTimeToJsonEncoder();

  @override
  Converter<String, DateTime> get decoder => const DateTimeFromJsonDecoder();

  @override
  String toJson(DateTime object) => encoder.convert(object);

  @override
  DateTime fromJson(String json) => decoder.convert(json);
}

/// A [DateTime] -> [String] converter.
class DateTimeToJsonEncoder extends Converter<DateTime, String> {
  @literal
  const DateTimeToJsonEncoder();

  @override
  String convert(DateTime input) => input.isUtc ? input.toUtcIso8601String() : input.toLocalIso8601String();
}

/// A [String] -> [DateTime] converter.
class DateTimeFromJsonDecoder extends Converter<String, DateTime> {
  @literal
  const DateTimeFromJsonDecoder();

  @override
  DateTime convert(String input) {
    final dateTime = DateTime.parse(input);
    return input.endsWith('Z') ? dateTime.toUtc() : dateTime.toLocal();
  }
}

/// Extension methods for the DateTime class.
extension ConverterDateTimeX on DateTime {
  static final intl.DateFormat _isoFormat = intl.DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// Returns a DateTime representation as a String in the UTC timezone.
  String toUtcIso8601String() => '${_isoFormat.format(toUtc())}Z';

  /// Returns a DateTime representation as a String in the local timezone.
  String toLocalIso8601String() {
    final dateTime = toLocal();
    final tz = dateTime.timeZoneOffset;

    final buffer =
        StringBuffer()
          ..write(_isoFormat.format(dateTime))
          ..write(tz.isNegative ? '-' : '+')
          ..write(tz.inHours.abs().toString().padLeft(2, '0'))
          ..write(':')
          ..write((tz.inMinutes.abs() % 60).toString().padLeft(2, '0'));

    return buffer.toString();
  }
}
