import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/widgets/task/confirm_dialog.dart';
import 'package:flutter/material.dart';

class TaskToggleButton extends StatelessWidget {
  final Task task;

  const TaskToggleButton({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ConfirmDialog(
              title: 'Mark as ${task.isDone ? 'Incomplete ' : 'Complete'}',
              content:
                  'Do you want to mark this task as ${task.isDone ? 'incomplete ' : 'complete'}?',
            );
          },
        );
      },
      icon: task.isDone ? const Icon(Icons.undo) : const Icon(Icons.check),
    );
  }
}
