import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/models/student_search.dart';
import 'package:coaching_admin/provider/meeting_dates_provider.dart';
import 'package:coaching_admin/screen/assignments/meeting_schedules.dart';
import 'package:coaching_admin/screen/assignments/student%20info/student_info.dart';
import 'package:coaching_admin/screen/schedule_meeting.dart';
import 'package:coaching_admin/screen/schedule_task.dart';
import 'package:coaching_admin/services/firestore_service.dart';
import 'package:coaching_admin/widgets/task/tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class StudentDetailWithIdPage extends StatelessWidget {
  final String studentId;
  const StudentDetailWithIdPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final meetingDatesProvider =
        Provider.of<MeetingDatesProvider>(context, listen: true);
    Future<void> getMeetingDates() async {
      if (meetingDatesProvider.dates.isEmpty) {
        await meetingDatesProvider.fetchMeetingDates(DateTime.now().year);
      }
    }

    Future<Student?> loadStudentData() async {
      final FirestoreService firestoreService = FirestoreService();
      await getMeetingDates();
      DocumentSnapshot snapshot =
          await firestoreService.readDocument('students', studentId);

      if (snapshot.exists) {
        Map<String, dynamic> studentData =
            snapshot.data() as Map<String, dynamic>;

        return Student.fromJson(studentData, studentId);
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Student?>(
        future: loadStudentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Text('Loading...'));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final Student student = snapshot.data!;

          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentInfoPage(student: student),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: const Text('Student Information'),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MeetingSchedulesPage(
                        student: StudentSearchModel(
                            id: student.id!,
                            name: student.name,
                            email: student.email,
                            profileUrl: student.profileUrl!),
                        count: student.meetings ?? 0,
                      ),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text('${student.meetings ?? 0} Meeting Schedules'),
                trailing: const Icon(Icons.chevron_right),
              ),
              Expanded(child: Tasks(userId: studentId)),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<Student?>(
        future: loadStudentData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(); // Hide FAB if no data
          }
          final Student student = snapshot.data!;
          return SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue.shade900,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            spacing: 8,
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.task),
                label: 'Add Task (${student.todos ?? 0})',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ScheduleTaskPage(
                        sid: studentId,
                        todos: student.todos!,
                        incompletes: student.incompletes!,
                      ),
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
                      reverseTransitionDuration:
                          const Duration(milliseconds: 600),
                      transitionDuration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
              ),
              SpeedDialChild(
                child: const Icon(Icons.event),
                label: 'Add Meeting',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ScheduleMeetingPage(),
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
                      reverseTransitionDuration:
                          const Duration(milliseconds: 600),
                      transitionDuration: const Duration(milliseconds: 1000),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
