import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/widgets/task/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssignmentsPage extends StatelessWidget {
  const AssignmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (!studentProvider.isInitialized) {
          return const Center(
            child: Text('Loading...'),
          );
        }

        if (studentProvider.students.isEmpty) {
          return const Center(
            child: Text('No students available'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: studentProvider.students.length,
          itemBuilder: (context, index) {
            Student student = studentProvider.students[index];
            return TaskCard(student: student);
          },
        );
      },
    );
  }
}
