import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/utils/format_date_time.dart';
import 'package:flutter/material.dart';

class PastMeetingWidget extends StatelessWidget {
  final Meeting meeting;

  const PastMeetingWidget({super.key, required this.meeting});

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
}
