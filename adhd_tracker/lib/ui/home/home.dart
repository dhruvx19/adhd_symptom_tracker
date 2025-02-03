import 'package:flutter/material.dart';
import 'package:ADHD_Tracker/helpers/curved_navbar.dart';
import 'package:ADHD_Tracker/providers.dart/home_provider.dart';
import 'package:ADHD_Tracker/ui/auth/create_profile.dart';
import 'package:ADHD_Tracker/ui/home/goals/goals.dart';
import 'package:ADHD_Tracker/ui/home/record/symptom.dart';
import 'package:ADHD_Tracker/ui/home/reminder/reminder.dart';
import 'package:ADHD_Tracker/ui/home/reminder/show_reminder.dart';
import 'package:ADHD_Tracker/ui/settings/settings.dart';
import 'package:ADHD_Tracker/utils/color.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ADHD_Tracker/providers.dart/login_provider.dart';
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

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final healthProvider =
          Provider.of<HealthDataProvider>(context, listen: false);

      await Future.wait([
        _fetchMoods(),
        healthProvider.fetchSymptoms(_selectedDate),
        healthProvider.fetchMedications(_selectedDate),
      ]);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: ${e.toString()}')),
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
    _fetchAllData();
  }
  // Widget _buildDailySummary() {
  //   final healthProvider = Provider.of<HealthDataProvider>(context);
  //   final symptoms = healthProvider.symptoms;
  //   final medications = healthProvider.medications;

  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         if (_moodData[_selectedDate] != null) ...[
  //           Text(
  //             'Mood: ${getMoodText(_moodData[_selectedDate]!)}',
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 16),
  //         ],

  //         if (symptoms.isNotEmpty) ...[
  //           Text(
  //             'Symptoms:',
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 8),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: symptoms.map((symptom) => Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 4),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text('• Time: ${symptom['timeOfDay']}'),
  //                   Text('• Severity: ${symptom['severity']}'),
  //                   Text('• Symptoms: ${symptom['symptoms'].join(", ")}'),
  //                   if (symptom['notes'] != null)
  //                     Text('• Notes: ${symptom['notes']}'),
  //                   Divider(),
  //                 ],
  //               ),
  //             )).toList(),
  //           ),
  //         ],

  //         if (medications.isNotEmpty) ...[
  //           SizedBox(height: 16),
  //           Text(
  //             'Medications:',
  //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 8),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: medications.map((medication) => Padding(
  //               padding: const EdgeInsets.symmetric(vertical: 4),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text('• ${medication['medicationName']} - ${medication['dosage']}'),
  //                   Text('• Time: ${medication['timeOfTheDay']}'),
  //                   if (medication['effects'] != null)
  //                     Text('• Effects: ${medication['effects'].join(", ")}'),
  //                   Divider(),
  //                 ],
  //               ),
  //             )).toList(),
  //           ),
  //         ],

  //         if (symptoms.isEmpty && medications.isEmpty && _moodData[_selectedDate] == null)
  //           const Text(
  //             'No Records for this date',
  //             style: TextStyle(
  //               fontSize: 18,
  //               color: Colors.grey,
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

// In your HomePage class, replace _buildDailySummary() with:
  Widget _buildDailySummary() {
    return DayRecordTile(
      selectedDate: _selectedDate,
      moodData: _moodData,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
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
                  selectedColor: AppTheme.upeiRed,
                  unselectedColor: Colors.black,
                  currentIndex: _currentIndex,
                )
              : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: isLandscape ? 8 : 20,
                    bottom: 16 + bottomPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TableCalendar(
                          locale: "en_US",
                          headerStyle: const HeaderStyle(
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
                            final healthProvider =
                                Provider.of<HealthDataProvider>(context,
                                    listen: false);
                            healthProvider.fetchSymptoms(selectedDay);
                            healthProvider.fetchMedications(selectedDay);
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
                      _buildDailySummary(),
                      SizedBox(height: 80 + bottomPadding),

                      SizedBox(height: isSmallScreen ? 16 : 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: _moodData[_selectedDate] == null
                            ? const Text(
                                '',
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
                ),
              ),
      ),
    );
  }
}

class DayRecordTile extends StatefulWidget {
  final DateTime selectedDate;
  final Map<DateTime, int> moodData;

  const DayRecordTile({
    Key? key,
    required this.selectedDate,
    required this.moodData,
  }) : super(key: key);

  @override
  _DayRecordTileState createState() => _DayRecordTileState();
}

class _DayRecordTileState extends State<DayRecordTile> {
  bool isExpanded = false;

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

  String getSymptomsList(dynamic symptoms) {
    if (symptoms == null) return 'None';
    if (symptoms is List) {
      return symptoms.join(", ");
    }
    return symptoms.toString();
  }

  String getEffectsList(dynamic effects) {
    if (effects == null) return 'None';
    if (effects is List) {
      return effects.join(", ");
    }
    return effects.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDataProvider>(
      builder: (context, healthProvider, child) {
        final symptoms = healthProvider.symptoms;
        final medications = healthProvider.medications;
        final normalizedDate = DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
        );
        final mood = widget.moodData[normalizedDate];

        return Card(
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Your Day Record',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                ),
                trailing: IconButton(
                  icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              ),
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood Section
                      if (mood != null) ...[
                        Text(
                          'Mood',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(getMoodText(mood)),
                        ),
                        Divider(),
                      ],

                      // Symptoms Section
                      if (symptoms.isNotEmpty) ...[
                        Text(
                          'Symptoms',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: symptoms.length,
                          itemBuilder: (context, index) {
                            final symptom = symptoms[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Time: ${symptom['timeOfDay'] ?? 'Not specified'}',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text('Severity: ${symptom['severity'] ?? 'Not specified'}'),
                                    Text('Symptoms: ${getSymptomsList(symptom['symptoms'])}'),
                                    if (symptom['notes'] != null && symptom['notes'].toString().isNotEmpty)
                                      Text('Notes: ${symptom['notes']}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(),
                      ],

                      // Medications Section
                      if (medications.isNotEmpty) ...[
                        Text(
                          'Medications',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: medications.length,
                          itemBuilder: (context, index) {
                            final medication = medications[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${medication['medicationName'] ?? 'Unknown'} - ${medication['dosage'] ?? 'Not specified'}',
                                      style: TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text('Time: ${medication['timeOfTheDay'] ?? 'Not specified'}'),
                                    Text('Effects: ${getEffectsList(medication['effects'])}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      if (mood == null && symptoms.isEmpty && medications.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(Icons.note_alt_outlined, 
                                     size: 48, 
                                     color: Colors.grey),
                                SizedBox(height: 8),
                                Text(
                                  'No records for this date',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}