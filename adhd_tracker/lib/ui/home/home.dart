import 'package:flutter/material.dart';
import 'package:mindle/helpers/curved_navbar.dart';
import 'package:mindle/ui/auth/create_profile.dart';
import 'package:mindle/ui/home/goals/goals.dart';
import 'package:mindle/ui/home/record/symptom.dart';
import 'package:mindle/ui/home/reminder/reminder.dart';
import 'package:mindle/ui/home/reminder/show_reminder.dart';
import 'package:mindle/ui/settings/settings.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:mindle/providers.dart/login_provider.dart';
import 'dart:convert';
import 'mood.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [GoalsPage(), ReminderListPage(), SettingsPage()];

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, int> _moodData = {};
  bool _isLoading = false;

  Color getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return Color(0xFF4CAF50); // Green for Mild
      case 2:
        return Color(0xFFFFA726); // Orange for Moderate
      case 3:
        return Color(0xFFE53935); // Red for Severe
      default:
        return Colors.grey;
    }
  }

  String getMoodText(int mood) {
    switch (mood) {
      case 1:
        return "Mild";
      case 2:
        return "Moderate";
      case 3:
        return "Severe";
      default:
        return "Unknown";
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _fetchMoods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final loginProvider = Provider.of<LoginProvider>(context, listen: false);
      final token = loginProvider.token;

      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Calculate date range for current month view
      final startDate = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 2, 0);

      final url = Uri.parse(
          'https://freelance-backend-xx6e.onrender.com/api/v1/mood/mood?startDate=${startDate.toIso8601String().split('T')[0]}&endDate=${endDate.toIso8601String().split('T')[0]}');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          Map<DateTime, int> newMoodData = {};

          for (var item in responseData['data']) {
            final date = DateTime.parse(item['date']);
            final normalizedDate = _normalizeDate(date);
            newMoodData[normalizedDate] = item['mood'];
          }

          setState(() {
            _moodData = newMoodData;
          });
        }
      } else {
        throw Exception('Failed to fetch moods');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching mood data: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMoods();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      bottomNavigationBar:
          Provider.of<LoginProvider>(context, listen: false).isLoggedIn
              ? CustomCurvedNavigationBar(
                  items: [
                    CurvedNavigationBarItem(
                      iconData: Icons.home,
                      selectedIconData: Icons.home,
                    ),
                    CurvedNavigationBarItem(
                      iconData: Icons.flag,
                      selectedIconData: Icons.flag,
                    ),
                    CurvedNavigationBarItem(
                      iconData: Icons.notifications,
                      selectedIconData: Icons.notifications,
                    ),
                    CurvedNavigationBarItem(
                      iconData: Icons.settings,
                      selectedIconData: Icons.settings,
                    ),
                  ],
                  onTap: (index) {
                    if (index == 0) {
                      setState(() {
                        _currentIndex = 0;
                      });
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => _pages[index - 1]));
                    }
                  },
                  selectedColor: const Color(0xFF8D5BFF),
                  unselectedColor: Colors.black,
                  currentIndex: _currentIndex,
                )
              : null,
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TableCalendar(
                    locale: "en_US",
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDate = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                      _fetchMoods(); // Fetch moods when month changes
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, events) {
                        final normalizedDate = _normalizeDate(date);
                        final mood = _moodData[normalizedDate];

                        if (mood != null) {
                          return Container(
                            margin: const EdgeInsets.all(4.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getMoodColor(mood),
                            ),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                      selectedBuilder: (context, date, events) {
                        final normalizedDate = _normalizeDate(date);
                        final mood = _moodData[normalizedDate];

                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mood != null
                                ? getMoodColor(mood)
                                : Color(0xFF8D5BFF),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, date, events) {
                        final normalizedDate = _normalizeDate(date);
                        final mood = _moodData[normalizedDate];

                        return Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mood != null
                                ? getMoodColor(mood)
                                : Colors.transparent,
                            border: Border.all(
                              color: Color(0xFF8D5BFF),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: mood != null
                                  ? Colors.white
                                  : Color(0xFF8D5BFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    daysOfWeekHeight: isSmallScreen ? 16 : 20,
                    rowHeight: isSmallScreen ? 42 : 52,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 40),
                
                SizedBox(height: isSmallScreen ? 16 : 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: _moodData[_selectedDate] == null
                      ? const Text(
                          'No Records Yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        )
                      : Text(
                          'Mood: ${_moodData[_selectedDate] == 0 ? "Mild" : _moodData[_selectedDate] == 1 ? "Moderate" : "Severe"}',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
                // Add extra padding at bottom to prevent content from being hidden behind navbar
                SizedBox(height: 80 + bottomPadding),
              ],
            ),
    );
  }
}
