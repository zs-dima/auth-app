import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:ui/src/inputs/popup/core/dropdown_suggestion.dart';
import 'package:ui/src/inputs/popup/popup.dart';
import 'package:ui/src/utils/iterable_ex.dart';

class DropdownSuggestions<T> extends StatelessWidget {
  const DropdownSuggestions({
    super.key,
    this.autofocus = true,
    this.focusedValue,
    required this.suggestions,
    this.onSelected,
    this.loadMore,
    this.intrinsicWidth = false,
    this.addNewButton,
    this.buildSuggestion,
  });

  static const int _nextPageThreshold = 3;

  final bool autofocus;
  final T? focusedValue;
  final List<DropdownEntry<T>> suggestions;
  final ValueChanged<T>? onSelected;
  final bool intrinsicWidth;
  final VoidCallback? loadMore;
  final Widget? addNewButton;
  final Widget Function(DropdownEntry<T> suggestion)? buildSuggestion;

  @override
  Widget build(BuildContext context) => PointerInterceptor(
    child: Padding(
      padding: const .only(top: 1.0),
      child: Material(
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: .all(.circular(8.0)),
        ),
        child: suggestions.isEmpty
            ? Column(
                mainAxisSize: .min,
                children: [
                  const Padding(
                    padding: .all(16.0),
                    child: Text('No items found'),
                  ),
                  if (addNewButton != null) ...[
                    const Divider(height: 0.0),
                    SizedBox(width: .maxFinite, child: addNewButton),
                  ],
                ],
              )
            : Padding(
                padding: const .only(top: 4.0),
                child: intrinsicWidth
                    // A popup that must be as wide as its widest suggestion has no other way to
                    // ask: nothing above it knows that width. The extra layout pass is paid once,
                    // when the popup opens, over a handful of rows.
                    // layout-check: ignore intrinsic
                    ? IntrinsicWidth(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: .min,
                            children: suggestions.toIndexedList(
                              (index, suggestion) => _SuggestionTile<T>(
                                key: ValueKey<T>(suggestion.value),
                                suggestion: suggestion,
                                index: index,
                                autofocus: autofocus,
                                focusedValue: focusedValue,
                                onSelected: onSelected,
                                buildSuggestion: buildSuggestion,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: .min,
                        children: [
                          Flexible(
                            fit: .loose,
                            child: CustomScrollView(
                              // A popup sizes to its content up to the space it is allowed; that
                              // IS shrink-wrapping, and the alternative — filling the screen — is
                              // not a dropdown. Bounded by `SliverFixedExtentList` below, so the
                              // measure is arithmetic rather than a layout per row.
                              // layout-check: ignore shrink-wrap
                              shrinkWrap: true,
                              slivers: [
                                SliverFixedExtentList(
                                  itemExtent: 42.0,
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (loadMore != null && index >= suggestions.length - _nextPageThreshold) {
                                        loadMore!();
                                      }
                                      final suggestion = suggestions[index];
                                      return _SuggestionTile<T>(
                                        key: ValueKey<T>(suggestion.value),
                                        suggestion: suggestion,
                                        index: index,
                                        autofocus: autofocus,
                                        focusedValue: focusedValue,
                                        onSelected: onSelected,
                                        buildSuggestion: buildSuggestion,
                                      );
                                    },
                                    childCount: suggestions.length,
                                  ),
                                ),
                                if (loadMore != null && suggestions.length > 7)
                                  const SliverPadding(
                                    padding: .symmetric(horizontal: 2.0),
                                    sliver: SliverToBoxAdapter(
                                      child: SizedBox(
                                        width: .maxFinite,
                                        height: 6.0,
                                        child: LinearProgressIndicator(
                                          borderRadius: .all(.circular(8.0)),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (addNewButton != null) ...[
                            const Divider(height: 0.0),
                            SizedBox(
                              width: .maxFinite,
                              child: addNewButton,
                            ),
                          ],
                        ],
                      ),
              ),
      ),
    ),
  );
}

/// One row of the popup: the kit's own [DropdownSuggestion], or whatever
/// [DropdownSuggestions.buildSuggestion] returns, wrapped in an [InkWell] so it stays tappable.
///
/// A widget rather than a method returning one: a method has no element of its own, so every row
/// was rebuilt whenever the popup was and none of them could hold state. Keyed by
/// [DropdownEntry.value] — the identity this API already treats as unique (`DropdownEntryX.byValue`)
/// — so reordering the list moves elements instead of rebuilding them.
class _SuggestionTile<T> extends StatelessWidget {
  const _SuggestionTile({
    required this.suggestion,
    required this.index,
    required this.autofocus,
    required this.focusedValue,
    required this.onSelected,
    required this.buildSuggestion,
    super.key,
  });

  /// The entry this row shows.
  final DropdownEntry<T> suggestion;

  /// Its position, which decides the initial focus while nothing is selected.
  final int index;

  /// Whether the popup takes focus when it opens.
  final bool autofocus;

  /// The currently selected value, if any.
  final T? focusedValue;

  /// Called with [DropdownEntry.value] on a tap.
  final ValueChanged<T>? onSelected;

  /// The caller's own row builder; the kit's row is used when it is null.
  final Widget Function(DropdownEntry<T> suggestion)? buildSuggestion;

  @override
  Widget build(BuildContext context) {
    final build = buildSuggestion;
    if (build != null) {
      return InkWell(
        autofocus: autofocus,
        onTap: () => onSelected?.call(suggestion.value),
        child: build(suggestion),
      );
    }

    return DropdownSuggestion(
      title: suggestion.label,
      icon: suggestion.icon,
      autofocus: autofocus && focusedValue == null ? index == 0 : suggestion.value == focusedValue,
      onTap: () => onSelected?.call(suggestion.value),
    );
  }
}
