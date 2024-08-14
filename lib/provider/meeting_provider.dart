import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Meeting> _meetings = [];
  List<Meeting> get meetings => _meetings;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  MeetingProvider() {
    initialize();
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await fetchMeetings();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchMeetings() async {
    DateTime nowUtc = DateTime.now().toUtc();
    DateTime startOfDayUtc =
        DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 0, 0, 0);
    DateTime endOfDayUtc =
        DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day, 23, 59, 59);

    try {
      final snapshot = await _firestore
          .collection('meetings')
          .where('dateTimeUtc',
              isGreaterThanOrEqualTo: startOfDayUtc.toIso8601String())
          .where('dateTimeUtc',
              isLessThanOrEqualTo: endOfDayUtc.toIso8601String())
          .get();

      _meetings = snapshot.docs.map((doc) {
        try {
          return Meeting.fromFirestore(doc.data(), doc.id);
        } catch (e) {
          print('Error parsing meeting document ${doc.id}: $e');
          throw e;
        }
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching meetings: $e');
      rethrow;
    }
  }

  Future<List<Meeting>> fetchSubMeetings(
      String docId, String subCollectionPath) async {
    try {
      final snapshot = await _firestore
          .collection('students')
          .doc(docId)
          .collection(subCollectionPath)
          .orderBy('dateTimeUtc')
          .get();
      return snapshot.docs
          .map((doc) => Meeting.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching sub-meetings: $e');
      rethrow;
    }
  }

  Future<void> addMeeting(Meeting meeting) async {
    DateTime today = DateTime.now();
    DateFormat dateFormat = DateFormat('yyyy-MM-dd');

    try {
      // Add the meeting to the student's subcollection and get the generated doc ID
      DocumentReference docRef = await _firestore
          .collection('students')
          .doc(meeting.sid!)
          .collection('meetings')
          .add(meeting.toStudents());

      // Use the generated ID to add the meeting to the main 'meetings' collection
      await _firestore
          .collection('meetings')
          .doc(docRef.id)
          .set(meeting.toMeetings());

      // Add to local _meetings list if the meeting is for today
      if (dateFormat.format(meeting.getLocalDateTime()) ==
          dateFormat.format(today)) {
        _meetings.add(meeting);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding meeting: $e');
      rethrow;
    }
  }
}
