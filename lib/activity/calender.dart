import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'config.dart';

void main() {
  runApp(MaterialApp(
    home: BangladeshiCalendarScreen(),
  ));
}

class Holiday {
  final String name;
  final DateTime date;

  Holiday(this.name, this.date);
}

class BangladeshiCalendarScreen extends StatefulWidget {
  @override
  _BangladeshiCalendarScreenState createState() =>
      _BangladeshiCalendarScreenState();
}

class _BangladeshiCalendarScreenState extends State<BangladeshiCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  List<Holiday> _holidays = [];

  @override
  void initState() {
    super.initState();
    fetchHolidays();
  }

  Future<void> fetchHolidays() async {
    int year = _focusedDay.year;
    final apiUrl = Uri.parse(
        'https://calenderkaka.000webhostapp.com/getholidays.php?year=$year');

    try {
      final response = await http.get(apiUrl);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Holiday> holidays = [];

        jsonData.forEach((holidayData) {
          holidays.add(Holiday(
              holidayData['name'], DateTime.parse(holidayData['date'])));
        });

        setState(() {
          _holidays = holidays;
        });
      } else {
        print('Failed to fetch holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bangladeshi Calendar'),
      ),
      body: ListView(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, events) {
                var isHoliday = _holidays.any((holiday) =>
                    holiday.date.year == date.year &&
                    holiday.date.month == date.month &&
                    holiday.date.day == date.day);
                final isFridayOrSaturday = date.weekday == DateTime.friday ||
                    date.weekday == DateTime.saturday;

                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isHoliday || isFridayOrSaturday
                          ? Color.fromARGB(255, 236, 59, 47)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isHoliday || isFridayOrSaturday
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle: TextStyle(
                  color: Color.fromARGB(255, 221, 58, 46), fontSize: 15),
            ),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
              fetchHolidays();
            },
          ),
          if (_holidays.isNotEmpty)
            Column(
              children: [
                Text(
                  'Holidays:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color.fromARGB(255, 224, 74, 48)),
                ),
                ...(_holidays
                    .where((holiday) => _focusedDay.month == holiday.date.month)
                    .map((holiday) => Card(
                          elevation: 5,
                          margin: EdgeInsets.all(5),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              '${holiday.name}: ${DateFormat('yyyy-MM-dd').format(holiday.date)}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ))
                    .toList()),
              ],
            )
        ],
      ),
    );
  }
}
