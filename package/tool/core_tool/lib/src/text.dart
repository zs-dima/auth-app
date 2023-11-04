import 'package:characters/characters.dart';

extension StringX on String {
  /// Returns string limited to [length] characters.
  String limit(int length) => length < this.length ? characters.getRange(0, length).toString() : this;

  /// Trims string using [pattern] from both ends.
  String trim2(String pattern) => trimStart2(pattern).trimEnd2(pattern);

  /// Trims string using [pattern] from end.
  String trimEnd2(String pattern) {
    if (isEmpty) return '';
    var i = length;
    while (startsWith(pattern, i - pattern.length)) {
      i -= pattern.length;
    }

    return characters.getRange(0, i).toString();
  }

  /// Trims string using [pattern] from start.
  String trimStart2(String pattern) {
    if (isEmpty) return '';
    var i = 0;
    while (startsWith(pattern, i)) {
      i += pattern.length;
    }

    return characters.getRange(i).toString();
  }

  /// Returns capitalized string.
  String get capitalized => isEmpty //
      ? ''
      : '${this[0].toUpperCase()}${characters.getRange(1).toLowerCase()}';

  /// Returns string with capitalized first letter of each word.
  String get titled => isEmpty //
      ? ''
      : replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.capitalized).join(' ');
}

extension StringNX on String? {
  bool get isNullOrSpace => this == null || this!.trim().isEmpty;
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  String whenEmpty(String value) => isNullOrEmpty ? value : this!;
}
