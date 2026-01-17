extension IterableX<T> on Iterable<T> {
  /// Maps each element of this iterable to a new value by applying [f]
  /// to the element along with its index.
  ///
  /// Example:
  /// ```dart
  /// final items = ['a', 'b', 'c'];
  /// final indexed = items.toIndexedList((index, item) => '$index-$item');
  /// // indexed = ['0-a', '1-b', '2-c']
  /// ```
  List<R> toIndexedList<R>(R Function(int index, T item) f) {
    var i = 0;
    return map((e) => f(i++, e)).toList();
  }
}
