import 'package:cached_network_image/cached_network_image.dart';
import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/screen/contacts/student_registration.dart';
import 'package:flutter/material.dart';

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: student.profileUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: student.profileUrl!,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => const SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      )),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.error,
                    size: 16,
                  ),
                )
              : const Icon(Icons.person, color: Colors.grey),
        ),
        title: Text(student.name),
        subtitle: Text(student.formattedstartDate),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      StudentRegistrationPage(student: student)));
        },
      ),
    );
  }
}
