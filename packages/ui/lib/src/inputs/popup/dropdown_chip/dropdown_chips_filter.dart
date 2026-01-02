import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class DropdownChipsFilter<T> extends StatefulWidget {
  DropdownChipsFilter({
    super.key,
    required List<T> values,
    this.decoration = const InputDecoration(),
    this.style,
    this.strutStyle,
    required this.chipBuilder,
    required this.onChanged,
    this.onChipTapped,
    this.onSubmitted,
    this.onTextChanged,
    this.focusNode,
    this.intrinsicWidth = false,
    this.requestFocusOnTap = true,
    this.enabled = true,
    required this.overlayController,
    this.validator,
  }) : values = values.toSet().toList();

  final List<T> values;
  final InputDecoration decoration;
  final TextStyle? style;
  final StrutStyle? strutStyle;

  final ValueChanged<List<T>> onChanged;
  final ValueChanged<T>? onChipTapped;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onTextChanged;

  final FocusNode? focusNode;

  final Widget Function(BuildContext context, T data) chipBuilder;

  final bool intrinsicWidth;
  final bool requestFocusOnTap;
  final bool enabled;

  final OverlayPortalController overlayController;
  final FormFieldValidator<String>? validator;

  @override
  DropdownChipsFilterState<T> createState() => DropdownChipsFilterState<T>();
}

class DropdownChipsFilterState<T> extends State<DropdownChipsFilter<T>> {
  static int countReplacements(String text) =>
      text.codeUnits.where((u) => u == DropdownChipsFilterEditingController.kObjectReplacementChar).length;

  static void _handleUpKeyInvoke() {
    // print('up');
    // setState(() {
    //   if (!widget.enabled || !widget.overlayController.isShowing) {
    //     return;
    //   }
    // });
  }

  static void _handleDownKeyInvoke() {
    // print('down');
    // setState(() {
    //   if (!widget.enabled || !widget.overlayController.isShowing) {
    //     return;
    //   }
    // });
  }
  @visibleForTesting
  late final DropdownChipsFilterEditingController<T> controller;

  late final StreamController<String> _queryStreamController;

  StreamSubscription? _querySubscription;

  String _previousText = '';

  TextSelection? _previousSelection;

  @override
  void initState() {
    super.initState();

    _queryStreamController = StreamController<String>.broadcast();
    _querySubscription =
        _queryStreamController //
            .stream
            .distinct()
            .debounceTime(const Duration(milliseconds: 200))
            .listen((query) {
              widget.onTextChanged?.call(query);
            });

    controller = DropdownChipsFilterEditingController<T>(widget.values, widget.chipBuilder);
    controller.addListener(_textListener);
  }

  void _textListener() {
    final currentText = controller.text;

    if (_previousSelection != null) {
      final currentNumber = countReplacements(currentText);
      final previousNumber = countReplacements(_previousText);

      final values = widget.values;

      // If the current number and the previous number of replacements are different, then
      // the user has deleted the InputChip using the keyboard. In this case, we trigger
      // the onChanged callback. We need to be sure also that the current number of
      // replacements is different from the input chip to avoid double-deletion.
      if (currentNumber < previousNumber && currentNumber != values.length) {
        final cursorEnd = _previousSelection!.extentOffset;
        final cursorStart = _previousSelection!.baseOffset;

        if (cursorStart == cursorEnd) {
          values.removeRange(cursorStart - 1, cursorEnd);
        } else {
          if (cursorStart > cursorEnd) {
            values.removeRange(cursorEnd, cursorStart);
          } else {
            values.removeRange(cursorStart, cursorEnd);
          }
        }
        widget.onChanged(values);
        controller.updateValues(values);
      }
    }

    _previousText = currentText;
    _previousSelection = controller.selection;
  }

  bool _canRequestFocus() => widget.focusNode?.canRequestFocus ?? widget.requestFocusOnTap;
  //  ??
  // switch (Theme.of(context).platform) {
  //   .iOS || .android || .fuchsia => false,
  //   .macOS || .linux || .windows => true,
  // };

  void _handleEscapeKeyInvoke() {
    if (widget.overlayController.isShowing) {
      // currentHighlight = null;
      widget.overlayController.hide();
    }
  }

  // void _handleBackspaceKeyInvoke() {
  //   final selection = controller.selection;

  //   // If the user hasn't typed anything besides chips
  //   // or if the caret is at offset zero, remove the last chip.
  //   final noTypedText = controller.textWithoutReplacements.isEmpty;
  //   final caretAtStart = selection.baseOffset == 0 && selection.extentOffset == 0;

  //   if (noTypedText || caretAtStart) {
  //     final chips = widget.values;
  //     if (chips.isNotEmpty) {
  //       // Remove the last chip
  //       chips.removeLast();
  //       widget.onChanged(chips);
  //       setState(() {});
  //     }
  //   }
  //   // else do nothing here, so normal TextField backspacing occurs
  // }

  void _handlePressed() {
    if (widget.overlayController.isShowing) {
      // currentHighlight = null;
      widget.overlayController.hide();
    } else {
      // close to open
      if (controller.text.isNotEmpty) {
        // _enableFilter = false;
      }
      widget.overlayController.show();
    }
    // setState(() {});
  }

  @override
  void dispose() {
    _querySubscription?.cancel();
    _queryStreamController.close();

    controller
      ..removeListener(_textListener)
      ..dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(DropdownChipsFilter<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!ListEquality<T>().equals(oldWidget.values, widget.values)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.updateValues(widget.values);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MouseCursor? effectiveMouseCursor = switch (widget.enabled) {
      true => _canRequestFocus() ? SystemMouseCursors.text : SystemMouseCursors.click,
      false => null,
    };

    final textField = TextFormField(
      minLines: 1,
      maxLines: 7,
      textInputAction: .done,
      textAlignVertical: .center,
      focusNode: widget.focusNode,
      canRequestFocus: _canRequestFocus(),
      enableInteractiveSelection: _canRequestFocus(),
      style: widget.style,
      strutStyle: widget.strutStyle,
      controller: controller,
      decoration: widget.decoration,
      onChanged: (value) => _queryStreamController.add(controller.textWithoutReplacements.trim().toLowerCase()),
      onFieldSubmitted: (value) => widget.onSubmitted?.call(controller.textWithoutReplacements),
      mouseCursor: effectiveMouseCursor,
      onEditingComplete: () {
        // if (currentHighlight == null) {
        //   widget.onSelected?.call(null);
        // } else {
        //   final DropdownMenuEntry<T> entry = filteredEntries[currentHighlight!];
        //   if (entry.enabled) {
        //     controller.value = TextEditingValue(
        //       text: entry.label,
        //       selection: TextSelection.collapsed(offset: entry.label.length),
        //     );
        //     widget.onSelected?.call(entry.value);
        //   }
        // }
        // if (!widget.enableSearch) {
        //   currentHighlight = null;
        // }
        // controller.close();
      },
      onTap: widget.enabled ? _handlePressed : null,
      validator: widget.validator,
    );

    final shortcutsWidget = Shortcuts(
      shortcuts: _kMenuTraversalShortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ArrowUpIntent: CallbackAction<_ArrowUpIntent>(onInvoke: (_) => _handleUpKeyInvoke()),
          _ArrowDownIntent: CallbackAction<_ArrowDownIntent>(onInvoke: (_) => _handleDownKeyInvoke()),
          _EscapeIntent: CallbackAction<_EscapeIntent>(onInvoke: (_) => _handleEscapeKeyInvoke()),
          // _BackspaceIntent: CallbackAction<_BackspaceIntent>(
          //   onInvoke: (_) => _handleBackspaceKeyInvoke(),
          // ),
        },
        child: textField,
      ),
    );

    return widget.intrinsicWidth
        ? ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 250.0),
            child: IntrinsicWidth(child: shortcutsWidget),
          )
        : shortcutsWidget;
  }
}

class DropdownChipsFilterEditingController<T> extends TextEditingController {
  // This constant character acts as a placeholder in the TextField text value.
  // There will be one character for each of the InputChip displayed.
  static const int kObjectReplacementChar = 0xFFFE;

  DropdownChipsFilterEditingController(this.values, this.chipBuilder)
    : super(text: String.fromCharCode(kObjectReplacementChar) * values.length);

  List<T> values;

  final Widget Function(BuildContext context, T data) chipBuilder;

  String get textWithoutReplacements {
    final char = String.fromCharCode(kObjectReplacementChar);
    return text.replaceAll(RegExp(char), '');
  }

  String get textWithReplacements => text;

  /// Called whenever chip is either added or removed
  /// from the outside the context of the text field.
  void updateValues(List<T> values) {
    if (values.length == this.values.length) return;

    final char = String.fromCharCode(kObjectReplacementChar);
    final length = values.length;
    value = TextEditingValue(
      text: char * length,
      selection: TextSelection.collapsed(offset: length),
    );
    this.values = values;
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final chipWidgets = values.map((v) => WidgetSpan(child: chipBuilder(context, v)));

    return TextSpan(
      style: style?.copyWith(height: 1),
      children: <InlineSpan>[
        ...chipWidgets,
        if (textWithoutReplacements.isNotEmpty) TextSpan(text: textWithoutReplacements),
      ],
    );
  }
}

// Navigation shortcuts to move the selected menu items up or down.
final Map<ShortcutActivator, Intent> _kMenuTraversalShortcuts = <ShortcutActivator, Intent>{
  LogicalKeySet(.arrowUp): const _ArrowUpIntent(),
  LogicalKeySet(.arrowDown): const _ArrowDownIntent(),
  LogicalKeySet(.escape): const _EscapeIntent(),
  // LogicalKeySet(LogicalKeyboardKey.backspace): const _BackspaceIntent(),
};

class _ArrowUpIntent extends Intent {
  const _ArrowUpIntent();
}

class _ArrowDownIntent extends Intent {
  const _ArrowDownIntent();
}

class _EscapeIntent extends Intent {
  const _EscapeIntent();
}

// class _BackspaceIntent extends Intent {
//   const _BackspaceIntent();
// }
