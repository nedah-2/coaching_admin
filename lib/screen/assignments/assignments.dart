import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/widgets/task/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AssignmentsPage extends StatefulWidget {
  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _loadMoreStudents();
        }
      });
  }

  Future<void> _loadMoreStudents() async {
    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    if (studentProvider.isInitialized && studentProvider.hasMoreStudents) {
      await studentProvider.fetchStudents(loadMore: true);
    }
  }

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
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: studentProvider.students.length +
              (studentProvider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == studentProvider.students.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              );
            }
            Student student = studentProvider.students[index];
            return TaskCard(student: student);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
