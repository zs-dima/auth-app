import 'dart:math';

import 'package:core_tool/core_tool.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// A formatter that formats user input as they type, according to a [NumberFormat].
/// This version attempts to handle:
/// - Locale-dependent decimal separators
/// - Trailing decimal symbol input
/// - Maintaining cursor position when possible
/// - Grouping symbols and partial input states
class NumberTextInputFormatter extends TextInputFormatter {
  const NumberTextInputFormatter({required NumberFormat format}) : _format = format;

  final NumberFormat _format;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // If unchanged or empty, just return as is.
    if (newValue.text.isEmpty || newValue.text == oldValue.text) return newValue;

    final decimalSymbol = _format.symbols.DECIMAL_SEP;
    final groupingSymbol = _format.symbols.GROUP_SEP;

    // Allow typing a single decimal point when decimals are allowed
    final decimalDigits = _format.decimalDigits ?? 0;
    // Check if the user is trying to type just the decimal symbol and allow it
    if (decimalDigits > 0 &&
        newValue.text.endsWith(decimalSymbol) &&
        _countOccurrences(newValue.text, decimalSymbol) == 1) {
      return newValue;
    }

    // Attempt parsing:
    // Remove trailing decimal symbol if present to allow parsing
    final candidateText = _removeTrailingDecimalIfNeeded(newValue.text, decimalSymbol);

    // Remove grouping symbols before parsing
    final withoutGrouping = candidateText.replaceAll(groupingSymbol, '');

    // Special handling for a lone minus sign (if negative allowed by format)
    if (withoutGrouping == '-') {
      // Just accept the minus sign without formatting further
      return newValue;
    }

    final parsedValue = _tryParseNumber(withoutGrouping);
    if (parsedValue == null) {
      // If we can't parse, revert to old value
      return oldValue;
    }

    // Format the parsed value according to the format
    final newFormatted = _format.format(parsedValue);

    // If formatting is identical, keep the newValue as is
    if (newFormatted == newValue.text) return newValue;

    // Attempt to preserve cursor position
    // final oldCursorPosition = oldValue.selection.baseOffset;
    final newCursorPosition = _calculateNewCursorPosition(
      oldValue: oldValue,
      newValue: newValue,
      formattedValue: newFormatted,
      decimalSymbol: decimalSymbol,
      groupingSymbol: groupingSymbol,
    );

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(
        offset: newCursorPosition,
        affinity: TextAffinity.upstream, // or downstream depending on your preference
      ),
    );
  }

  /// Tries parsing the given string with the current NumberFormat.
  /// Returns null if parsing fails.
  num? _tryParseNumber(String input) {
    try {
      return _format.parse(input);
    } catch (_) {
      return null;
    }
  }

  /// Remove a trailing decimal symbol if it exists, to allow parsing.
  /// If user only typed "123." and decimals are allowed, we keep "123." as is,
  /// but attempt parsing "123".
  static String _removeTrailingDecimalIfNeeded(String text, String decimalSymbol) =>
      text.endsWith(decimalSymbol) ? text.substring(0, text.length - decimalSymbol.length) : text;

  /// Count occurrences of a substring in a string.
  static int _countOccurrences(String input, String pattern) {
    if (pattern.isEmpty) return 0;
    var count = 0;
    var start = 0;
    while (true) {
      final index = input.indexOf(pattern, start);
      if (index == -1) break;
      count++;
      start = index + pattern.length;
    }
    return count;
  }

  /// Attempt to estimate a reasonable new cursor position after reformatting.
  static int _calculateNewCursorPosition({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
    required String formattedValue,
    required String decimalSymbol,
    required String groupingSymbol,
  }) {
    // A naive approach is to place the cursor at the end of the new formatted string.
    // But we can try better:
    //
    // We'll try to track how many characters were typed and how that maps onto the new formatting.
    // This is not perfect and may need adjustments depending on your UI/UX needs.

    // Step 1: Consider the difference in length before and after
    // final oldText = oldValue.text;
    // final newText = newValue.text;

    // Heuristic: try to keep the cursor close to the same relative position.
    // Relative position (in terms of raw typed characters) vs. formatted output might differ.
    //
    // We'll use the old cursor position relative to old text and try to map it to new formatted text.

    var relativeCursorOffset = newValue.selection.baseOffset;

    // If the newValue had a decimal typed in at the end, and formatting may remove or insert grouping
    // symbols, try to match characters from the start:
    //
    // This is complex, because formatting might insert grouping separators.
    //
    // For simplicity, let's just clamp the offset to the length of the new formatted text.
    if (relativeCursorOffset > formattedValue.length) {
      relativeCursorOffset = formattedValue.length;
    }

    return relativeCursorOffset;
  }
}

class NumberTextInputFormatter0 extends TextInputFormatter {
  const NumberTextInputFormatter0({required NumberFormat format}) : _format = format;

  final NumberFormat _format;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty || newValue.text == oldValue.text) return newValue;

    // Allow last decimal symbol
    final decimalSymbol = _format.symbols.DECIMAL_SEP;
    if ((_format.decimalDigits ?? 0) > 0 &&
        newValue.text.trim().endsWith(decimalSymbol) &&
        decimalSymbol.allMatches(newValue.text).length == 1) {
      return newValue;
    }

    final value = _format.tryParse(newValue.text.trimEnd2(decimalSymbol));
    if (value == null) return oldValue;

    final newText = _format.format(value);
    if (newText == newValue.text) return newValue;

    return TextEditingValue(
      text: _format.format(value),
      selection: TextSelection.collapsed(offset: newText.length, affinity: newValue.selection.affinity),
    );
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  CurrencyInputFormatter({required String locale, String symbol = r'$', int decimalDigits = 2})
    : currencyFormat = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: decimalDigits);

  final NumberFormat currencyFormat;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Remove all non-digit characters
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Parse the string to integer
    final value = int.parse(digitsOnly);

    // Move the decimal point left by decimalDigits
    final doubleValue = value / pow(10, currencyFormat.decimalDigits ?? 0);

    // Format the number
    final newText = currencyFormat.format(doubleValue);

    // Update the selection to the end of the text
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  const DecimalTextInputFormatter({required String locale, int decimalDigits = 2})
    : _locale = locale,
      _decimalDigits = decimalDigits;

  final String _locale;
  final int _decimalDigits;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text == oldValue.text) {
      final selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;

      final format = NumberFormat.decimalPatternDigits(locale: _locale, decimalDigits: _decimalDigits);

      // Allow last decimal symbol
      final decimalSymbol = format.symbols.DECIMAL_SEP;
      var newStringClean = newValue.text;
      final newStringDecimalStart = newStringClean.endsWith(decimalSymbol);
      if (newStringDecimalStart) {
        newStringClean = newStringClean.characters.getRange(0, newStringClean.length - 1).toString();
        if (newStringClean.contains(decimalSymbol)) return oldValue;
      }

      final number = format.parse(newStringClean);
      final newString = format.format(number) + (newStringDecimalStart ? decimalSymbol : '');

      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: newString.length - selectionIndexFromTheRight),
      );
    }

    return newValue;
  }
}

class IntTextInputFormatter extends TextInputFormatter {
  const IntTextInputFormatter({required String locale}) : _locale = locale;

  final String _locale;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text == oldValue.text) {
      final selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;

      final format = NumberFormat('#,##0', _locale);

      final number = format.parse(newValue.text);
      final newString = format.format(number);

      return TextEditingValue(
        text: newString,
        selection: TextSelection.collapsed(offset: newString.length - selectionIndexFromTheRight),
      );
    }

    return newValue;
  }
}

class PhoneTextInputFormatter extends TextInputFormatter {
  const PhoneTextInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final regEx = RegExp(
      r'^(?:\+?(61))? ?(?:\((?=.*\)))?(0?[2-57-8])\)? ?(\d\d(?:[- ](?=\d{3})|(?!\d\d[- ]?\d[- ]))\d\d[- ]?\d[- ]?\d{3})',
    );

    final newString = regEx.stringMatch(newValue.text) ?? '';

    return newString == newValue.text ? newValue : oldValue;
  }
}
