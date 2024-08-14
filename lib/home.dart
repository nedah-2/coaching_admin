import 'package:coaching_admin/provider/auth_provider.dart';

import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/provider/tab_provider.dart';
import 'package:coaching_admin/screen/alumni.dart';
import 'package:coaching_admin/screen/assignments/assignments.dart';
import 'package:coaching_admin/screen/contacts/contacts.dart';
import 'package:coaching_admin/screen/meetings/meetings.dart';
import 'package:coaching_admin/screen/reviews/reviews.dart';
import 'package:coaching_admin/screen/schedule_meeting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<Widget> _pages = [
    const ContactsPage(),
    const AssignmentsPage(),
    const MeetingsPage(),
    const MeetingReviews()
  ];

  @override
  Widget build(BuildContext context) {
    final tabIndexProvider = Provider.of<TabIndexProvider>(context);
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: true);

    // Future<void> uploadSampleData(MeetingDatesProvider provider) async {
    //   final year = 2025;
    //   final month = 2; // July

    //   // Initial sample data for July 2024
    //   final sampleData = {
    //     1: ["09:00", "14:00"], // July 1st
    //     5: ["10:00", "15:00"], // July 5th
    //     10: ["08:00", "12:00"], // July 10th
    //     15: ["09:00", "13:00"], // July 15th
    //     20: ["11:00", "16:00"], // July 20th
    //     25: ["07:00", "14:30"], // July 25th
    //     30: ["08:30", "17:00"], // July 30th
    //   };

    //   // Upload initial sample data to Firestore
    //   for (var entry in sampleData.entries) {
    //     final day = entry.key;
    //     final times = entry.value;
    //     for (var time in times) {
    //       await provider.addMeetingDate(year, month, day, time);
    //     }
    //   }
    // }

    Future<void> showLoadingDialog(BuildContext context) async {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            content: const Row(
              children: [
                SizedBox(
                    width: 28, height: 28, child: CircularProgressIndicator()),
                SizedBox(width: 24),
                Text("Signing Out..."),
              ],
            ),
          );
        },
      );

      // Delay for 2 seconds before closing the dialog
      await Future.delayed(const Duration(seconds: 2));
      if (context.mounted) Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          if (studentProvider.alumni.isNotEmpty)
            IconButton(
                onPressed: () async {
                  //await uploadSampleData(meetingDatesProvider);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlumniPage()));
                },
                icon: const Icon(Icons.group)),
          Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 4.0),
            child: IconButton(
                onPressed: () async {
                  await showLoadingDialog(context);
                  await authManager.signOut();
                },
                icon: const Icon(Icons.logout)),
          )
        ],
      ),
      body: _pages[tabIndexProvider.currentIndex],
      floatingActionButton: tabIndexProvider.currentIndex != 2
          ? null
          : FloatingActionButton(
              onPressed: () {
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
              backgroundColor: Colors.blue.shade900,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndexProvider.currentIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blue.shade900,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        onTap: (index) {
          tabIndexProvider.setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Meetings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Reviews',
          ),
        ],
      ),
    );
  }
}
