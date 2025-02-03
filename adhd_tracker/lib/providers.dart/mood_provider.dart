import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';


// Stats Provider
class MoodStatsProvider extends ChangeNotifier {
  Map<int, int> _moodTotals = {};
  int _currentStreak = 0;
  int _longestStreak = 0;
  int? _daysSinceBadDay;
  bool isLoading = true;
  String? error;

  Map<int, int> get moodTotals => _moodTotals;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int? get daysSinceBadDay => _daysSinceBadDay;

  Future<void> fetchMoodData() async {
    try {
      final response = await http.get(Uri.parse(
        'https://freelance-backend-xx6e.onrender.com/api/v1/mood/mood?startDate=2025-01-28&endDate=2025-02-04'
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Process mood totals
          Map<int, int> totals = {};
          for (var mood in data['data']) {
            int moodValue = mood['mood'];
            totals[moodValue] = (totals[moodValue] ?? 0) + 1;
          }
          _moodTotals = totals;

          // Calculate streaks and days since bad day
          List<dynamic> sortedMoods = List.from(data['data'])
            ..sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

          _calculateStreaks(sortedMoods);
          _calculateDaysSinceBadDay(sortedMoods);

          isLoading = false;
          notifyListeners();
        }
      } else {
        error = 'Failed to load mood data';
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      error = 'Error: $e';
      isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStreaks(List<dynamic> sortedMoods) {
    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? lastDate;

    for (var mood in sortedMoods) {
      DateTime date = DateTime.parse(mood['date']);
      
      if (lastDate == null || 
          date.difference(lastDate).inDays == 1) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
      } else {
        currentStreak = 1;
      }
      
      lastDate = date;
    }

    _currentStreak = currentStreak;
    _longestStreak = longestStreak;
  }

  void _calculateDaysSinceBadDay(List<dynamic> sortedMoods) {
    if (sortedMoods.isEmpty) {
      _daysSinceBadDay = null;
      return;
    }

    DateTime now = DateTime.now();
    for (var mood in sortedMoods) {
      if (mood['mood'] == 2) { // Bad mood
        DateTime badMoodDate = DateTime.parse(mood['date']);
        _daysSinceBadDay = now.difference(badMoodDate).inDays;
        return;
      }
    }
    _daysSinceBadDay = null;
  }
}

// Streak Card Widget
class StreakCard extends StatelessWidget {
  final String title;
  final int number;
  final bool isVisible;
  final IconData icon;

  const StreakCard({
    super.key,
    required this.title,
    required this.number,
    required this.isVisible,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || number < 0) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}