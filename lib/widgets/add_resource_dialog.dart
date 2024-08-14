import 'package:coaching_admin/models/task.dart';
import 'package:coaching_admin/utils/calculate_minutes.dart';
import 'package:flutter/material.dart';

class AddResourceDialog extends StatefulWidget {
  const AddResourceDialog({
    super.key,
    required this.onResourceAdded,
    required this.type,
  });

  final String type;
  final Function(Resource) onResourceAdded;

  @override
  State<AddResourceDialog> createState() => _AddResourceDialogState();
}

class _AddResourceDialogState extends State<AddResourceDialog> {
  TextEditingController linkController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  TextEditingController minutesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    linkController.dispose();
    titleController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Task Assignment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Add title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: linkController,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Paste your link here',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a link';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: hoursController,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Hours',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            int.parse(value);
                          } catch (e) {
                            return 'Invalid number format';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: minutesController,
                      decoration: const InputDecoration(
                        isDense: true,
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            int.parse(value);
                          } catch (e) {
                            return 'Invalid number format';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    String link = linkController.text.trim();
                    String title = titleController.text.trim();
                    int? hours = hoursController.text.trim().isNotEmpty
                        ? int.parse(hoursController.text.trim())
                        : null;
                    int? minutes = minutesController.text.trim().isNotEmpty
                        ? int.parse(minutesController.text.trim())
                        : null;

                    if (hours == null && minutes == null) {
                      // If neither hours nor minutes are provided, show an error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter hours, minutes, or both'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    

                    widget.onResourceAdded(Resource(
                      type: widget.type,
                      title: title,
                      duration: calculateTotalMinutes(hours, minutes),
                      resource: link,
                    ));

                    Navigator.pop(
                        context); // Close dialog after adding resource
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.blue[900],
                ),
                child: const Text(
                  'Assign This Task',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
