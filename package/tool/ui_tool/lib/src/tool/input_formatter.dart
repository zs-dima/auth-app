import 'package:characters/characters.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalTextInputFormatter extends TextInputFormatter {
  final String _locale;

  DecimalTextInputFormatter({required String locale}) : _locale = locale;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      final selectionIndexFromTheRight = newValue.text.length - newValue.selection.end;

      final format = NumberFormat.decimalPattern(_locale);

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
  final String _locale;

  IntTextInputFormatter({required String locale}) : _locale = locale;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
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
