import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';

class InputDatePicker1FormField extends FormField<DateTime> {
  InputDatePicker1FormField.large({
    super.key,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    ValueChanged<DateTime?>? onDateTimeChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    InputDecoration? decoration,
    // String? errorFormatText,
    // String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    TextStyle? fieldStyle,
    // TextInputType? keyboardType,
  }) : super(
         initialValue: initialDate ?? DateTime.now(),
         builder: (state) {
           final effectiveDecoration = (decoration ?? const InputDecoration())
               .applyDefaults(InputDecorations.flatTheme)
               .copyWith(labelText: '');
           //  : (decoration ?? const InputDecoration()).applyDefaults(
           //      Theme.of(state.context).inputDecorationTheme,
           //    );

           return GestureDetector(
             onTap: () async {
               // Show date picker
               final pickedDate = await showDatePicker(
                 context: state.context,
                 initialDate: state.value ?? DateTime.now(),
                 firstDate: firstDate,
                 lastDate: lastDate,
               );

               if (pickedDate != null) {
                 final selectedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);

                 state.didChange(selectedDateTime);
                 onDateTimeChanged?.call(selectedDateTime);
               }
             },
             child: InputDecorator(
               decoration: effectiveDecoration.copyWith(
                 labelText: fieldLabelText,
                 errorText: state.errorText,
                 // suffixIcon: const Icon(Icons.calendar_today),
               ),
               child: Text(
                 state.value == null
                     ? (fieldHintText ?? 'Select date and time')
                     : DateFormat('yyyy-MM-dd').format(state.value!),
                 style: fieldStyle,
               ),
             ),
           );
         },
       );
}
