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

  Widget _dropdownSuggestion(DropdownEntry<T> suggestion, int index) {
    if (buildSuggestion != null)
      return InkWell(
        autofocus: autofocus,
        onTap: () => onSelected?.call(suggestion.value),
        child: buildSuggestion!(suggestion),
      );

    return DropdownSuggestion(
      key: ValueKey(suggestion.value),
      title: suggestion.label,
      icon: suggestion.icon,
      autofocus: autofocus && focusedValue == null ? index == 0 : suggestion.value == focusedValue,
      onTap: () => onSelected?.call(suggestion.value),
    );
  }

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
                    ? IntrinsicWidth(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: .min,
                            children: suggestions.toIndexedList(
                              (index, suggestion) => _dropdownSuggestion(suggestion, index),
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
                                      return _dropdownSuggestion(suggestion, index);
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
