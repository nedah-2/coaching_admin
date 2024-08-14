import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/screen/assignments/student%20info/student_detail.dart';
import 'package:coaching_admin/utils/launch_link.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final Student student;

  const TaskCard({super.key, required this.student});

  Future<void> _callStudent(BuildContext context) async {
    makePhoneCall(context, student.phone);
  }

  Future<void> _emailStudent(BuildContext context) async {
    sendEmail(context, student.email);
  }

  @override
  Widget build(BuildContext context) {
    String meetings = student.meetings! <= 1
        ? '${student.meetings} meeting'
        : '${student.meetings} meetings';
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: Text(
                student.incompletes.toString(),
                style: const TextStyle(
                    color: Colors.deepPurple, fontWeight: FontWeight.bold),
              ),
            ),
            if (student.incompletes != null && student.incompletes! > 0)
              Positioned.fill(
                child: CircularProgressIndicator(
                  value: (student.todos! - student.incompletes!) /
                      student.todos!, // Example value for progress
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
              ),
          ],
        ),
        title: Text(student.name),
        subtitle: Text(meetings),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'Call':
                _callStudent(context);
                break;
              case 'Email':
                _emailStudent(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            return {'Call', 'Email'}.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Row(
                  children: [
                    Icon(
                      choice == 'Call' ? Icons.phone : Icons.email,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(choice),
                  ],
                ),
              );
            }).toList();
          },
          icon: const Icon(Icons.more_vert),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDetailPage(student: student),
            ),
          );
        },
      ),
    );
  }
}
