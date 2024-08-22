import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/models/student_search.dart';
import 'package:coaching_admin/screen/schedule_meeting.dart';
import 'package:coaching_admin/utils/format_date_time.dart';
import 'package:coaching_admin/utils/handle_review.dart';
import 'package:flutter/material.dart';

class PastMeetingWidget extends StatelessWidget {
  final BuildContext contex;
  final Meeting meeting;

  const PastMeetingWidget(
      {super.key, required this.contex, required this.meeting});

  @override
  Widget build(BuildContext context) {
    Icon statusIcon;
    Color statusColor;

    // Determine the icon and color based on the status
    switch (meeting.status) {
      case 'Attend':
        statusIcon = Icon(Icons.check_circle, color: Colors.green.shade800);
        statusColor = Colors.green.shade800;
        break;
      case 'Absent':
        statusIcon = Icon(Icons.cancel, color: Colors.red.shade800);
        statusColor = Colors.red.shade800;
        break;
      case 'Reschedule':
        statusIcon = Icon(
          Icons.event,
          color: Colors.yellow.shade800,
        );
        statusColor = Colors.yellow.shade800;
        break;
      default:
        statusIcon = const Icon(Icons.access_time, color: Colors.grey);
        statusColor = Colors.grey;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: () {
          _showStatusOptions(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          meeting.title,
        ),
        subtitle: Text(formatDate(meeting.getLocalDateTime())),
        trailing: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6)),
            child: statusIcon),
      ),
    );
  }

  void _showStatusOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green.shade800),
                title: const Text('Attend'),
                onTap: () {
                  // Update the meeting status to 'Attend'
                  Navigator.pop(context);
                  handleAction(contex, 'Attend', meeting);
                },
              ),
              ListTile(
                leading: Icon(Icons.event, color: Colors.yellow.shade800),
                title: const Text('Reschedule'),
                onTap: () async {
                  // Update the meeting status to 'Reschedule'
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ScheduleMeetingPage(
                        student: StudentSearchModel(
                            id: meeting.sid!,
                            name: meeting.student!,
                            email: '',
                            profileUrl: ''),
                        meeting: meeting,
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
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red.shade800),
                title: const Text('Absent'),
                onTap: () {
                  // Update the meeting status to 'Absent'
                  Navigator.pop(context);
                  handleAction(contex, 'Absent', meeting);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
