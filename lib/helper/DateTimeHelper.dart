import 'package:flutter/material.dart';

class DateTimeHelper {
  static DateTime get now => DateTime.now();
  // Method to pick a date
  static Future<DateTime?> pickDate(
      BuildContext context, DateTime initialDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    return pickedDate;
  }

  // Method to format a DateTime object into a string
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
