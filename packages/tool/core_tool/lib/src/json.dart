/// Utility class for working with JSON.
sealed class JsonTool {
  /// Extracts a value from [json] and casts it to [T].
  static T extract<T>(Map<String, Object?> json, String key, [T? fallback]) {
    if (json[key] case final T value) return value;
    if (fallback is T) return fallback;
    throw ArgumentError.value(json[key], 'value', 'is not of type $T');
  }

  /// Extracts a value from [json] and casts it to [T].
  /// Returns `null` if the value is not of type [T].
  static T? extractOrNull<T>(Map<String, Object?> json, String key) {
    if (json[key] case final T value) return value;
    return null;
  }

  /// Extracts a value from [json] and casts it to [DateTime].
  /// [String] - [DateTime] format: `yyyy-MM-ddTHH:mm:ss.SSSZ`
  /// [int] - [DateTime] format: seconds since epoch
  static DateTime? extractDateTimeOrNull(Map<String, Object?> json, String key) => switch (json[key]) {
    final String value => DateTime.tryParse(value),
    final int value => .fromMillisecondsSinceEpoch(value * 1000),
    _ => null,
  };
}

extension JsonToolX on Map<String, Object?> {
  /// Extracts a value from [this] and casts it to [T].
  T extract<T>(String key, [T? fallback]) => JsonTool.extract<T>(this, key, fallback);

  /// Extracts a value from [this] and casts it to [T].
  /// Returns `null` if the value is not of type [T].
  T? extractOrNull<T>(String key) => JsonTool.extractOrNull<T>(this, key);

  /// Extracts a value from [this] and casts it to [DateTime].
  /// [String] - [DateTime] format: `yyyy-MM-ddTHH:mm:ss.SSSZ`
  /// [int] - [DateTime] format: seconds since epoch
  DateTime? extractDateTimeOrNull(String key) => JsonTool.extractDateTimeOrNull(this, key);
}
