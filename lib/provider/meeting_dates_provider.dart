import 'package:coaching_admin/models/meeting_dates.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingDatesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<int, Map<int, List<String>>> _dates = {};

  Map<int, Map<int, List<String>>> get dates => _dates;

  Future<void> fetchMeetingDates(int year) async {
    final doc =
        await _firestore.collection('meetingDates').doc(year.toString()).get();
    if (doc.exists) {
      _dates = MeetingDates.fromFirestore(doc).dates;
      notifyListeners();
    }
  }

  Future<void> addMeetingDate(int year, int month, int day, String time) async {
    final docRef = _firestore.collection('meetingDates').doc(year.toString());
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      final meetingDates = doc.exists
          ? MeetingDates.fromFirestore(doc)
          : MeetingDates(dates: {});

      final monthMap = meetingDates.dates[month] ?? {};
      final dayList = monthMap[day] ?? [];
      dayList.add(time);

      monthMap[day] = dayList;
      final newDates = {...meetingDates.dates, month: monthMap};

      transaction.set(docRef, MeetingDates(dates: newDates).toFirestore());
    });

    await fetchMeetingDates(DateTime.now().year);
  }

  Future<void> updateMeetingDate(
      int year, int month, int day, String oldTime, String newTime) async {
    final docRef = _firestore.collection('meetingDates').doc(year.toString());
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);

      final meetingDates = doc.exists
          ? MeetingDates.fromFirestore(doc)
          : MeetingDates(dates: {});

      final monthMap = meetingDates.dates[month] ?? {};
      final dayList = monthMap[day] ?? [];

      // Find the index of the old time
      final index = dayList.indexOf(oldTime);
      if (index != -1) {
        // Replace the old time with the new time
        dayList[index] = newTime;
      }

      monthMap[day] = dayList;
      final newDates = {...meetingDates.dates, month: monthMap};

      transaction.set(docRef, MeetingDates(dates: newDates).toFirestore());
    });

    await fetchMeetingDates(DateTime.now().year);
  }
}
