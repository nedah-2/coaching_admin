import 'package:coaching_admin/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screen/assignments/student info/student_detail_id.dart';

class MeetingCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingCard({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    final isStudent = meeting.sid != null;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: isStudent
          ? () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StudentDetailWithIdPage(studentId: meeting.sid!)));
            }
          : null,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.sid == null
                    ? DateFormat('EEEE, MMM d, y')
                        .format(meeting.getLocalDateTime())
                    : 'With: ${meeting.student ?? 'Unknown'}',
                style: TextStyle(fontSize: 14.0, color: Colors.blue.shade900),
              ),
              const SizedBox(height: 6.0),
              Text(
                meeting.title,
                style: const TextStyle(
                  fontSize: 16.0,
                  //fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  const Icon(Icons.meeting_room_rounded, size: 20),
                  const SizedBox(width: 12.0),
                  Text(
                    meeting.mid,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Icon(Icons.password, size: 20),
                  const SizedBox(width: 12.0),
                  Text(
                    meeting.passcode,
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 22),
                  const SizedBox(width: 8.0),
                  Text(
                    DateFormat.jm().format(meeting.getLocalDateTime()),
                    style: const TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 32,
                    width: 80,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          side: BorderSide(
                              width: 1.5, color: Colors.blue.shade900),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                      onPressed: () {
                        // Handle change button press
                      },
                      child: Text(
                        'Change',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:coaching_admin/models/meeting.dart';
// import 'package:coaching_admin/screen/assignments/student%20info/student_detail_id.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// // Assuming 'Meeting' model class is defined as before

// class MeetingCard extends StatelessWidget {
//   final Meeting meeting;

//   const MeetingCard({super.key, required this.meeting});

//   String _formatDate(DateTime date) {
//     // Format date as "April 24, 2024 (Monday)"
//     return DateFormat('MMMM d, yyyy - EEEE ').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isStudent = meeting.student != null;

//     return InkWell(
//       borderRadius: BorderRadius.circular(8),
//       onTap: isStudent
//           ? () {
//               Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           StudentDetailWithIdPage(studentId: meeting.sid!)));
//             }
//           : null,
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//               horizontal: 16, vertical: isStudent ? 16 : 8),
//           child: SizedBox(
//             height: 180,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _formatDate(meeting.date),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w400, fontSize: 16),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   meeting.title,
//                   style: const TextStyle(
//                       fontSize: 17, fontWeight: FontWeight.w500),
//                 ),
//                 const SizedBox(height: 12),
//                 //const Spacer(),
//                 Text('Time: ${meeting.time.format(context)}'),
//                 if (isStudent) const SizedBox(height: 4),
//                 if (isStudent) Text('Student: ${meeting.student}'),
//                 const SizedBox(height: 4),
//                 Text('Meeting ID: ${meeting.mid}'),
//                 const SizedBox(height: 4),
//                 Text('Passcode: ${meeting.passcode}'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
