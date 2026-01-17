import 'package:flutter/material.dart';

class DropdownMenuFormFieldBase<T> extends FormField<T> {
  DropdownMenuFormFieldBase({
    super.key,
    bool enabled = true,
    double? width,
    double? menuHeight,
    Widget? leadingIcon,
    Widget? trailingIcon,
    Widget? label,
    String? hintText,
    String? helperText,
    // String? errorText,
    Widget? selectedTrailingIcon,
    bool enableFilter = false,
    bool enableSearch = true,
    TextStyle? textStyle,
    InputDecorationTheme? inputDecorationTheme,
    MenuStyle? menuStyle,
    this.controller,
    T? initialSelection,
    this.onSelected,
    bool? requestFocusOnTap,
    EdgeInsets? expandedInsets,
    required List<DropdownMenuEntry<T>> dropdownMenuEntries,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.validator,
    super.onSaved,
    SearchCallback<T>? searchCallback,
  }) : super(
         initialValue: initialSelection,
         builder: (field) {
           final state = field as _DropdownMenuFormFieldBaseState<T>;
           void onSelectedHandler(T? value) {
             field.didChange(value);
             onSelected?.call(value);
           }

           return DropdownMenu<T>(
             key: key,
             enabled: enabled,
             width: width,
             menuHeight: menuHeight,
             leadingIcon: leadingIcon,
             trailingIcon: trailingIcon,
             label: label,
             hintText: hintText,
             helperText: helperText,
             errorText: state.errorText,
             selectedTrailingIcon: selectedTrailingIcon,
             enableFilter: enableFilter,
             enableSearch: enableSearch,
             textStyle: textStyle,
             inputDecorationTheme: inputDecorationTheme,
             menuStyle: menuStyle,
             controller: controller,
             initialSelection: state.value,
             onSelected: onSelectedHandler,
             requestFocusOnTap: requestFocusOnTap,
             expandedInsets: expandedInsets,
             dropdownMenuEntries: dropdownMenuEntries,
             searchCallback: searchCallback,
           );
         },
       );

  final ValueChanged<T?>? onSelected;

  final TextEditingController? controller;

  @override
  FormFieldState<T> createState() => _DropdownMenuFormFieldBaseState<T>();
}

class _DropdownMenuFormFieldBaseState<T> extends FormFieldState<T> {
  DropdownMenuFormFieldBase<T> get _dropdownMenuFormField => widget as DropdownMenuFormFieldBase<T>;

  @override
  void didUpdateWidget(DropdownMenuFormFieldBase<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    _dropdownMenuFormField.onSelected!(value);
  }
}
