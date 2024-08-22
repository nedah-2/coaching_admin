import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/utils/calculate_minutes.dart';
import 'package:coaching_admin/utils/launch_link.dart';
import 'package:flutter/material.dart';

class ResourceCard extends StatelessWidget {
  final Resource resource;
  final VoidCallback? onDelete; // Callback for delete action

  const ResourceCard({
    super.key,
    required this.resource,
    this.onDelete,
  });

  static const Map<String, Icon> icons = {
    'article': Icon(Icons.article, color: Colors.deepPurpleAccent),
    'video': Icon(Icons.video_file, color: Colors.deepPurpleAccent),
    'podcast': Icon(Icons.podcasts, color: Colors.deepPurpleAccent),
  };

  @override
  Widget build(BuildContext context) {
    final isEdit = onDelete != null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: isEdit
            ? const EdgeInsets.fromLTRB(16, 2, 4, 2)
            : const EdgeInsets.fromLTRB(16, 2, 16, 2),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: icons[resource.type],
        ),
        title: Text(
          resource.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(formatDurationFromTotalMinutes(resource.duration)),
        trailing: isEdit ? _buildDeleteButton() : const Icon(Icons.open_in_new),
        onTap: () {
          launchURL(context, resource.resource);
        },
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: onDelete,
    );
  }
}
