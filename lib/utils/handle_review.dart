import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/provider/review_provider.dart';
import 'package:coaching_admin/widgets/confirm_dialog.dart';
import 'package:coaching_admin/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void handleAction(BuildContext context, String action, Meeting meeting) {
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
          Navigator.pop(context);
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
