import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/models/student_search.dart';

import 'package:coaching_admin/provider/meeting_provider.dart';
import 'package:coaching_admin/screen/schedule_meeting.dart';
import 'package:coaching_admin/widgets/meeting_card.dart';
import 'package:coaching_admin/widgets/past_meeting_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeetingSchedulesPage extends StatelessWidget {
  final StudentSearchModel student;
  final int count;
  const MeetingSchedulesPage(
      {super.key, required this.student, required this.count});

  @override
  Widget build(BuildContext context) {
    final meetingProvider =
        Provider.of<MeetingProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '$count Meeting Schedules',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      body: FutureBuilder<List<Meeting>>(
        future: meetingProvider.fetchSubMeetings(student.id, 'meetings'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text('Loading...'), // Loading indicator
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'), // Error message
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No meetings yet'), // Empty state message
            );
          } else {
            List<Meeting> meetings = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                final isPastMeeting =
                    meeting.getLocalDateTime().isBefore(DateTime.now());

                if (isPastMeeting) {
                  return PastMeetingWidget(meeting: meeting);
                } else {
                  return MeetingCard(meeting: meeting);
                }
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ScheduleMeetingPage(student: student),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0.0, 1.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              reverseTransitionDuration: const Duration(milliseconds: 600),
              transitionDuration: const Duration(milliseconds: 1000),
            ),
          );
        },
        backgroundColor: Colors.blue.shade900,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
