// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:ui/ui.dart';

// class InputTextField extends StatefulWidget {
//   const InputTextField({
//     this.enabled = true,
//     this.controller,
//     this.label,
//     this.hint,
//     this.multiline = false,
//     this.expands = false,
//     this.floatingLabelBehavior,
//     this.keyboardType,
//     this.textInputAction,
//     this.inputFormatters,
//     this.focusNode,
//     this.minLines,
//     this.maxLength,
//     this.prefixIcon,
//     this.suffixIcon,
//     this.autofillHints,
//     this.autocorrect = true,
//     this.order,
//     this.onSubmitted,
//     super.key,
//   });

//   final bool enabled;
//   final TextEditingController? controller;
//   final String? label;
//   final String? hint;
//   final bool multiline;
//   final bool expands;
//   final FloatingLabelBehavior? floatingLabelBehavior;
//   final TextInputType? keyboardType;
//   final List<TextInputFormatter>? inputFormatters;
//   final TextInputAction? textInputAction;
//   final FocusNode? focusNode;
//   final int? minLines;
//   final int? maxLength;
//   final Widget? prefixIcon;
//   final Widget? suffixIcon;
//   final Iterable<String>? autofillHints;
//   final bool autocorrect;
//   final double? order;
//   final void Function(String text)? onSubmitted;

//   @override
//   State<InputTextField> createState() => _InputTextFieldState();
// }

// class _InputTextFieldState extends State<InputTextField> {
//   late TextEditingController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = widget.controller ?? TextEditingController();
//   }

//   @override
//   void didUpdateWidget(covariant InputTextField oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (!identical(oldWidget.controller, widget.controller)) {
//       final current = _controller;
//       if (oldWidget.controller == null) scheduleMicrotask(current.dispose);
//       _controller = widget.controller ?? TextEditingController();
//     }
//   }

//   @override
//   void dispose() {
//     if (widget.controller == null) _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => CaseWrapWidget(
//     getWrapper: switch (widget.order) {
//       final double value => (child) => FocusTraversalOrder(order: NumericFocusOrder(value), child: child),
//       null => null,
//     },
//     child: SizedBox(
//       height: widget.multiline ? null : 56,
//       child: Center(
//         child: AppTextField.titleMedium(
//           style: Theme.of(context).textTheme.bodyMedium,
//           onSubmitted: widget.onSubmitted,
//           focusNode: widget.focusNode,
//           controller: _controller,
//           maxLines: widget.multiline ? null : 1,
//           expands: widget.multiline && widget.expands,
//           autofillHints: widget.autofillHints,
//           autocorrect: widget.autocorrect,
//           keyboardType: widget.keyboardType ?? (widget.multiline ? TextInputType.multiline : TextInputType.text),
//           //style: ,
//           inputFormatters: widget.inputFormatters,
//           textInputAction: widget.textInputAction,
//           maxLength: widget.maxLength,
//           minLines: widget.multiline ? widget.minLines : null,
//           textAlignVertical: widget.multiline ? TextAlignVertical.top : null,
//           decoration: InputDecoration(
//             isCollapsed: false,
//             isDense: false,
//             filled: true,
//             floatingLabelBehavior: widget.floatingLabelBehavior,
//             contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
//             //hoverColor: colorScheme.surface,
//             labelText: widget.label,
//             hintText: widget.hint,
//             helperText: null,
//             prefixIcon: widget.prefixIcon,
//             prefixIconConstraints: const BoxConstraints.expand(width: 48, height: 48),
//             suffixIcon: widget.suffixIcon,
//             suffixIconConstraints: const BoxConstraints.expand(width: 48, height: 48),
//             counter: const SizedBox.shrink(),
//             errorText: null,
//             helperMaxLines: 0,
//             errorMaxLines: 0,
//           ),
//         ),
//       ),
//     ),
//   );
// }
