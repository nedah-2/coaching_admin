import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlumniPage extends StatelessWidget {
  const AlumniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (!studentProvider.isInitialized) {
          return const Center(
            child: Text('Loading...'),
          );
        }

        if (studentProvider.alumni.isEmpty) {
          return const Center(
            child: Text('No alumni yet'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Alumni',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            centerTitle: true,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: studentProvider.alumni.length,
            itemBuilder: (context, index) {
              Student student = studentProvider.alumni[index];
              return StudentCard(student: student);
            },
          ),
        );
      },
    );
  }
}
