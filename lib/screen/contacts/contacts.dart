import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (!studentProvider.isInitialized) {
          return const Center(
            child: Text('Loading...'),
          );
        }

        if (studentProvider.users.isEmpty) {
          return const Center(
            child: Text('No contacts available'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: studentProvider.users.length,
          itemBuilder: (context, index) {
            Student student = studentProvider.users[index];
            return StudentCard(student: student);
          },
        );
      },
    );
  }
}
