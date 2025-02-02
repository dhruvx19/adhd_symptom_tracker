// mood_chart_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mindle/models/representation/mood_model.dart';
import 'package:mindle/services/mood_service.dart';

class MoodChartScreen extends StatefulWidget {
  @override
  _MoodChartScreenState createState() => _MoodChartScreenState();
}

class _MoodChartScreenState extends State<MoodChartScreen> {
  final MoodService _moodService = MoodService();
  String _selectedRange = 'week';
  List<MoodEntry> _moodData = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final DateTime endDate = DateTime.now();
      final DateTime startDate = _selectedRange == 'week'
          ? endDate.subtract(const Duration(days: 7))
          : endDate.subtract(const Duration(days: 30));

      final data = await _moodService.fetchMoodData(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _moodData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
   Color getMoodColor(int moodValue) {
    switch (moodValue) {
      case 0:
        return Color(0xFF4CAF50);
      case 1:
        return Color(0xFFFFA726);
      case 2:
        return Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  final List<Map<String, dynamic>> moods = [
    {"label": "Mild - Can Function", "emoji": "😊", "value": 0},
    {"label": "Moderate - Slowed", "emoji": "😐", "value": 1},
    {"label": "Severe - Cannot Function", "emoji": "😢", "value": 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          DropdownButton<String>(
            value: _selectedRange,
            items: ['week', 'month'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRange = newValue;
                });
                _fetchData();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_moodData.isEmpty) {
      return const Center(child: Text('No mood data available'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Mood Trends',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final dailyAverages = _calculateDailyAverages();
    final spots = dailyAverages.entries.map((e) {
      return FlSpot(
        e.key.millisecondsSinceEpoch.toDouble(),
        e.value,
      );
    }).toList();

    // Get min and max dates for x-axis
    final minDate = spots.isEmpty
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(spots.first.x.toInt());
    final maxDate = spots.isEmpty
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(spots.last.x.toInt());

    // Calculate interval for x-axis labels
    final daysDifference = maxDate.difference(minDate).inDays;
    final interval = _calculateInterval(daysDifference);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: interval * 86400000, // Convert days to milliseconds
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: interval * 86400000, // Convert days to milliseconds
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                // Only show labels at interval points
                if (date.difference(minDate).inDays % interval != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                String emoji;
                switch (value.toInt()) {
                  case 1:
                    emoji = '😊';
                    break;
                  case 2:
                    emoji = '😐';
                    break;
                  case 3:
                    emoji = '😔';
                    break;
                  default:
                    return const SizedBox.shrink();
                }
                return SizedBox(
                  width: 30,
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(),
          topTitles: AxisTitles(),
        ),
        borderData: FlBorderData(show: true),
        minY: 1,
        maxY: 3,
        minX: minDate.millisecondsSinceEpoch.toDouble(),
        maxX: maxDate.millisecondsSinceEpoch.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.purple,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4, // Reduced from 6
                  color: Colors.purple,
                  strokeWidth: 1, // Reduced from 2
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date =
                    DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                String emoji;
                if (spot.y <= 1.5) {
                  emoji = '😊';
                } else if (spot.y <= 2.5) {
                  emoji = '😐';
                } else {
                  emoji = '😔';
                }
                return LineTooltipItem(
                  '${DateFormat('MM/dd').format(date)}\n$emoji ${spot.y.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  // Helper method to calculate appropriate interval based on date range
  double _calculateInterval(int daysDifference) {
    if (daysDifference <= 7) {
      return 1; // Show daily labels for a week or less
    } else if (daysDifference <= 14) {
      return 2; // Show labels every 2 days for two weeks
    } else if (daysDifference <= 31) {
      return 5; // Show labels every 5 days for a month
    } else {
      return (daysDifference / 6)
          .ceil()
          .toDouble(); // Show approximately 6 labels
    }
  }

  Map<DateTime, double> _calculateDailyAverages() {
    final Map<DateTime, List<int>> dailyMoods = {};

    for (var entry in _moodData) {
      final date = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );

      if (!dailyMoods.containsKey(date)) {
        dailyMoods[date] = [];
      }
      dailyMoods[date]!.add(entry.mood);
    }

    final sortedDates = dailyMoods.keys.toList()..sort();

    return Map.fromEntries(
      sortedDates.map((date) {
        final moods = dailyMoods[date]!;
        final average = moods.reduce((a, b) => a + b) / moods.length;
        return MapEntry(date, average);
      }),
    );
  }
}
