import 'dart:async';

import 'package:collection/collection.dart';
import 'package:control/control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ui/src/inputs/form/chip_field.dart';
import 'package:ui/src/inputs/popup/core/dropdown_entry.dart';
import 'package:ui/src/inputs/popup/core/dropdown_suggestions.dart';
import 'package:ui/src/inputs/popup/dropdown_chip/dropdown_chip.dart';
import 'package:ui/src/inputs/popup/dropdown_chip/dropdown_chip_controller.dart';
import 'package:ui/src/inputs/popup/dropdown_chip/dropdown_chips_filter.dart';
import 'package:ui/src/inputs/popup/popup_builder.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';
import 'package:ui/src/inputs/widget/label_widget.dart';
import 'package:ui/src/widgets/case_wrap_widget.dart';

typedef ChipSelectorAddNewCallback<T> = Future<T?> Function(String name);

class DropdownChips<T> extends StatefulWidget {
  const DropdownChips(
    this.largeScreen, {
    super.key,
    this.title,
    this.icon,
    this.suffixIcon,
    required this.suggestions,
    required this.values,
    this.constValues = const [],
    this.exclude,
    this.validator,
    this.textToChipValues,
    required this.onSelected,
    this.intrinsicChip = false,
    this.intrinsicPopup = false,
    this.popupMaxWidth = 370,
    this.requestFocusOnTap = true,
    this.enabled = true,
    this.query,
    this.loadMore,
    this.onAddNew,
    this.decoration,
    this.chipSide,
    this.onPopupVisibilityChanged,
    this.buildSuggestion,
  });

  const DropdownChips.large({
    super.key,
    this.title,
    this.icon,
    this.suffixIcon,
    required this.suggestions,
    required this.values,
    this.constValues = const [],
    this.exclude,
    this.validator,
    this.textToChipValues,
    required this.onSelected,
    this.intrinsicChip = false,
    this.intrinsicPopup = false,
    this.popupMaxWidth = 370,
    this.requestFocusOnTap = true,
    this.enabled = true,
    this.query,
    this.loadMore,
    this.onAddNew,
    this.decoration,
    this.chipSide,
    this.onPopupVisibilityChanged,
    this.buildSuggestion,
  }) : largeScreen = true;

  final bool largeScreen;

  final String? title;
  final Widget? icon;
  final Widget? suffixIcon;
  final InputDecoration? decoration;
  final BorderSide? chipSide;

  final List<DropdownEntry<T>> suggestions;
  final FormFieldValidator<String>? validator;
  final List<T> Function(String text)? textToChipValues;
  final ChipValueChanged<T>? onSelected;
  final List<T> values;
  final List<T> constValues;
  final Iterable<T> Function()? exclude;

  final void Function(String query)? query;
  final VoidCallback? loadMore;

  final bool intrinsicChip;
  final bool intrinsicPopup;
  final double popupMaxWidth;
  final bool requestFocusOnTap;
  final bool enabled;

  final ChipSelectorAddNewCallback<T>? onAddNew;
  final ValueChanged<bool>? onPopupVisibilityChanged;

  final Widget Function(DropdownEntry<T> suggestion)? buildSuggestion;

  @override
  State createState() => DropdownChipsState<T>();
}

class DropdownChipsState<T> extends State<DropdownChips<T>> {
  late DropdownChipController<T> _chipsController;
  late OverlayPortalController _overlayController;
  final FocusNode _chipFocusNode = FocusNode();
  final _textChangeSubject = BehaviorSubject<String>();

  late final StreamSubscription<String> _debounceSubscription;

  late Map<T, DropdownEntry<T>> _suggestionsByValue;

  @override
  void initState() {
    super.initState();

    _updateSuggestionsMap();

    // Listen to the subject's stream with a 300ms debounce
    _debounceSubscription = _textChangeSubject.debounceTime(const Duration(milliseconds: 300)).listen(_onSearchChanged);

    _chipsController = DropdownChipController<T>(
      allSuggestions: widget
          .suggestions //
          .where((i) => !widget.constValues.contains(i.value))
          .toList(),
      values: widget.values.toSet(),
      exclude: widget.exclude,
    );
    _overlayController = OverlayPortalController(debugLabel: 'DropdownChips');

    // _chipFocusNode.addListener(() {
    //   if (!_chipFocusNode.hasFocus || _overlayController.isShowing) return;
    //   _chipsController.refresh();
    //   _overlayController.show();
    // });
  }

  void _notifyPopup(bool open) => widget.onPopupVisibilityChanged?.call(open);

  void _showPopup() {
    if (_overlayController.isShowing) return;
    _overlayController.show();
    _notifyPopup(true);
  }

  void _hidePopup() {
    if (!_overlayController.isShowing) return;
    _overlayController.hide();
    _notifyPopup(false);
  }

  void _updateSuggestionsMap() {
    _suggestionsByValue = {
      for (final entry in widget.suggestions) entry.value: entry,
    };
  }

  void _addValues(List<T> values) {
    final uniqueValues = values.where((v) => !_getValues.contains(v)).toList();
    if (uniqueValues.isEmpty) return;

    // 1. update local selection
    _chipsController.selected(uniqueValues.toSet());

    // 2. notify the outside world (this calls _placesController.add)
    widget.onSelected?.call(uniqueValues, true);

    // clear local search – keep external suggestions intact
    // _chipsController.query('');
    Future.microtask(() => (widget.query ?? _chipsController.query)(''));
  }

  void _removeValues(List<T> values) {
    _chipsController.unselected(values.toSet());

    widget.onSelected?.call(values, false);
  }

  Future<void> _setValues(List<T> data) async {
    final uniqueData = data.toSet().toList();
    final values = _getValues;
    final toRemove = values.where((i) => !uniqueData.contains(i)).toList();
    final toAdd = uniqueData.where((i) => !values.contains(i)).toList();

    if (toRemove.isNotEmpty) _removeValues(toRemove);
    if (toAdd.isNotEmpty) _addValues(toAdd);
  }

  void _onSearchChanged(String query) {
    (widget.query ?? _chipsController.query)(query);

    if (query.isNotEmpty) {
      _showPopup();
    } else {
      _hidePopup();
    }
  }

  Widget _chipBuilder(BuildContext context, T value) {
    final chip = _suggestionsByValue[value];
    if (chip == null) {
      if (widget.suggestions.isNotEmpty) debugPrint('DropdownChips _chipBuilder value missing: $value');
      return const SizedBox();
    }

    final isConst = widget.constValues.contains(value);

    return DropdownChip<T>(
      chip,
      icon: chip.icon,
      onDeleted: isConst ? null : _onChipDeleted,
      onSelected: _onChipTapped,
      side: widget.chipSide,
      tooltip: chip.tooltip,
    );
  }

  void _selectSuggestion(T value) {
    _addValues([value]);
    // _hidePopup();
  }

  void _onChipTapped(T value) {}

  void _onChipDeleted(T value) {
    _removeValues([value]);
    _hidePopup();
  }

  void _onSubmitted(String text) {
    final txt = text.trim().toLowerCase();
    if (txt.isEmpty) return;

    final values = _getValues;
    if (widget.textToChipValues != null) {
      final value = widget.textToChipValues!(txt);
      if (value.isNotEmpty) _addValues(value);
      return;
    }

    final value = widget
        .suggestions //
        .where((v) => !values.contains(v))
        .firstWhereOrNull((i) => i.toString().toLowerCase() == txt)
        ?.value;
    if (value != null) _addValues([value]);
  }

  @override
  void didUpdateWidget(covariant DropdownChips<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final suggestionsEquals = listEquals(
      oldWidget.suggestions,
      widget.suggestions,
    );
    if (!suggestionsEquals) _updateSuggestionsMap();

    if (!listEquals(oldWidget.values, widget.values) ||
        !listEquals(oldWidget.constValues, widget.constValues) ||
        !suggestionsEquals) {
      _chipsController.initialize(
        allSuggestions: widget
            .suggestions //
            .where((i) => !widget.constValues.contains(i.value))
            .toList(),
        values: widget.values.toSet(),
      );
    }
  }

  @override
  void dispose() {
    _debounceSubscription.cancel();
    _textChangeSubject.close();
    _chipFocusNode.dispose();
    _chipsController.dispose();
    super.dispose();
  }

  List<T> get _getValues => _chipsController.state.selected.toList();

  @override
  Widget build(BuildContext context) => CaseWrapWidget(
    getWrapper: widget.largeScreen
        ? (child) => LabelWidget(
            label: widget.title ?? widget.decoration?.labelText ?? '',
            child: child,
          )
        : null,
    child: PopupBuilder(
      controller: _overlayController,
      followerAnchor: Alignment.topLeft,
      targetAnchor: Alignment.bottomLeft,
      targetBuilder: (context, controller) => TapRegion(
        debugLabel: 'PopupDropdown',
        groupId: controller,
        child: StateConsumer<DropdownChipController<T>, DropdownChipState<T>>(
          controller: _chipsController,
          buildWhen: (previous, current) => !SetEquality<T>().equals(previous.selected, current.selected),
          builder: (context, chipsState, _) => DropdownChipsFilter<T>(
            // key: _fieldKey,
            focusNode: _chipFocusNode,
            intrinsicWidth: widget.intrinsicChip,
            values: [...widget.constValues, ...chipsState.selected],
            decoration: widget.largeScreen
                ? (widget.decoration ?? const InputDecoration())
                      .applyDefaults(InputDecorations.flatTheme)
                      .copyWith(labelText: '')
                : (widget.decoration ?? const InputDecoration()).copyWith(
                    labelText: widget.title,
                    prefixIcon: widget.icon,
                    suffixIcon:
                        widget.suffixIcon ??
                        SizedBox(
                          width: 66,
                          height: 30,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              if (chipsState.selected.isEmpty)
                                const SizedBox(width: 30)
                              else
                                SizedBox.square(
                                  dimension: 30,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      HapticFeedback.mediumImpact().ignore();
                                      _chipFocusNode.unfocus();
                                      _removeValues(chipsState.selected.toList());
                                    },
                                    icon: const Icon(Icons.clear, size: 18),
                                  ),
                                ),
                              SizedBox.square(
                                dimension: 30,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 14,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact().ignore();
                                    if (_overlayController.isShowing) {
                                      _hidePopup();
                                    } else {
                                      _chipsController.refresh();
                                      _showPopup();
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                  ),
            strutStyle: const StrutStyle(fontSize: 15),
            onChanged: _setValues,
            onSubmitted: _onSubmitted,
            chipBuilder: _chipBuilder,
            onTextChanged: _textChangeSubject.add,
            requestFocusOnTap: widget.requestFocusOnTap,
            enabled: widget.enabled,
            overlayController: _overlayController,
            validator: widget.validator,
          ),
        ),
      ),
      followerBuilder: (context, controller) => PopupFollower(
        // autofocus: false,
        onDismiss: controller.hide,
        tapRegionGroupId: controller,
        constraints: widget.intrinsicPopup
            ? const BoxConstraints()
            : BoxConstraints(
                maxHeight: 300,
                maxWidth: widget.popupMaxWidth,
              ),
        child: StateConsumer<DropdownChipController<T>, DropdownChipState<T>>(
          controller: _chipsController,
          buildWhen: (previous, current) => !IterableEquality<DropdownEntry<T>>().equals(
            previous.suggestions,
            current.suggestions,
          ),
          builder: (context, chipsState, _) => DropdownSuggestions<T>(
            autofocus: false,
            suggestions: chipsState.suggestions.toList(), // TODO as List
            onSelected: _selectSuggestion,
            intrinsicWidth: widget.intrinsicPopup,
            loadMore: widget.loadMore,
            buildSuggestion: widget.buildSuggestion,
            addNewButton: widget.onAddNew == null
                ? null
                : TextButton.icon(
                    icon: const Icon(Icons.add),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(8),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      HapticFeedback.mediumImpact().ignore();
                      _hidePopup();

                      final selected = await widget.onAddNew!(
                        _chipsController.state.query,
                      );
                      if (selected != null) _addValues([selected]);

                      _chipFocusNode.requestFocus();
                    },
                    label: const Text('Add new'),
                  ),
          ),
        ),
      ),
    ),
  );
}
