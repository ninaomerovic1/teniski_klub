// date_picker.dart
import 'package:flutter/material.dart';

Future<void> selectDate(
  BuildContext context,
  Function(DateTime?) onDateSelected,
) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.orange, // header background color
            onPrimary: Colors.black, // header text color
            onSurface: Colors.black, // body text color
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange, // button text color
            ),
          ),
        ),
        child: child!,
      );
    },
  );
  onDateSelected(picked);
}
