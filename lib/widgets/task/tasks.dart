import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/provider/task_provider.dart';
import 'package:coaching_admin/widgets/task/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Tasks extends StatelessWidget {
  final String userId;
  const Tasks({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: true);
    return FutureBuilder<void>(
      future: taskProvider.fetchTasks(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text('Loading...'), // Loading indicator
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'), // Error message
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text('No tasks assigned'), // Empty state message
          );
        } else {
          return Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              if (taskProvider.tasksByDeadline.isEmpty) {
                return const Center(
                  child: Text('No tasks assigned'), // Empty state message
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                itemCount: taskProvider.tasksByDeadline.length,
                itemBuilder: (context, index) {
                  String deadline =
                      taskProvider.tasksByDeadline.keys.elementAt(index);
                  List<Task> tasks = taskProvider.tasksByDeadline[deadline]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
                          child: Text(
                            'Deadline: $deadline',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                        ...tasks.map((task) {
                          return TaskCard(task: task);
                        }),
                      ],
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}



// import 'package:coaching_admin/models/task.dart';
// import 'package:coaching_admin/provider/task_provider.dart';
// import 'package:coaching_admin/widgets/task/task_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Tasks extends StatelessWidget {
//   final String userId;
//   const Tasks({super.key, required this.userId});

//   @override
//   Widget build(BuildContext context) {
//     final taskProvider = Provider.of<TaskProvider>(context, listen: false);
//     return FutureBuilder(
//       future: taskProvider.fetchTasks(userId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: Text('Loading...'), // Loading indicator
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error: ${snapshot.error}'), // Error message
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text('No tasks assignment'), // Empty state message
//           );
//         } else {
//           Map<String, List<Task>> tasksByDeadline = snapshot.data!;

//           return ListView.builder(
//             shrinkWrap: true,
//             padding: const EdgeInsets.only(bottom: 24, top: 8),
//             itemCount: tasksByDeadline.length,
//             itemBuilder: (context, index) {
//               String deadline = tasksByDeadline.keys.elementAt(index);
//               List<Task> tasks = tasksByDeadline[deadline]!;

//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 24.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
//                       child: Text(
//                         'Deadline: $deadline',
//                         style: const TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w400,
//                             fontStyle: FontStyle.italic),
//                       ),
//                     ),
//                     ...tasks.map((task) {
//                       return TaskCard(task: task);
//                     }),
//                   ],
//                 ),
//               );
//             },
//           );
//         }
      
//       },
//     );
//   }
// }

  // if (snapshot.hasError) {
        //   return Center(child: Text('Error: ${snapshot.error}'));
        // } else {
        //   return Consumer<TaskProvider>(
        //     builder: (context, taskProvider, child) {
        //       if (taskProvider.isLoading) {
        //         return const Center(child: Text('Loading...'));
        //       }

        //       if (taskProvider.tasksByDeadline.isEmpty) {
        //         return const Center(child: Text('No tasks available.'));
        //       }

        //       return ListView.builder(
        //         shrinkWrap: true,
        //         padding: const EdgeInsets.only(bottom: 24, top: 8),
        //         itemCount: taskProvider.tasksByDeadline.length,
        //         itemBuilder: (context, index) {
        //           String deadline =
        //               taskProvider.tasksByDeadline.keys.elementAt(index);
        //           List<Task> tasks = taskProvider.tasksByDeadline[deadline]!;

        //           return Padding(
        //             padding: const EdgeInsets.only(bottom: 24.0),
        //             child: Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Padding(
        //                   padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
        //                   child: Text(
        //                     'Deadline: $deadline',
        //                     style: const TextStyle(
        //                         fontSize: 17,
        //                         fontWeight: FontWeight.w400,
        //                         fontStyle: FontStyle.italic),
        //                   ),
        //                 ),
        //                 ...tasks.map((task) {
        //                   return TaskCard(task: task);
        //                 }),
        //               ],
        //             ),
        //           );
        //         },
        //       );
        //     },
        //   );
        // }