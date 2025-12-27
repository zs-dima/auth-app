import 'package:json_annotation/json_annotation.dart';

class TimeZoneConverter implements JsonConverter<Duration, String> {
  const TimeZoneConverter();

  @override
  Duration fromJson(String json) {
    final parts = json.split(':');
    if (parts.length != 2) return Duration.zero;

    final hours = int.parse(parts.first);
    final minutes = int.parse(parts.last);
    return Duration(hours: hours, minutes: minutes);
  }

  @override
  String toJson(Duration duration) {
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
