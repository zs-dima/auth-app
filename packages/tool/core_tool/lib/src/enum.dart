abstract final class EnumTool {
  static final Map<int, Map<String, Enum>> _$searchCache = {};

  static T search<T extends Enum>(Iterable<T> values, Object? /* String | int */ value, {T Function()? fallback}) {
    if (value is String) {
      final cache = _$searchCache.putIfAbsent(values.hashCode, () => {for (final e in values) e.name: e});
      if (cache[value] case final T e) return e;
    } else if (value is int) {
      try {
        return values.elementAt(value);
      } on RangeError {
        /* ignore */
      }
    }
    return fallback?.call() ?? _$searchNotFound();
  }

  static Never _$searchNotFound() => throw Exception('Not found');
}
