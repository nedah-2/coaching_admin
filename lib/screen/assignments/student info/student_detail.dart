import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/models/student_search.dart';

import 'package:coaching_admin/screen/assignments/meeting_schedules.dart';
import 'package:coaching_admin/screen/assignments/student%20info/student_info.dart';
import 'package:coaching_admin/screen/schedule_meeting.dart';
import 'package:coaching_admin/screen/schedule_task.dart';
import 'package:coaching_admin/widgets/task/tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class StudentDetailPage extends StatelessWidget {
  final Student student;
  const StudentDetailPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    // final meetingDatesProvider =
    //     Provider.of<MeetingDatesProvider>(context, listen: true);

    // Future<void> getMeetingDates() async {
    //   if (meetingDatesProvider.dates.isEmpty) {
    //     await meetingDatesProvider.fetchMeetingDates(DateTime.now().year);
    //   }
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body:
          //  FutureBuilder<void>(
          //     future: getMeetingDates(),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return const Center(child: Text('Loading...'));
          //       } else if (snapshot.hasError) {
          //         return const Center(child: Text('Error loading meeting dates'));
          //       } else {
          //   return
          Column(
        children: [
          ListTile(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentInfoPage(student: student)));
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: const Text('Student Infomation'),
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
                          )));
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            title: Text('${student.meetings} Meeting Schedules'),
            trailing: const Icon(Icons.chevron_right),
          ),
          Expanded(child: Tasks(userId: student.id!)),
        ],
      ),
      //   }
      // }),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        spacing: 8,
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.task),
            label: 'Add Task',
            onTap: () {
              // Handle the task addition here
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ScheduleTaskPage(
                    sid: student.id!,
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
                  reverseTransitionDuration: const Duration(milliseconds: 600),
                  transitionDuration: const Duration(milliseconds: 1000),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.event),
            label: 'Add Meeting',
            onTap: () {
              // Handle the meeting addition here
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
                  reverseTransitionDuration: const Duration(milliseconds: 600),
                  transitionDuration: const Duration(milliseconds: 1000),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
