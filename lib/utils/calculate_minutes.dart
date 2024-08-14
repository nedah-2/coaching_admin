int calculateTotalMinutes(int? hours, int? minutes) {
  int totalHours = hours ?? 0;
  int totalMinutes = minutes ?? 0;
  return (totalHours * 60) + totalMinutes;
}

Map<String, int> calculateHoursAndMinutes(int totalMinutes) {
  int hours = totalMinutes ~/ 60; // Get the number of hours
  int minutes = totalMinutes % 60; // Get the remaining minutes

  return {'hours': hours, 'minutes': minutes};
}

String formatDurationFromTotalMinutes(int totalMinutes) {
  if (totalMinutes <= 0) {
    return '3 min';
  }

  int hours = totalMinutes ~/ 60;
  int minutes = totalMinutes % 60;

  if (hours > 0) {
    if (minutes >= 30) {
      // Round up to the next hour if 30 minutes or more
      return '${hours + 1} hr';
    } else {
      // If less than 30 minutes, just show the hours
      return '$hours hr';
    }
  } else {
    return '$minutes min';
  }
}
