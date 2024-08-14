import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coaching_admin/models/student.dart';
import 'package:coaching_admin/provider/auth_provider.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/services/storage_service.dart';
import 'package:coaching_admin/utils/launch_link.dart';
import 'package:coaching_admin/widgets/confirm_dialog.dart';
import 'package:coaching_admin/widgets/custom_snackbar.dart';
import 'package:coaching_admin/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class StudentInfoPage extends StatefulWidget {
  final Student student;
  final Function(bool)? onSave;

  const StudentInfoPage({
    super.key,
    required this.student,
    this.onSave,
  });

  @override
  State<StudentInfoPage> createState() => _StudentInfoPageState();
}

class _StudentInfoPageState extends State<StudentInfoPage> {
  static StorageService storageService = StorageService();

  File? image;
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthManager>(context, listen: true);

    Future<void> deleteStudent() async {
      await Provider.of<StudentProvider>(context, listen: false)
          .deleteStudent(widget.student.id!);

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        showSnackBar(context, 'A student has been deleted!');
      }
    }

    Future<void> markAsAlumnus() async {
      Student newStudent = Student(
          id: widget.student.id,
          name: widget.student.name,
          email: widget.student.email,
          phone: widget.student.phone,
          age: widget.student.age,
          gender: widget.student.gender,
          country: widget.student.country,
          goal: widget.student.goal,
          profileUrl: widget.student.profileUrl,
          startDate: DateTime.now());

      await Provider.of<StudentProvider>(context, listen: false)
          .addAlumni(newStudent);

      if (context.mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        showSnackBar(context, 'A student has been marked as alumnus!');
      }
    }

    void showResetPasswordDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            titlePadding: const EdgeInsets.only(top: 32, left: 20),
            contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            title: const Text(
              'Password Reset',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: Text.rich(
              TextSpan(
                text: 'A password reset link has been sent to ',
                children: <TextSpan>[
                  TextSpan(
                    text: widget.student.email,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          image = File(pickedFile.path);
        });
      }
    }

    Future<void> saveImage() async {
      if (image != null) {
        String? imageUrl;
        final oldPhotoUrl = widget.student.profileUrl;
        final id = widget.student.id!;

        // Check if oldPhotoUrl is not null and not empty
        if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
          imageUrl =
              await storageService.updatePhotoFromFile(image!, id, oldPhotoUrl);
        } else {
          imageUrl = await storageService.uploadPhotoFromFile(image!, id);
        }

        // Update Firestore document only if imageUrl is not null
        if (imageUrl != null && context.mounted) {
          final StudentProvider studentProvider =
              Provider.of(context, listen: false);
          await studentProvider
              .updateStudentField(id, {'profileUrl': imageUrl});
        }
      }
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (image != null) {
          showLoading(context);
          await saveImage();
          if (context.mounted) Navigator.pop(context);
        }

        bool shouldPop = true;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Student Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showConfirmationDialog(
                    context,
                    'Delete Student',
                    "Are you sure that you want to delete this student?",
                    'Delete',
                    deleteStudent);
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      pickImage();
                    },
                    child: Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300, shape: BoxShape.circle),
                      child: image != null
                          ? Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(image!),
                                      fit: BoxFit.cover)),
                            )
                          : widget.student.profileUrl!.isEmpty
                              ? const Icon(
                                  Icons.add_a_photo,
                                  size: 36,
                                  color: Colors.black38,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.student.profileUrl!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  placeholder: (context, url) => const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3,
                                      )),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.error,
                                    size: 32,
                                  ),
                                ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Full Name',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        widget.student.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      const Text('Age',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        "${widget.student.age} years",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                ],
              ),
            ),
            ListTile(
              onTap: () async {
                await sendEmail(context, widget.student.email);
              },
              dense: true,
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 24, 8),
              title: const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                widget.student.email,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Icon(
                Icons.email,
                color: Colors.blue[900],
              ),
            ),
            ListTile(
              onTap: () async {
                await makePhoneCall(context, widget.student.phone);
              },
              dense: true,
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 24, 8),
              title: const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                widget.student.phone,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: Icon(
                Icons.phone,
                color: Colors.blue[900],
              ),
            ),
            ListTile(
              onTap: () {},
              dense: true,
              contentPadding: const EdgeInsets.fromLTRB(20, 8, 24, 8),
              title: const Text(
                'Country',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              subtitle: Text(
                widget.student.country,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 24, 2),
              child: Text('Personal Goal',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.student.goal,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () {
                  showConfirmationDialog(
                      context,
                      'Mark as Alumnus',
                      "Do you want to mark student as an alumnus?",
                      'Confirm',
                      markAsAlumnus);
                },
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    side: BorderSide(width: 2, color: Colors.blue.shade900)),
                child: Text(
                  'Mark As Alumnus',
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: auth.isLoading
                    ? () {}
                    : () async {
                        await auth.resetPassword(widget.student.email);
                        if (context.mounted) {
                          showResetPasswordDialog(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue[900],
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Reset Password',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
