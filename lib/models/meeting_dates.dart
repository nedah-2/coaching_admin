import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingDates {
  final Map<int, Map<int, List<String>>> dates; // month -> day -> list of times

  MeetingDates({required this.dates});

  factory MeetingDates.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dates = <int, Map<int, List<String>>>{};

    for (var entry in data.entries) {
      final month = int.parse(entry.key);
      final dayMap = entry.value as Map<String, dynamic>;
      final dayMapInt = <int, List<String>>{};

      for (var dayEntry in dayMap.entries) {
        final day = int.parse(dayEntry.key);
        dayMapInt[day] = List<String>.from(dayEntry.value);
      }

      dates[month] = dayMapInt;
    }

    return MeetingDates(dates: dates);
  }

  Map<String, dynamic> toFirestore() {
    final data = <String, dynamic>{};

    dates.forEach((month, dayMap) {
      final dayMapData = <String, dynamic>{};

      dayMap.forEach((day, times) {
        dayMapData[day.toString()] = times;
      });

      data[month.toString()] = dayMapData;
    });

    return data;
  }
}
