// pages/reminder_list_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mindle/models/reminder_db.dart';
import 'package:mindle/models/reminder_model.dart';
import 'package:mindle/ui/home/reminder/reminder.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  late Future<List<Reminder>> _reminderFuture;
   List<Reminder> _reminder = [];

  @override
  void initState() {
    super.initState();
    _refreshReminder();
  }

  void _refreshReminder() {
    setState(() {
      _reminderFuture = DatabaseHelper.instance.getAllReminder();
    });
  }

  Future<void> _toggleReminderCompletion(Reminder reminder) async {
    await DatabaseHelper.instance
        .updateReminderCompletion(reminder.id!, !reminder.isCompleted);
    _refreshReminder();
  }

  Future<void> _deleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Reminder'),
        content: Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteReminder(reminder.id!);
      _refreshReminder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Reminders',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2642),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Reminder>>(
        future: _reminderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reminder = snapshot.data ?? [];

          if (reminder.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: reminder.length,
            itemBuilder: (context, index) {
              final reminder = _reminder[index];
              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _toggleReminderCompletion(reminder),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF8D5BFF),
                              width: 2,
                            ),
                            color:
                                reminder.isCompleted ? Color(0xFF8D5BFF) : Colors.white,
                          ),
                          child: reminder.isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  decoration: reminder.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: reminder.isCompleted
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${DateFormat('MMM d, y').format(reminder.startDate)} at ${reminder.scheduledTime.format(context)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              if (reminder.notes.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  reminder.notes,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: Colors.red[300]),
                          onPressed: () => _deleteReminder(reminder),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await  Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReminderPage(),
                          ),
                        );
          _refreshReminder();
        },
        backgroundColor: Color(0xFF8D5BFF),
        child: Icon(Icons.add),
      ),
    );
  }
}