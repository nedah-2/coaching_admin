import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:coaching_admin/models/meeting.dart';
import 'package:coaching_admin/models/student_search.dart';
import 'package:coaching_admin/provider/meeting_dates_provider.dart';
import 'package:coaching_admin/provider/meeting_provider.dart';
import 'package:coaching_admin/provider/review_provider.dart';
import 'package:coaching_admin/provider/student_search_provider.dart';
import 'package:coaching_admin/utils/create_meeting.dart';
import 'package:coaching_admin/utils/format_date_time.dart';
import 'package:coaching_admin/widgets/calendar_widget.dart';
import 'package:coaching_admin/widgets/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../widgets/custom_snackbar.dart';

class ScheduleMeetingPage extends StatefulWidget {
  final StudentSearchModel? student;
  final Meeting? meeting;
  const ScheduleMeetingPage({super.key, this.student, this.meeting});

  @override
  State<ScheduleMeetingPage> createState() => _ScheduleMeetingPageState();
}

class _ScheduleMeetingPageState extends State<ScheduleMeetingPage> {
  TimeOfDay? _selectedTime;
  DateTime? _selectedDate;
  StudentSearchModel? _selectedStudent;
  String? _meetingId;
  String? _passcode;
  final TextEditingController _topicController = TextEditingController();
  List<String>? meetingTimes;

  void _setMeetings(List<String> meetings) {
    setState(() {
      meetingTimes = sortMeetingTimes(meetings);
    });
  }

  void _selectDate(DateTime? date) {
    if (date != null && date != _selectedDate) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _selectStudent(StudentSearchModel? student) {
    if (student != null && student.email != _selectedStudent?.email) {
      setState(() {
        _selectedStudent = student;
      });
    }
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      if (meetingTimes != null &&
          !meetingTimes!.contains(formatTimeOfDay(picked))) {
        setState(() {
          _selectedTime = picked;
        });
      } else {
        if (mounted) {
          if (meetingTimes != null) {
            showSnackBar(context, 'Cannot start meeting at the same time');
          } else {
            showSnackBar(context, 'Please select the date first');
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.student != null) {
      _selectedStudent = widget.student;
    }
    if (widget.meeting != null) {
      _topicController.text = widget.meeting!.title;
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> scheduleMeeting(
      String topic, String startTime) async {
    const defaultId = '';
    const defaultPasscode = '';

    final accessToken = await getAccessToken();

    // ignore: prefer_const_declarations
    final url = 'https://api.zoom.us/v2/users/me/meetings';

    final body = {
      "topic": topic,
      "type": 2, // Scheduled meeting
      "start_time": startTime, // In ISO 8601 format
      "duration": 90, // Meeting duration in minutes
      "settings": {
        "join_before_host": false,
        "waiting_room": true,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return {'mid': data['id'].toString(), 'passcode': data['password']};
    }

    return {'mid': defaultId, 'passcode': defaultPasscode};
  }

  @override
  Widget build(BuildContext context) {
    final isTimeSelected = _selectedTime != null;
    final isDateSelectd = _selectedDate != null;
    final isStudentSelected = _selectedStudent != null;

    Widget buildChip(String time) {
      return Chip(
        label: Text(time),
        avatar: const Icon(Icons.schedule),
      );
    }

    void showStudentSelectionDialog(BuildContext context) async {
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Student Selection",
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (context, animation, secondaryAnimation) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Access the StudentSearchProvider
              final studentSearchProvider =
                  Provider.of<StudentSearchProvider>(context);

              // Initially, filtered list is the same as the full list
              List<StudentSearchModel> filteredStudents =
                  studentSearchProvider.filteredStudents;

              return Center(
                child: Material(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.85,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 12, left: 16, right: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Select Student',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              IconButton(
                                onPressed: () {
                                  studentSearchProvider.searchStudents('');
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close, size: 20),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            onChanged: (query) {
                              // Call the search method from the provider
                              studentSearchProvider.searchStudents(query);
                              setState(() {
                                filteredStudents =
                                    studentSearchProvider.filteredStudents;
                              });
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: 'Search',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        if (studentSearchProvider.isLoading)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: const Center(child: Text('Loading...')),
                          )
                        else if (filteredStudents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Center(child: Text('No studnets found')),
                          )
                        else
                          ListView.separated(
                            itemCount: filteredStudents.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: student.profileUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: student.profileUrl,
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
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
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                                  width: 8,
                                                  height: 8,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 1,
                                                  )),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                            Icons.error,
                                            size: 18,
                                          ),
                                        )
                                      : const Icon(Icons.person, size: 18),
                                ),
                                title: Text(
                                  student.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(student.email),
                                onTap: () {
                                  _selectStudent(student);
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    }

    Future<void> saveMeeting() async {
      // Validate inputs
      if (!isStudentSelected) {
        showSnackBar(context, 'Please select a student');
        return;
      }
      if (!isDateSelectd) {
        showSnackBar(context, 'Please select a date');
        return;
      }
      if (!isTimeSelected) {
        showSnackBar(context, 'Please select a time');
        return;
      }
      if (_topicController.text.isEmpty) {
        showSnackBar(context, 'Please enter a meeting topic');
        return;
      }

      // Show loading dialog
      showLoading(context);

      try {
        // Format the date and time
        final dateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
        final startTime = dateTime.toIso8601String();

        // Schedule the meeting and get the meeting ID and passcode
        final meetingDetails =
            await scheduleMeeting(_topicController.text, startTime);

        setState(() {
          _meetingId = meetingDetails['mid'];
          _passcode = meetingDetails['passcode'];
        });

        if (context.mounted) {
          await Provider.of<MeetingProvider>(context, listen: false).addMeeting(
            Meeting(
              title: _topicController.text.trim(),
              dateTimeUtc: dateTime,
              mid: _meetingId!,
              passcode: _passcode!,
              sid: _selectedStudent!.id,
              student: _selectedStudent!.name,
            ),
          );

          if (context.mounted) {
            await Provider.of<MeetingDatesProvider>(context, listen: false)
                .addMeetingDate(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              formatTimeOfDay(_selectedTime!),
            );
          }

          if (context.mounted && widget.meeting != null) {
            await Provider.of<ReviewProvider>(context, listen: false)
                .updateStatus(widget.meeting!, 'Reschedule');
            if (context.mounted) {
              showSnackBar(context, 'Meeting has been rescheduled');
            }
          }

          if (context.mounted) Navigator.of(context).pop();
          if (context.mounted) Navigator.of(context).pop(); // Pop the page
        }
      } catch (e) {
        if (context.mounted) {
          showSnackBar(context, 'An error occurred while saving the meeting');
        }
      } finally {
        // Ensure that the loading dialog is dismissed
        if (context.mounted && Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Schedule Meeting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Close the page
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await saveMeeting();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 6),
                child: Row(
                  children: [
                    const Text(
                      'With : ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        isStudentSelected
                            ? _selectedStudent!.name
                            : 'No Student Selected',
                        style: TextStyle(
                          fontSize: 16,
                          color: isStudentSelected ? Colors.black : Colors.grey,
                          fontWeight: isStudentSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to select student
                        showStudentSelectionDialog(context);
                      },
                      child: Text(
                        isStudentSelected ? 'Edit' : 'Select',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 6),
                child: Row(
                  children: [
                    const Text(
                      'Date :  ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        isDateSelectd ? formatDate(_selectedDate) : 'Not Set',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDateSelectd ? Colors.black : Colors.grey,
                          fontWeight: isDateSelectd
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showMeetingDatePickerDialog(context);
                      },
                      child: Text(
                        isDateSelectd ? 'Edit' : 'Select',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 6),
                child: Row(
                  children: [
                    const Text(
                      'Time :  ',
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Text(
                        isTimeSelected ? formatTime(_selectedTime) : 'Not Set',
                        style: TextStyle(
                          fontSize: 16,
                          color: isTimeSelected ? Colors.black : Colors.grey,
                          fontWeight: isTimeSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _selectTime,
                      child: Text(
                        isTimeSelected ? 'Edit' : 'Select',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _topicController,
                  // maxLines: 3,
                  decoration: const InputDecoration(
                    // isDense: true,
                    labelText: 'What is the meeting about?',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              if (meetingTimes != null && meetingTimes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 32.0),
                        child: Text(
                          'Meetings on selected day',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                            top: 12,
                          ),
                          child: Wrap(
                            spacing: 12.0, // Gap between adjacent chips
                            runSpacing: 4.0, // Gap between lines
                            children: meetingTimes!
                                .map((time) => buildChip(time))
                                .toList(),
                          )),
                    ],
                  ),
                ),
              // const Expanded(
              //     child: Center(
              //   child: Text('No meeting on this day'),
              // ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMeetingDatePickerDialog(
    BuildContext context,
  ) async {
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: const EdgeInsets.all(16),
              titlePadding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              actionsPadding: const EdgeInsets.only(right: 8, bottom: 24),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: const Text(
                'Select Meeting Date',
                style: TextStyle(fontSize: 16),
              ),
              content: SizedBox(
                width: double.maxFinite, // Use full width

                child: MyCalendar(
                  selectedDay: _selectedDate,
                  onDaySelected: _selectDate,
                  setMeetings: _setMeetings,
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(selectedDate);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
