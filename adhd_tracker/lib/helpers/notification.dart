import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static Future<bool> initializeNotifications() async {
    return await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'Reminder Notifications',
          channelDescription: 'Channel for reminder notifications',
          defaultColor: const Color(0xFF8D5BFF),
          ledColor: const Color(0xFF8D5BFF),
          importance: NotificationImportance.High,
          soundSource: 'resource://raw/res_water',
          playSound: true,
        ),
      ],
    );
  }

  static Future<bool> requestPermission(BuildContext context) async {
    // Check if permissions are already granted
    final isGranted = await AwesomeNotifications().isNotificationAllowed();
    if (!isGranted) {
      // Show permission dialog
      final userResponse = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notification Permission'),
          content: const Text(
            'To receive reminders, please allow notification permissions. Would you like to enable notifications?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not Now'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable'),
            ),
          ],
        ),
      );

      if (userResponse == true) {
        return await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return false;
    }
    return true;
  }

  static Future<bool> scheduleReminder({
    required BuildContext context,
    required String title,
    required String notes,
    required DateTime startDate,
    required TimeOfDay selectedTime,
    required String frequency,
    required String sound,
  }) async {
    try {
      // First check/request permissions
      final hasPermission = await requestPermission(context);
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifications permission is required to set reminders'),
            duration: Duration(seconds: 4),
          ),
        );
        return false;
      }

      final scheduledDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final int notificationCount = _getNotificationCount(frequency);

      // Schedule notifications based on frequency
      for (int i = 0; i < notificationCount; i++) {
        final int minutesInterval = i * 5;
        
        final created = await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000) + i,
            channelKey: 'reminder_channel',
            title: title,
            body: notes,
            notificationLayout: NotificationLayout.Default,
            category: NotificationCategory.Reminder,
          ),
          schedule: NotificationCalendar(
            year: scheduledDate.year,
            month: scheduledDate.month,
            day: scheduledDate.day,
            hour: scheduledDate.hour,
            minute: scheduledDate.minute + minutesInterval,
            second: 0,
            millisecond: 0,
            repeats: false,
          ),
        );

        if (!created) {
          throw Exception('Failed to schedule notification');
        }
      }
      
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to schedule reminder: ${e.toString()}'),
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
  }

  static int _getNotificationCount(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'once':
        return 1;
      case 'twice':
        return 2;
      case 'thrice':
        return 3;
      default:
        return 1;
    }
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}