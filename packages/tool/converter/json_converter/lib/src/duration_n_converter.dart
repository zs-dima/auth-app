import 'package:json_annotation/json_annotation.dart';

class DurationNullConverter implements JsonConverter<Duration?, String?> {
  const DurationNullConverter();

  @override
  Duration? fromJson(String? json) {
    if (json == null) return null;
    final parts = json.split(':');
    final hours = int.parse(parts.first);
    final minutes = int.parse(parts[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  @override
  String? toJson(Duration? duration) {
    if (duration == null) return null;
    final hours = duration.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
