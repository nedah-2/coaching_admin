import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/contact_provider.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/utils/launch_link.dart';
import 'package:coaching_admin/widgets/custom_snackbar.dart';
import 'package:coaching_admin/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentRegistrationPage extends StatelessWidget {
  final Student student;

  const StudentRegistrationPage({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final email = student.email;

    Future<void> deleteContact() async {
      await Provider.of<ContactProvider>(context, listen: false)
          .deleteContact(student.id!);

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        showSnackBar(context, 'A contact has been deleted!');
      }
    }

    Future<void> registerStudent() async {
      await Provider.of<StudentProvider>(context, listen: false)
          .addStudent(student)
          .then((result) async {
        await Provider.of<ContactProvider>(context, listen: false)
            .deleteMemoryContact(student.id!);
      });
      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        showSnackBar(context, 'A contact has been registered!');
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Student Registration',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showConfirmationDialog(
                  context,
                  'Delete Contact',
                  "Are you sure that you want to delete this contact?",
                  'Delete',
                  deleteContact);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                student.formattedstartDate,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade900),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                student.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                '${student.age} years',
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Icon(
                student.gender == 'Male' ? Icons.male : Icons.female,
                color: Colors.blue[900],
                size: 29,
              ),
            ),
            const Divider(height: 24, thickness: 1),
            ListTile(
              onTap: () async {
                await sendEmail(context, email);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                email,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Icon(
                Icons.email,
                color: Colors.blue[900],
              ),
            ),
            const Divider(height: 24, thickness: 1),
            ListTile(
              onTap: () async {
                await makePhoneCall(context, student.phone);
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                student.phone,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Icon(
                Icons.phone,
                color: Colors.blue[900],
              ),
            ),
            const Divider(height: 24, thickness: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(
                'Country',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                student.country,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(height: 24, thickness: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: const Text(
                'Personal Goal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                student.goal,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton(
                onPressed: () {
                  showConfirmationDialog(
                      context,
                      'Register Contact',
                      "Are you sure that you want to register this contact?",
                      'Register',
                      registerStudent);
                },
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(width: 2, color: Colors.blue.shade900)),
                child: Text(
                  'Register This Student',
                  style: TextStyle(color: Colors.blue[900], fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () async {
                  await sendEmail(context, email);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue[900],
                ),
                child: const Text(
                  'Send Email',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
