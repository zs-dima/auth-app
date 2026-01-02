import 'dart:math' as math;

import 'package:intl/intl.dart' as intl;
import 'package:json_annotation/json_annotation.dart';
import 'package:json_converter/json_converter.dart';

/// A [JsonConverter] that converts between a [DateTime] and a [String] in the
/// ISO 8601 format.
///
/// Use it as an annotation, like so: `@dateTimeJsonConverter`.
const JsonConverter<DateTime, String> kDateTimeJsonConverter = DateTimeJsonCodec();

/// Extension methods for the DateTime class.
extension DateTimeX on DateTime {
  DateTime round({Duration delta = const Duration(minutes: 15)}) =>
      .fromMillisecondsSinceEpoch(millisecondsSinceEpoch - millisecondsSinceEpoch % delta.inMilliseconds);

  // ignore: avoid-duplicate-collection-elements
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

  DateTime get date => .new(year, month, day);
  Duration get time =>
      .new(hours: hour, minutes: minute, seconds: second, microseconds: microsecond, milliseconds: millisecond);

  DateTime addMonths(int value) {
    final months = value % 12;
    final yearAdd = (value - months) ~/ 12;
    var newYear = year + yearAdd;
    var newMonth = month + months;
    if (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    final newDay = math.min(day, daysInMonth(newYear, newMonth));

    return isUtc //
        ? DateTime.utc(newYear, newMonth, newDay, hour, minute, second, millisecond, microsecond)
        : DateTime(newYear, newMonth, newDay, hour, minute, second, millisecond, microsecond);
  }

  /// Format date
  String format({intl.DateFormat? format}) {
    if (format != null) return format.format(this);
    final now = DateTime.now();
    final today = now.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
    if (isAfter(today)) return intl.DateFormat.Hms().format(this);

    return isAfter(today.subtract(const Duration(days: 7)))
        ? intl.DateFormat(intl.DateFormat.WEEKDAY).format(this)
        : intl.DateFormat.yMd().format(this);
  }

  /// Returns a DateTime representation as a String in the UTC timezone.
  String toUtcIso8601String() => ConverterDateTimeX(this).toUtcIso8601String();

  /// Returns a DateTime representation as a String in the local timezone.
  String toLocalIso8601String() => ConverterDateTimeX(this).toLocalIso8601String();
}

/// Restore the [DateTime] from a JSON value.
DateTime fromJsonDateTime(Object json) =>
    fromJsonDateTimeOrNull(json) ?? (throw ArgumentError.value(json, 'json', 'Invalid DateTime value'));

/// Restore the [DateTime] from a JSON value or return `null` if the value is `null`.
DateTime? fromJsonDateTimeOrNull(Object? json) => switch (json) {
  final String s => DateTime.tryParse(s),
  null => null,
  final int ms => .fromMillisecondsSinceEpoch(ms),
  final DateTime dt => dt,
  _ => throw ArgumentError.value(json, 'json', 'Invalid DateTime value'),
};

String weekdayName(int weekday, [String? locale]) {
  final now = DateTime.now().toLocal();
  final diff = now.weekday - weekday;
  DateTime updatedDt;
  if (diff > 0) {
    updatedDt = now.subtract(Duration(days: diff));
  } else if (diff == 0) {
    updatedDt = now;
  } else {
    updatedDt = now.add(Duration(days: diff * -1));
  }
  return intl.DateFormat('EEEE', locale).format(updatedDt);
}

String weekdayWorkingName(int weekday, [String? locale]) {
  locale ??= intl.Intl.getCurrentLocale();
  final symbols = intl.DateFormat.yMd(locale).dateSymbols;

  final weekend = symbols.WEEKENDRANGE;
  final weekendEnd = weekend.last; // end of weekend (0=Mon, ..., 6=Sun)
  final firstWorkdayIndex = (weekendEnd + 1) % 7; // first working day index (0=Mon,...6=Sun)

  // 3. Calculate target day index in 0=Mon terms and convert to DateTime weekday (1–7)
  final targetIndex = (firstWorkdayIndex + weekday) % 7;
  // final targetWeekday = targetIndex + 1; // convert 0=Mon to 1=Mon for DateTime.weekday

  // 4. Pick a reference date (e.g. 2021-03-01 was a Monday) and add targetIndex days
  final baseMonday = DateTime.utc(2021, 3, 1); // This date is a Monday (weekday=1)
  final targetDate = baseMonday.add(Duration(days: targetIndex));

  // Format the date to get the localized weekday name
  return intl.DateFormat('EEEE', locale).format(targetDate);
}

extension DateTimeJsonN on DateTime {
  /// Convert a [DateTime] to a JSON value.
  String toJson() => kDateTimeJsonConverter.toJson(this);
}

extension DateTimeJsonNX on DateTime? {
  /// Convert a [DateTime] to a JSON value or return `null` if the value is `null`.
  String? toJson() => this == null ? null : kDateTimeJsonConverter.toJson(this!);
}

extension DurationX on Duration? {
  bool get isNullOrEmpty => this == null || this == .zero;

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

  String get formattedMs {
    if (this == null) return '0ms';

    final minutes = this!.inMinutes;
    final seconds = this!.inSeconds % 60;
    final milliseconds = this!.inMilliseconds % 1000;
    final microseconds = this!.inMicroseconds % 1000;

    final buffer = StringBuffer();
    if (minutes > 0) {
      buffer
        ..write(minutes)
        ..write('m ');
    }
    if (seconds > 0 && minutes == 0) {
      buffer
        ..write(seconds)
        ..write('s ');
    }
    if (milliseconds > 0 && minutes == 0 && seconds == 0) {
      buffer
        ..write(milliseconds)
        ..write('ms ');
    }
    if (microseconds > 0 && minutes == 0 && seconds == 0 && milliseconds == 0) {
      buffer
        ..write(microseconds)
        ..write('μs');
    }
    // Trimming any extra space and printing the result
    return buffer.toString().trim();
  }

  // Returns a formatted string for the given Duration [d] to be DD:HH:mm:ss and ignore if 0.
  String get formatted {
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
