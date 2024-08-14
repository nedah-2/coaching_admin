import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/provider/review_provider.dart'; // Replace with ReviewProvider
import 'package:coaching_admin/widgets/meeting_review_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeetingReviews extends StatelessWidget {
  const MeetingReviews({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        if (!reviewProvider.isInitialized) {
          return const Center(
            child: Text('Loading...'),
          );
        }

        if (reviewProvider.unreviewedMeetings.isEmpty) {
          return const Center(
            child: Text('No meetings to review yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 72, top: 8),
          itemCount: reviewProvider.unreviewedMeetings.length,
          itemBuilder: (context, index) {
            Meeting meeting = reviewProvider.unreviewedMeetings[index];
            return MeetingReviewCard(meeting: meeting); // Use MeetingReviewCard
          },
        );
      },
    );
  }
}
