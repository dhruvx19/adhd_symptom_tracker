import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindle/models/database_helper.dart';
import 'package:mindle/models/goals.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  DateTime? _startDate;
  TimeOfDay? _selectedTime;
  String? selectedFrequency;
  int _frequencyCount = 1;
  String? _selectedSound;

  final List<String> _soundOptions = [
    'Default',
    'Chime',
    'Gentle Alarm',
    'Bell',
    'Electronic',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 10),
    );

    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveGoal() async {
    if (_startDate == null ||
        _selectedTime == null ||
        selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final goal = Goal(
      name: 'Your Goal Name', // Replace with actual input
      frequency: '$selectedFrequency ($_frequencyCount times)',
      startDate: DateTime(_startDate!.year, _startDate!.month, _startDate!.day,
          _selectedTime!.hour, _selectedTime!.minute),
      notes: 'Sound: ${_selectedSound ?? 'Default'}',
    );

    await DatabaseHelper.instance.insertGoal(goal);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontScale = size.width / 375.0;
    final softPurple = const Color(0xFF8D5BFF);
    final darkPurple = const Color(0xFF2D2642);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Reminder',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Title',
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Frequency Selection
            Text(
              'Frequency',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _FrequencyButton(
                  label: 'Daily',
                  isSelected: selectedFrequency == 'Daily',
                  onPressed: () => setState(() => selectedFrequency = 'Daily'),
                ),
                _FrequencyButton(
                  label: 'Weekly',
                  isSelected: selectedFrequency == 'Weekly',
                  onPressed: () => setState(() => selectedFrequency = 'Weekly'),
                ),
                _FrequencyButton(
                  label: 'Monthly',
                  isSelected: selectedFrequency == 'Monthly',
                  onPressed: () =>
                      setState(() => selectedFrequency = 'Monthly'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Frequency Count Selection
            Text(
              'Repeat Count',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3].map((count) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _frequencyCount = count),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _frequencyCount == count
                            ? Colors.blue[50]
                            : Colors.white,
                        side: BorderSide(
                          color: _frequencyCount == count
                              ? Colors.blue
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: Text('$count times'),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Date and Time Selection
            ListTile(
              title: Text(_startDate != null
                  ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                  : "Select Start Date"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            ListTile(
              title: Text(_selectedTime != null
                  ? _selectedTime!.format(context)
                  : "Select Time"),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(context),
            ),
            // Sound Selection
            // (Previous code remains the same, replace Sound Selection section with:)
            Text(
              'Sound',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 16 * fontScale,
                  fontWeight: FontWeight.bold,
                  color: darkPurple,
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: Text('Select Sound'),
              value: _selectedSound,
              items: _soundOptions.map((sound) {
                return DropdownMenuItem(
                  value: sound,
                  child: Text(sound),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSound = value;
                });
              },
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _soundOptions.map((sound) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(sound),
                      selected: _selectedSound == sound,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedSound = selected ? sound : null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Create Reminder',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// _FrequencyButton remains the same as in the original code
class _FrequencyButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _FrequencyButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue[50] : Colors.white,
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
