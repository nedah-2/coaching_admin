import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/provider/task_provider.dart';
import 'package:coaching_admin/utils/format_date_time.dart';
import 'package:coaching_admin/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:coaching_admin/widgets/task/resource_card.dart';
import 'package:coaching_admin/widgets/add_resource_dialog.dart';
import 'package:coaching_admin/models/task.dart';
import 'package:provider/provider.dart';

class ScheduleTaskPage extends StatefulWidget {
  final String sid;
  final int todos;
  final int incompletes;
  const ScheduleTaskPage(
      {super.key,
      required this.sid,
      required this.todos,
      required this.incompletes});

  @override
  State<ScheduleTaskPage> createState() => _ScheduleTaskPageState();
}

class _ScheduleTaskPageState extends State<ScheduleTaskPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final List<Resource> _resources = [];
  String? _title;
  String? _description;

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      helpText: 'Choose Deadline',
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _addResource(Resource resource) {
    setState(() {
      _resources.add(resource);
    });
  }

  void _deleteResource(int index) {
    setState(() {
      _resources.removeAt(index);
    });
  }

  Future<void> _saveTask() async {
    final form = _formKey.currentState;
    if (form != null && form.validate()) {
      form.save();

      if (_selectedDate == null) {
        _selectDate(); // Prompt the user to select a date
        return;
      }

      if (_resources.isEmpty) {
        bool? confirmNoResources = await showDialog(
          context: context,
          // barrierDismissible: false,
          builder: (BuildContext context) => AlertDialog(
            insetPadding: const EdgeInsets.all(32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            titlePadding: const EdgeInsets.only(left: 24, top: 32),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            title: const Text(
              'No Resources Added',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            content: const Text(
                'Are you sure you want to save without adding any resources?'),
            actionsOverflowDirection: VerticalDirection.up,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Add Resources"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Save Without Resources'),
              ),
            ],
          ),
        );

        if (confirmNoResources == null || !confirmNoResources) {
          return;
        }
      }

      if (mounted) showLoading(context);

      // Create the Task object
      Task newTask = Task(
        title: _title!,
        description: _description!,
        deadline: _selectedDate!.toIso8601String(),
        isDone: false,
        resources: _resources,
      );

      if (mounted) {
        // Use the provider to add the task
        final sid = widget.sid;
        final taskProvider = Provider.of<TaskProvider>(context, listen: false);
        final studentProvider =
            Provider.of<StudentProvider>(context, listen: false);
        await taskProvider.addTask(sid, newTask);
        await studentProvider.updateStudentField(sid,
            {'todos': widget.todos + 1, 'incompletes': widget.incompletes + 1});
      }

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // Close the page after saving
      }
    }
  }

  Widget _buildDeadlineField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Deadline :  ',
              style: TextStyle(fontSize: 16),
            ),
            Expanded(
              child: Text(
                formatDate(_selectedDate),
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedDate == null ? Colors.grey : Colors.black,
                  fontWeight: _selectedDate == null
                      ? FontWeight.normal
                      : FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _selectDate,
              child: Text(
                _selectedDate == null ? 'Select' : 'Edit',
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Close action
          },
        ),
        title: const Text(
          'Task Assignment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTask, // Save action
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _titleFocusNode.unfocus();
          _descriptionFocusNode.unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDeadlineField(),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: _titleFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Add Title',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) {
                      _title = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    focusNode: _descriptionFocusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Add Description',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (value) {
                      _description = value!;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_resources.isNotEmpty)
                    const Text(
                      'Resources',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  const SizedBox(height: 8),
                  _resources.isEmpty
                      ? const Center(
                          child: Text(
                            'No resources added yet.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : SizedBox(
                          height: 400,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(top: 8, bottom: 96),
                            shrinkWrap: true,
                            itemCount: _resources.length,
                            itemBuilder: (context, index) {
                              return ResourceCard(
                                resource: _resources[index],
                                onDelete: () => _deleteResource(index),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 6);
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: isKeyboardOpen
          ? null
          : SpeedDial(
              animatedIcon: AnimatedIcons.menu_close,
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.shade900,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              spacing: 8,
              spaceBetweenChildren: 4,
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.video_file),
                  label: 'Video',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AddResourceDialog(
                        onResourceAdded: _addResource,
                        type: 'video',
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.podcasts),
                  label: 'Audio',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AddResourceDialog(
                        onResourceAdded: _addResource,
                        type: 'podcast',
                      ),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.article),
                  label: 'Link',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AddResourceDialog(
                        type: 'article',
                        onResourceAdded: _addResource,
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
