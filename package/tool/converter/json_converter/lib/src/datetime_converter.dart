import 'package:json_annotation/json_annotation.dart';

class DateTimeJsonConverter implements JsonConverter<DateTime, int> {
  const DateTimeJsonConverter();

  @override
  int toJson(DateTime time) => time.millisecondsSinceEpoch ~/ 1000;

  @override
  DateTime fromJson(int fromSql) => DateTime.fromMillisecondsSinceEpoch(fromSql * 1000, isUtc: true);
}
