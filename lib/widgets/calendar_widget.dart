import 'package:coaching_admin/models/meeting_dates.dart';
import 'package:coaching_admin/provider/meeting_dates_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyCalendar extends StatefulWidget {
  final DateTime? selectedDay;
  final Function(DateTime?) onDaySelected;
  final Function(List<String>) setMeetings;

  const MyCalendar({
    super.key,
    required this.onDaySelected,
    this.selectedDay,
    required this.setMeetings,
  });

  @override
  State<MyCalendar> createState() => _MyCalendarState();
}

class _MyCalendarState extends State<MyCalendar> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDay;
    _fetchMeetingDatesForYear(_currentYear);
  }

  void _fetchMeetingDatesForYear(int year) {
    Provider.of<MeetingDatesProvider>(context, listen: false)
        .fetchMeetingDates(year);
  }

  @override
  Widget build(BuildContext context) {
    final meetingDatesProvider = Provider.of<MeetingDatesProvider>(context);
    final MeetingDates meetingDates =
        MeetingDates(dates: meetingDatesProvider.dates);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNavigationRow(),
        const SizedBox(height: 8),
        _buildCalendar(_currentMonth, meetingDates)
      ],
    );
  }

  Widget _buildNavigationRow() {
    DateTime today = DateTime.now();
    bool isCurrentMonth =
        _currentMonth.year == today.year && _currentMonth.month == today.month;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: isCurrentMonth
              ? null // Disable the back button if it's the current month
              : () {
                  setState(() {
                    _currentMonth = DateTime(
                      _currentMonth.year,
                      _currentMonth.month - 1,
                    );
                    _checkYearChange(_currentMonth.year);
                  });
                },
          color: isCurrentMonth
              ? Colors.grey
              : null, // Change button color if disabled
        ),
        Text(
          '${_currentMonth.year} ${getMonthName(_currentMonth.month)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
              _checkYearChange(_currentMonth.year);
            });
          },
        ),
      ],
    );
  }

  void _checkYearChange(int year) {
    if (year != _currentYear) {
      _currentYear = year;
      _fetchMeetingDatesForYear(year);
    }
  }

  Widget _buildCalendar(DateTime month, MeetingDates meetingDates) {
    int year = month.year;
    int monthNumber = month.month;
    DateTime firstDayOfMonth = DateTime(year, monthNumber, 1);
    DateTime lastDayOfMonth = (monthNumber < 12)
        ? DateTime(year, monthNumber + 1, 0)
        : DateTime(year + 1, 1, 0);

    int numberOfDays = lastDayOfMonth.day;
    int startingWeekday = firstDayOfMonth.weekday % 7;
    DateTime today = DateTime.now();

    List<TableRow> calendarRows = [];

    // Add background color for day names
    calendarRows.add(
      TableRow(
        children: List.generate(
          7,
          (index) => Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: index == 0
                  ? const BorderRadius.only(topLeft: Radius.circular(8))
                  : index == 6
                      ? const BorderRadius.only(topRight: Radius.circular(8))
                      : null,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  getAbbreviatedDayName(index),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    for (int i = 0; i < 6; i++) {
      List<Widget> weekWidgets = [];

      for (int j = 1; j <= 7; j++) {
        int dayValue = i * 7 + j - startingWeekday;

        if (dayValue > 0 && dayValue <= numberOfDays) {
          DateTime currentDay = DateTime(year, monthNumber, dayValue);
          bool hasMeeting =
              meetingDates.dates[monthNumber]?.containsKey(dayValue) ?? false;
          bool isSelected =
              _selectedDate != null && isSameDay(_selectedDate!, currentDay);
          bool isPastDay =
              currentDay.isBefore(today.subtract(const Duration(days: 1)));

          weekWidgets.add(
            GestureDetector(
              onTap: isPastDay
                  ? null // Disable interaction for past days
                  : () {
                      setState(() {
                        if (_selectedDate != null &&
                            isSameDay(_selectedDate!, currentDay)) {
                          _selectedDate = null; // Clear selected date
                        } else {
                          _selectedDate = currentDay; // Set selected date
                        }
                      });
                      widget.onDaySelected(_selectedDate);
                      widget.setMeetings(meetingDates.dates[monthNumber]
                              ?[_selectedDate!.day] ??
                          []);
                    },
              child: Padding(
                padding: i == 0
                    ? const EdgeInsets.only(top: 8)
                    : i == 4
                        ? const EdgeInsets.only(bottom: 8)
                        : EdgeInsets.zero,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(4),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? Colors.blue[900] : null),
                      child: Text(
                        '$dayValue',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isPastDay ? Colors.grey : Colors.black),
                        ),
                      ),
                    ),
                    if (hasMeeting && !isSelected && !isPastDay)
                      Container(
                        alignment: Alignment.bottomCenter,
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(4),
                        width: 40,
                        height: 40,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        } else {
          weekWidgets.add(Container());
        }
      }

      calendarRows.add(TableRow(children: weekWidgets));
    }

    List<Widget> first = calendarRows[1].children;

    if ((first[4] is! GestureDetector || first[5] is! GestureDetector)) {
      List<Widget> first = calendarRows.removeAt(1).children;
      List<Widget> last = calendarRows.removeLast().children;

      for (int i = 0; i < first.length; i++) {
        if (last[i] is GestureDetector) {
          first[i] = last[i];
        }
      }
      calendarRows.insert(1, TableRow(children: first));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 1,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: Table(
          children: calendarRows,
        ),
      ),
    );
  }

  String getAbbreviatedDayName(int day) {
    switch (day) {
      case 0:
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      default:
        return '';
    }
  }

  String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
