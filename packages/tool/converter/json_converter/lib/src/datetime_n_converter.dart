import 'package:json_annotation/json_annotation.dart';

class DateTimeNullJsonConverter implements JsonConverter<DateTime?, int> {
  const DateTimeNullJsonConverter();

  @override
  int toJson(DateTime? time) {
    if (time == null) return 0;

    return time.millisecondsSinceEpoch ~/ 1000;
  }

  @override
  DateTime? fromJson(int fromSql) {
    if (fromSql == 0) return null;

    return DateTime.fromMillisecondsSinceEpoch(fromSql * 1000, isUtc: true);
  }
}
