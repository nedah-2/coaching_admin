import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime? date) {
  if (date == null) return 'Not Set';
  return DateFormat('MMM dd, yyyy').format(date);
}

String formatTime(TimeOfDay? time) {
  if (time == null) return 'Not Set';
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

String formatTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  final format = DateFormat.jm(); // 'jm' formats to '5:08 PM'
  return format.format(dt);
}

List<String> sortMeetingTimes(List<String> times) {
  DateFormat timeFormat =
      DateFormat.jm(); // 'jm' pattern is used for '1:15 PM', '3:00 PM', etc.

  // Convert the string times to DateTime objects
  List<DateTime> dateTimeList = times.map((time) {
    return timeFormat.parse(time);
  }).toList();

  // Sort the DateTime objects
  dateTimeList.sort();

  // Convert back to the original string format
  List<String> sortedTimes = dateTimeList.map((dateTime) {
    return timeFormat.format(dateTime);
  }).toList();

  return sortedTimes;
}
