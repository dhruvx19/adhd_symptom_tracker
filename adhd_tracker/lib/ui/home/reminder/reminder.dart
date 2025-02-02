import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindle/helpers/notification.dart';
import 'package:mindle/models/goals.dart';
import 'package:mindle/models/reminder_db.dart';
import 'package:mindle/models/reminder_model.dart';
import 'package:mindle/utils/color.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
final List<String> _soundOptions = NotificationService.soundMap.keys.toList();
  final List<String> _frequencyOptions = [
    'Once',
    'Twice',
    'Thrice',
  ];
  String? _selectedSound;
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _selectedTime;
  String? selectedFrequency;
  String? _selectedFrequency;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _notesController = TextEditingController();
   final TextEditingController _titleController = TextEditingController();
    Timer? _debounce;


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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

void _saveReminder() async {
    if (_startDate == null || _selectedFrequency == null || _selectedTime == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final success = await NotificationService.scheduleReminder(
      context: context,
      title: _titleController.text,
      notes: _notesController.text,
      startDate: _startDate!,
      selectedTime: _selectedTime!,
      frequency: _selectedFrequency!,
      sound: _selectedSound ?? 'Default',
    );

    if (success) {
      final reminder = Reminder(
        name: _titleController.text,
        frequency: _selectedFrequency!,
        startDate: _startDate!,
        notes: _notesController.text,
        scheduledTime: _selectedTime!,
        sound: _selectedSound,
      );

      await DatabaseHelper.instance.insertReminder(reminder);
      Navigator.pop(context);
    }
  }
  void _saveToList() async {
    if (_startDate == null || _selectedFrequency == null || _selectedTime == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final reminder = Reminder(
      name: _titleController.text,
      frequency: _selectedFrequency!,
      startDate: _startDate!,
      notes: _notesController.text,
      scheduledTime: _selectedTime!,
      sound: _selectedSound,
    );

    await DatabaseHelper.instance.insertReminder(reminder);
    Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final size = MediaQuery.of(context).size;
    final fontScale = size.width < 360 ? 0.8 : size.width / 375.0;
    final isSmallScreen = size.height < 600;

    // Colors
   
    final grey = const Color(0xFFF5F5F5);
    final darkPurple = const Color(0xFF2D2642);

    // Padding
    final horizontalPadding = size.width * 0.05; // 5% of screen width
    final verticalSpacing = size.height * 0.02; // 2% of screen height

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'New Reminder',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 20 * fontScale,
              fontWeight: FontWeight.bold,
              color: darkPurple,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalSpacing,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: verticalSpacing),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    TextField(
                      controller: _notesController,
                      maxLines: isSmallScreen ? 3 : 5,
                      decoration: InputDecoration(
                        hintText: 'Add notes...',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: verticalSpacing * 2),
                    Text(
                      'Remind me on a day',
                      style: GoogleFonts.lato(
                        textStyle: TextStyle(
                          fontSize: 16 * fontScale,
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_startDate != null
                          ? "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}"
                          : "Select Start Date"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_selectedTime != null
                          ? _selectedTime!.format(context)
                          : "Select Time"),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                    SizedBox(height: verticalSpacing),
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
                    SizedBox(height: verticalSpacing),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      hint: Text('Select frequency'),
                      value: _selectedFrequency,
                      items: _frequencyOptions.map((freq) {
                        return DropdownMenuItem(
                          value: freq,
                          child: Text(freq),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value;
                        });
                      },
                    ),
                    SizedBox(height: verticalSpacing * 2),
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
                    SizedBox(height: verticalSpacing),
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
                    SizedBox(height: verticalSpacing * 3),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalSpacing,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.upeiRed,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                        ),
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
                  SizedBox(width: horizontalPadding * 0.5),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveToList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Save to list',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14 * fontScale,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
