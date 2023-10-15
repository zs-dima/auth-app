import 'dart:math' as math;

extension DateTimeX on DateTime {
  DateTime round({Duration delta = const Duration(minutes: 15)}) =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch - millisecondsSinceEpoch % delta.inMilliseconds);

  static const _daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

  bool isLeapYear(int value) => value % 400 == 0 || (value % 4 == 0 && value % 100 != 0);

  int daysInMonth(int year, int month) {
    var result = _daysInMonth[month];
    if (month == 2 && isLeapYear(year)) result++;

    return result;
  }

  DateTime startOfWeek({int? startOfWeek}) {
    var diff = weekday - (startOfWeek ?? DateTime.monday);
    if (diff < 0) {
      diff += 7;
    }

    return add(Duration(days: -1 * diff)).date;
  }

  DateTime get date => DateTime(year, month, day);
  Duration get time =>
      Duration(hours: hour, minutes: minute, seconds: second, microseconds: microsecond, milliseconds: millisecond);

  DateTime addMonths(int value) {
    final r = value % 12;
    final yearAdd = (value - r) ~/ 12;
    var newYear = year + yearAdd;
    var newMonth = month + r;
    if (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    final newDay = math.min(day, daysInMonth(newYear, newMonth));

    return isUtc //
        ? DateTime.utc(newYear, newMonth, newDay, hour, minute, second, millisecond, microsecond)
        : DateTime(newYear, newMonth, newDay, hour, minute, second, millisecond, microsecond);
  }
}

extension DurationX on Duration? {
  bool get isNullOrEmpty => this == null || this == Duration.zero;

  Duration? add(Duration duration) => (isNullOrEmpty || duration.isNullOrEmpty) ? null : this! + duration;

  /// Converts the duration into a readable string
  /// 01:10
  String toHoursMinutes() {
    if (this == null) return '00:00';
    final twoDigitMinutes = _toTwoDigits(this!.inMinutes.remainder(60));

    return '${_toTwoDigits(this!.inHours)}:$twoDigitMinutes';
  }

  /// Converts the duration into a readable string
  /// 01:10:05
  String toHoursMinutesSeconds() {
    if (this == null) return '00:00:00';
    final twoDigitMinutes = _toTwoDigits(this!.inMinutes.remainder(60));
    final twoDigitSeconds = _toTwoDigits(this!.inSeconds.remainder(60));

    return '${_toTwoDigits(this!.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }

  String _toTwoDigits(int n) => (n >= 10) ? '$n' : '0$n';

  // Returns a formatted string for the given Duration [d] to be DD:HH:mm:ss and ignore if 0.
  String format() {
    var seconds = this!.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final tokens = <String>[];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}h');
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('${minutes}m');
    }
    tokens.add('${seconds}s');

    return tokens.join(':');
  }
}
