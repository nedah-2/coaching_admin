import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/provider/meeting_provider.dart';
import 'package:coaching_admin/widgets/meeting_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeetingsPage extends StatelessWidget {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MeetingProvider>(
      builder: (context, meetingProvider, child) {
        if (!meetingProvider.isInitialized) {
          return const Center(
            child: Text('Loading...'),
          );
        }

        if (meetingProvider.meetings.isEmpty) {
          return const Center(
            child: Text('No meetings today'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          itemCount: meetingProvider.meetings.length,
          itemBuilder: (context, index) {
            Meeting meeting = meetingProvider.meetings[index];
            return MeetingCard(meeting: meeting);
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 8);
          },
        );
      },
    );
  }
}
