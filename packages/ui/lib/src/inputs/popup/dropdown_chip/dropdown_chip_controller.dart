// ignore_for_file: unused_element

import 'package:collection/collection.dart';
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ui/src/inputs/popup/core/dropdown_entry.dart';

@immutable
/// State for DropdownChipController, holding suggestions, selected values, and the current query.
class DropdownChipState<T> {
  const DropdownChipState(
    this.suggestions, {
    this.selected = const {},
    this.query = '',
  });

  /// The current list of suggestions.
  final Iterable<DropdownEntry<T>> suggestions;

  /// The currently selected values.
  final Set<T> selected;

  /// The current search query.
  final String query;

  @override
  int get hashCode => Object.hash(
    IterableEquality<DropdownEntry<T>>().hash(suggestions),
    IterableEquality<T>().hash(selected),
    query.hashCode,
  );

  /// Returns a copy of this state with optional new values.
  DropdownChipState<T> copyWith({
    Iterable<DropdownEntry<T>>? suggestions,
    Set<T>? selected,
    String? query,
  }) => DropdownChipState<T>(
    suggestions ?? this.suggestions,
    selected: selected ?? this.selected,
    query: query ?? this.query,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownChipState<T> &&
        IterableEquality<DropdownEntry<T>>().equals(
          other.suggestions,
          suggestions,
        ) &&
        IterableEquality<T>().equals(other.selected, selected) &&
        other.query == query;
  }
}

/// Controller for managing the state and logic of DropdownChips.
final class DropdownChipController<T> extends StateController<DropdownChipState<T>> with SequentialControllerHandler {
  DropdownChipController({
    required List<DropdownEntry<T>> allSuggestions,
    required Set<T> values,
    required Iterable<T> Function()? exclude,
  }) : _exclude = exclude,
       _allSuggestions = allSuggestions,
       super(
         initialState: DropdownChipState(
           allSuggestions.where((i) => !values.contains(i.value)),
           selected: values,
         ),
       );

  /// All possible suggestions.
  final List<DropdownEntry<T>> _allSuggestions;

  /// Function to provide values to exclude from suggestions.
  final Iterable<T> Function()? _exclude;

  void initialize({
    required List<DropdownEntry<T>> allSuggestions,
    required Set<T> values,
  }) => handle(
    () async {
      _allSuggestions
        ..clear()
        ..addAll(allSuggestions);
      final suggestions = _filter(state.query, values);
      setState(state.copyWith(suggestions: suggestions, selected: values));
    },
    error: (error, stackTrace) async => debugPrint('Error on initialize $error, $stackTrace'),
    name: 'initialize',
  );

  void refresh() => handle(
    () async {
      final suggestions = _filter(state.query, state.selected);
      setState(state.copyWith(suggestions: suggestions));
    },
    error: (error, stackTrace) async => debugPrint('Error on refresh $error, $stackTrace'),
    name: 'refresh',
  );

  void query(String q) => handle(
    () async {
      final query = q.toLowerCase();
      final suggestions = _filter(query, state.selected);
      setState(state.copyWith(suggestions: suggestions, query: query));
    },
    error: (error, stackTrace) async => debugPrint('Error on query $error, $stackTrace'),
    name: 'query',
  );

  void selected(Set<T> items) => handle(
    () async {
      final selected = {...state.selected, ...items};
      final suggestions = _filter(state.query, selected);
      setState(state.copyWith(suggestions: suggestions, selected: selected));
    },
    error: (error, stackTrace) async => debugPrint('Error on select $error, $stackTrace'),
    name: 'selected',
  );

  void unselected(Set<T> items) => handle(
    () async {
      final selected = {...state.selected}..removeAll(items);
      final suggestions = _filter(state.query, selected);
      setState(state.copyWith(suggestions: suggestions, selected: selected));
    },
    error: (error, stackTrace) async => debugPrint('Error on unselect $error, $stackTrace'),
    name: 'unselected',
  );

  /// Returns filtered suggestions based on the query and selected values, using cache for performance.
  List<DropdownEntry<T>> _filter(String query, Set<T> selected) {
    final excludesSet = _exclude?.call().toSet() ?? const {};
    final selectedSet = selected.toSet();

    // Early exit if query is empty and no selected/excluded items
    if (query.isEmpty && selectedSet.isEmpty && excludesSet.isEmpty) {
      return _allSuggestions;
    }

    // ignore: prefer-returning-conditional-expressions
    return _allSuggestions
        .where(
          (entry) =>
              !selectedSet.contains(entry.value) &&
              !excludesSet.contains(entry.value) &&
              entry.labelLower.contains(query),
        )
        .toList(growable: false);
  }
}
