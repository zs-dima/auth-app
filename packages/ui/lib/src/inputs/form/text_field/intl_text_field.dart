import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';
import 'package:ui/src/inputs/widget/label_widget.dart';
import 'package:ui/src/widgets/case_wrap_widget.dart';

class IntlTextField extends StatelessWidget {
  const IntlTextField(
    this.largeScreen, {
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.label,
    required this.format,
    this.hint,
    // this.multiline = false,
    this.expands = false,
    this.floatingLabelBehavior,
    this.textInputAction,
    this.focusNode,
    // this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.autofillHints,
    this.autocorrect = false,
    this.border,
    this.decoration,
  });

  const IntlTextField.large({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.label,
    required this.format,
    this.hint,
    // this.multiline = false,
    this.expands = false,
    this.floatingLabelBehavior,
    this.textInputAction,
    this.focusNode,
    // this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.autofillHints,
    this.autocorrect = false,
    this.border,
    this.decoration,
  }) : largeScreen = true;

  const IntlTextField.small({
    super.key,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.enabled = true,
    this.label,
    required this.format,
    this.hint,
    // this.multiline = false,
    this.expands = false,
    this.floatingLabelBehavior,
    this.textInputAction,
    this.focusNode,
    // this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.autofillHints,
    this.autocorrect = false,
    this.border,
    this.decoration,
  }) : largeScreen = false;

  final bool largeScreen;

  final String? label;
  final NumberFormat format;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final bool autocorrect;
  final bool enabled;

  final InputBorder? border;
  final String? hint;
  // final bool multiline;
  final bool expands;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  // final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final Iterable<String>? autofillHints;

  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final decimalDigits = (format.decimalDigits ?? 0) > 0;

    return CaseWrapWidget(
      getWrapper: largeScreen
          ? (child) => LabelWidget(
              label: label ?? decoration?.labelText ?? '',
              child: child,
            )
          : null,
      child: TextFormField(
        decoration: largeScreen
            ? (decoration ?? const InputDecoration())
                  .applyDefaults(InputDecorations.flatTheme)
                  .copyWith(
                    labelText: '',
                    prefixText: format.currencySymbol == 'USD' ? null : format.currencySymbol,
                    floatingLabelBehavior: floatingLabelBehavior,
                    hintText: hint,
                    prefixIcon: prefixIcon,
                    suffixIcon: suffixIcon,
                    suffixText: suffixText,
                    border: border,
                  )
            : (decoration ??
                  InputDecoration(
                    labelText: label,
                    prefixText: format.currencySymbol == 'USD' ? null : format.currencySymbol,
                    // contentPadding: const EdgeInsets.fromLTRB(16.0, 8.0, 4.0, 8.0),
                    // isCollapsed: false,
                    // isDense: false,
                    // filled: false,
                    floatingLabelBehavior: floatingLabelBehavior,
                    //hoverColor: colorScheme.surface,
                    hintText: hint,
                    // helperText: null,
                    prefixIcon: prefixIcon,
                    // prefixIconConstraints: const BoxConstraints.expand(width: 48.0, height: 48.0),
                    suffixIcon: suffixIcon,
                    suffixText: suffixText,
                    // suffixIconConstraints: const BoxConstraints.expand(width: 48.0, height: 48.0),
                    // counter: const SizedBox.shrink(),
                    // errorText: null,
                    // helperMaxLines: 0,
                    // errorMaxLines: 0,
                    border: border,
                  )),
        initialValue: initialValue,
        controller: controller,
        onChanged: onChanged,
        validator: validator,
        onSaved: onSaved,
        autocorrect: autocorrect,
        maxLines: null,
        // maxLines: multiline ? null : 1,
        textAlignVertical: .center,
        // textAlignVertical: multiline ? TextAlignVertical.top : null,
        keyboardType: decimalDigits ? TextInputType.numberWithOptions(decimal: decimalDigits) : .number,
        // keyboardType: widget.keyboardType ?? (widget.multiline ? TextInputType.multiline : TextInputType.text),
        inputFormatters: [
          if (decimalDigits)
            FilteringTextInputFormatter.allow(RegExp('^\\d+\\.?\\d{0,${format.decimalDigits}}'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],

        focusNode: focusNode,

        // expands: multiline && expands,
        autofillHints: autofillHints,

        textInputAction: textInputAction,
        maxLength: maxLength,
        // minLines: multiline ? minLines : null,
        enabled: enabled,
      ),
    );
  }
}
