import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/screen/assignments/task_detail.dart';
import 'package:coaching_admin/widgets/task/confirm_dialog.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  const TaskCard({super.key, required this.task});

  bool get isDeadlinePassed {
    return DateTime.now().isAfter(DateTime.parse(task.deadline));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      horizontalTitleGap: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(task: task),
          ),
        );
      },
      leading: isDeadlinePassed
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2)),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  )),
              onPressed: () {
                // Add any specific action if needed
              },
            )
          : Checkbox(
              activeColor: Colors.green,
              value: task.isDone,
              onChanged: (value) async {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmDialog(
                      title:
                          'Mark as ${task.isDone ? 'Incomplete' : 'Complete'}',
                      content:
                          'Do you want to mark this task as ${task.isDone ? 'incomplete' : 'complete'}?',
                    );
                  },
                );

                if (confirm != null && confirm) {
                  // Handle the checkbox change here
                }
              },
            ),
      title: Text(
        task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
