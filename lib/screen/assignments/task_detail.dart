import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/widgets/task/resource_card.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Task Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.edit))],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              task.title,
              style:
                  const TextStyle(fontSize: 19.0, fontWeight: FontWeight.w500),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Your task is to create a compelling introduction for a Lifestyle Coaching program. Utilize the provided resources, including the article, video, and audio, to craft a concise yet engaging description that invites potential participants to join the program.',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 16.0),
          if (task.resources!.isNotEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 6),
              child: Text(
                'Resources',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
              ),
            ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: task.resources!.length,
              itemBuilder: (BuildContext context, int index) {
                final resource = task.resources![index];
                return ResourceCard(resource: resource);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 8);
              },
            ),
          ),
        ],
      ),
    );
  }
}
