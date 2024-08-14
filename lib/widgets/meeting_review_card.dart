import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/models/student_search.dart';
import 'package:coaching_admin/provider/review_provider.dart';
import 'package:coaching_admin/screen/schedule_meeting.dart';
import 'package:coaching_admin/utils/format_date_time.dart';
import 'package:coaching_admin/widgets/confirm_dialog.dart';
import 'package:coaching_admin/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeetingReviewCard extends StatelessWidget {
  final Meeting meeting;

  const MeetingReviewCard({
    super.key,
    required this.meeting,
  });

  void _handleAction(BuildContext context, String action) {
    showConfirmationDialog(
      context,
      action,
      'Do you want to mark this meeting as $action for ${meeting.student ?? 'the student'}?',
      action,
      () async {
        // Get the ReviewProvider instance
        final reviewProvider =
            Provider.of<ReviewProvider>(context, listen: false);

        // Update the meeting status in Firestore
        try {
          await reviewProvider.updateStatus(meeting, action);
          if (context.mounted) {
            showSnackBar(context, 'Meeting marked as $action');
          }
        } catch (e) {
          if (context.mounted) {
            showSnackBar(context, 'Failed to update status: $e');
          }
        } finally {
          if (context.mounted) Navigator.pop(context);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meeting.title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "With ${meeting.student} on ${formatDate(meeting.getLocalDateTime())}",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: Colors.green.shade800, width: 1.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    // Handle "Attend" button press and update status
                    _handleAction(context, 'Attend');
                  },
                  child: Text(
                    'Attend',
                    style: TextStyle(color: Colors.green.shade800),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: Colors.yellow.shade800, width: 1.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () async {
                    // Handle "Cancel" button press and update status

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

                    if (context.mounted) {
                      showSnackBar(context, 'Meeting has been rescheduled');
                    }
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.yellow.shade800),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade800, width: 1.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    // Handle "Absent" button press and update status
                    _handleAction(context, 'Absent');
                  },
                  child: Text(
                    'Absent',
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
