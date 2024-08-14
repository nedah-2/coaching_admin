import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/meeting.dart';
import 'package:flutter/material.dart';

class ReviewProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Meeting> _unreviewedMeetings = [];
  List<Meeting> get unreviewedMeetings => _unreviewedMeetings;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ReviewProvider() {
    initialize();
  }

  Future<void> initialize() async {
    if (!_isInitialized) {
      await fetchUnreviewedMeetings();
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchUnreviewedMeetings() async {
    try {
      DateTime nowUtc = DateTime.now().toUtc();
      DateTime startOfTodayUtc =
          DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

      final snapshot = await _firestore
          .collection('meetings')
          .where('status',
              isEqualTo: null) // Query for documents where 'status' is null
          .where('dateTimeUtc',
              isLessThan: startOfTodayUtc
                  .toIso8601String()) // Fetch meetings before today
          .orderBy('dateTimeUtc') // Order by 'dateTimeUtc'
          .get();

      _unreviewedMeetings = snapshot.docs.map((doc) {
        return Meeting.fromFirestore(doc.data(), doc.id);
      }).toList();

      notifyListeners();
    } catch (e) {
      print('Error fetching unreviewed meetings: $e');
      rethrow;
    }
  }

  Future<void> updateStatus(Meeting meeting, String newStatus) async {
    try {
      if (meeting.sid != null) {
        await _firestore
            .collection('students')
            .doc(meeting.sid)
            .collection('meetings')
            .doc(meeting.id)
            .update({'status': newStatus});
      }

      await _firestore
          .collection('meetings')
          .doc(meeting.id)
          .update({'status': newStatus});

      meeting.status = newStatus;
      _unreviewedMeetings.removeWhere((m) => m.id == meeting.id);

      notifyListeners();
    } catch (e) {
      print('Error updating meeting status: $e');
      rethrow;
    }
  }
}
