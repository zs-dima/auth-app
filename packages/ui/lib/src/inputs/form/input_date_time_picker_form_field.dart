import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ui/src/inputs/widget/input_decorations.dart';

class InputDateTimePickerFormField extends FormField<DateTime> {
  InputDateTimePickerFormField.large({
    super.key,
    DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    ValueChanged<DateTime?>? onDateTimeChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    InputDecoration decoration = InputDecorations.flat,
    String? helperText,
    // String? errorFormatText,
    // String? errorInvalidText,
    String? fieldHintText,
    // String? fieldLabelText,
    TextStyle? fieldStyle,
    // TextInputType? keyboardType,
    // TimeOfDay? initialTime,
    bool clearButton = false,
  }) : super(
         initialValue: initialDate,
         builder: (state) {
           final effectiveDecoration = decoration.applyDefaults(
             Theme.of(state.context).inputDecorationTheme,
           );

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
                 final context = state.context;
                 if (!context.mounted) return;

                 // Show time picker
                 final pickedTime = await showTimePicker(
                   context: context,
                   initialTime: TimeOfDay.fromDateTime(state.value ?? DateTime.now()),
                 );

                 if (pickedTime != null) {
                   final selectedDateTime = DateTime(
                     pickedDate.year,
                     pickedDate.month,
                     pickedDate.day,
                     pickedTime.hour,
                     pickedTime.minute,
                   );

                   state.didChange(selectedDateTime);
                   onDateTimeChanged?.call(selectedDateTime);
                 }
               }
             },
             child: InputDecorator(
               decoration: effectiveDecoration.copyWith(
                 helperText: helperText,
                 errorText: state.errorText,
                 suffixIcon: (clearButton && state.value != null)
                     ? IconButton(
                         onPressed: () {
                           state.didChange(null);
                           onDateTimeChanged?.call(null);
                         },
                         icon: const Icon(Icons.clear, size: 18.0),
                       )
                     : null,
                 // suffixIcon: const Icon(Icons.calendar_today),
               ),
               child: Text(
                 state.value == null
                     ? (fieldHintText ?? 'Select date and time')
                     : DateFormat('yyyy-MM-dd HH:mm').format(state.value!),
                 style: fieldStyle,
               ),
             ),
           );
         },
       );
}
