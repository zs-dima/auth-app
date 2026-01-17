import 'package:flutter/material.dart';
import 'package:ui/src/inputs/popup/popup.dart';

class DropdownPushFormField<T> extends FormField<T> {
  DropdownPushFormField.large({
    super.key,
    // String? errorText,
    this.controller,
    String? title,
    required super.initialValue,
    required List<DropdownEntry<T>> items,
    Widget? icon,
    this.onSelected,
    super.autovalidateMode = AutovalidateMode.disabled,
    super.validator,
    super.onSaved,
    bool enabled = true,
    bool intrinsicPopup = false,
    InputDecoration? decoration,
  }) : super(
         builder: (field) {
           final state = field as _PopupDropdownFormFieldState<T>;
           void onSelectedHandler(T? value) {
             field.didChange(value);
             onSelected?.call(value);
           }

           // TODO .large( .small(
           return DropdownPush<T>.large(
             key: key,
             title: title,
             errorText: state.errorText,
             value: state.value,
             items: items,
             onSelected: onSelectedHandler,
             icon: icon,
             intrinsicPopup: intrinsicPopup,
             enabled: enabled,
             decoration: decoration,
           );
         },
       );

  final ValueChanged<T?>? onSelected;

  final TextEditingController? controller;

  @override
  FormFieldState<T> createState() => _PopupDropdownFormFieldState<T>();
}

class _PopupDropdownFormFieldState<T> extends FormFieldState<T> {
  DropdownPushFormField<T> get _dropdownMenuFormField => widget as DropdownPushFormField<T>;

  @override
  void didUpdateWidget(DropdownPushFormField<T> oldWidget) {
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
