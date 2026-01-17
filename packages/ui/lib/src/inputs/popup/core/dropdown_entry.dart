import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

final class DropdownEntry<T> {
  DropdownEntry(this.value, this.label, {this.icon, this.tooltip}) : labelLower = label.toLowerCase();

  DropdownEntry.value(this.value, {this.icon, this.tooltip}) : label = '$value', labelLower = '$value'.toLowerCase();
  final T value;
  final String label;
  final String labelLower;
  final IconData? icon;
  final String? tooltip;

  @override
  String toString() => '$value: $label';
}

extension DropdownEntryX<T> on Iterable<DropdownEntry<T>> {
  DropdownEntry<T> byValue(T value) => firstWhere((i) => i.value == value);
  DropdownEntry<T>? byValueOrNull(T value) => firstWhereOrNull((i) => i.value == value);
  Iterable<DropdownEntry<T>> byValues(Iterable<T> values) => where((i) => values.contains(i.value));
}

extension IterableX<T> on Iterable<T> {
  List<DropdownEntry<T>> toDropdown({IconData? Function(T item)? getIcon}) =>
      map((i) => DropdownEntry<T>(i, '$i', icon: getIcon?.call(i))).toList();
}
