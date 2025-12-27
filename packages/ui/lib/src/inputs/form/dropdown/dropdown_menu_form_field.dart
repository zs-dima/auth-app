import 'package:flutter/material.dart';
import 'package:ui/src/inputs/form/dropdown/dropdown_menu_form_field_base.dart';
import 'package:ui/src/inputs/form/dropdown/icons/dropdown_progress_icon.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';
import 'package:ui/src/inputs/widget/label_widget.dart';
import 'package:ui/src/widgets/case_wrap_widget.dart';

class DropdownMenuFormField<T> extends StatefulWidget {
  const DropdownMenuFormField(
    this.largeScreen, {
    super.key,
    this.title,
    required this.initialSelection,
    required this.dropdownMenuEntries,
    this.validator,
    this.onSelected,
    this.onSaved,
    this.loading = false,
    this.enabled = true,
    this.controller,
    this.menuHeight,
    this.width,
    this.decoration,
  });

  const DropdownMenuFormField.large({
    super.key,
    this.title,
    required this.initialSelection,
    required this.dropdownMenuEntries,
    this.validator,
    this.onSelected,
    this.onSaved,
    this.loading = false,
    this.enabled = true,
    this.controller,
    this.menuHeight,
    this.width,
    this.decoration,
  }) : largeScreen = true;

  final bool largeScreen;

  final String? title;
  final T? initialSelection;
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final ValueChanged<T?>? onSelected;
  final FormFieldSetter<T>? onSaved;
  final FormFieldValidator<T>? validator;

  final bool loading;
  final bool enabled;
  final TextEditingController? controller;
  final double? menuHeight;
  final double? width;
  final InputDecoration? decoration;

  @override
  State<DropdownMenuFormField<T>> createState() => _DropdownMenuFormFieldState<T>();
}

class _DropdownMenuFormFieldState<T> extends State<DropdownMenuFormField<T>> {
  late TextEditingController _dropdownController;

  @override
  void initState() {
    super.initState();

    _dropdownController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _dropdownController.dispose();
    super.dispose();
  }

  // TODO https://github.com/flutter/flutter/issues/141941
  @override
  Widget build(BuildContext context) {
    // Create InputDecorationTheme from the decoration or use default
    final inputDecorationTheme = widget.largeScreen
        ? InputDecorations.flatTheme
        : (widget.decoration == null
              ? context.dependOnInheritedWidgetOfExactType<InputDecorationTheme>()
              : InputDecorationTheme(
                  // Apply the decoration settings to the theme
                  border: widget.decoration!.border,
                  enabledBorder: widget.decoration!.enabledBorder,
                  focusedBorder: widget.decoration!.focusedBorder,
                  errorBorder: widget.decoration!.errorBorder,
                  focusedErrorBorder: widget.decoration!.focusedErrorBorder,
                  disabledBorder: widget.decoration!.disabledBorder,
                  filled: widget.decoration!.filled,
                  fillColor: widget.decoration!.fillColor,
                  focusColor: widget.decoration!.focusColor,
                  hoverColor: widget.decoration!.hoverColor,
                  contentPadding: widget.decoration!.contentPadding,
                  constraints: widget.decoration!.constraints,
                  isDense: widget.decoration!.isDense,
                  alignLabelWithHint: widget.decoration!.alignLabelWithHint,
                ));

    return CaseWrapWidget(
      getWrapper: widget.largeScreen
          ? (child) => LabelWidget(
              label: widget.title ?? widget.decoration?.labelText ?? '',
              child: child,
            )
          : null,
      child: DropdownMenuFormFieldBase<T>(
        label: (widget.largeScreen || widget.title == null)
            ? null
            : Text(widget.title!, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start),
        controller: _dropdownController,
        enabled: widget.enabled,
        enableFilter: true,
        requestFocusOnTap: true,
        expandedInsets: EdgeInsets.zero,
        trailingIcon:
            widget
                .loading //
            ? const DropdownProgressIcon()
            : const Icon(Icons.arrow_drop_down, size: 14),
        selectedTrailingIcon: const RotatedBox(quarterTurns: 2, child: Icon(Icons.arrow_drop_down, size: 14)),
        // TODO https://github.com/flutter/flutter/issues/145637
        // inputDecorationTheme: Theme.of(context).inputDecorationTheme,
        inputDecorationTheme: inputDecorationTheme,
        menuHeight: widget.menuHeight,
        width: widget.width,

        initialSelection: widget.initialSelection,
        dropdownMenuEntries: widget.dropdownMenuEntries,

        onSelected: widget.onSelected,
        onSaved: widget.onSaved,

        validator: (item) {
          // TODO workaround
          final text = _dropdownController.value.text.toLowerCase();
          if (widget.dropdownMenuEntries.every((i) => i.label.toLowerCase() != text)) {
            _dropdownController.value = TextEditingValue.empty;
            return widget.validator?.call(null);
          }
          return widget.validator?.call(item);
        },

        // TODO workaround https://github.com/flutter/flutter/issues/154532
        searchCallback: (entries, query) {
          final searchText = _dropdownController.value.text.toLowerCase();
          if (searchText.isEmpty) {
            return null;
          }
          final index = entries.indexWhere((entry) => entry.label.toLowerCase().contains(searchText));

          return index == -1 ? null : index;
        },
      ),
    );
  }
}
