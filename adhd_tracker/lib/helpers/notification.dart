import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:ADHD_Tracker/utils/color.dart';

class NotificationService {
   static const String REMINDER_CHANNEL_KEY = 'reminder_channel';
  static String _getSoundPath(String soundName) {
    if (Platform.isAndroid) {
      return 'resource://raw/res_$soundName';
    } else {
      return 'resource://raw/$soundName';
    }
  }

  static final Map<String, String> soundMap = {
    'Default': _getSoundPath('default_sound'),
    'Chime': _getSoundPath('chime'),
    'Water': _getSoundPath('water'),
    'Bell': _getSoundPath('bell'),
    'Electronic': _getSoundPath('electronic'),
  };
  static Future<bool> initializeNotifications() async {
    return await AwesomeNotifications().initialize(
      'resource://drawable/notification_icon',
      [
        NotificationChannel(
          channelKey: REMINDER_CHANNEL_KEY,
          channelName: 'Reminder Notifications',
          channelDescription: 'Channel for reminder notifications',
          defaultColor: AppTheme.upeiRed,
          ledColor: AppTheme.upeiRed,
          importance: NotificationImportance.High,
          soundSource: soundMap['Default'],
          playSound: true,
        ),
      ],
    );
  }

  static Future<void> scheduleDailyReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, // Fixed ID for daily reminder
        channelKey: REMINDER_CHANNEL_KEY,
        title: 'Daily Check-in',
        body: "It's time for your daily mindfulness check-in!",
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        bigPicture: 'resource://drawable/notification_icon',
        largeIcon: 'resource://drawable/notification_icon',
      ),
      schedule: NotificationCalendar(
        hour: 19,
        minute: 00,
        second: 0,
        repeats: true, 
      ),
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
              'To receive reminders, please allow notification permissions. Would you like to enable notifications?'),
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
        return await AwesomeNotifications()
            .requestPermissionToSendNotifications();
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
            content:
                Text('Notifications permission is required to set reminders'),
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

      final intervalMinutes = _getIntervalMinutes(frequency);

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
            customSound: soundMap[sound],
            bigPicture: 'resource://drawable/notification_icon',
            largeIcon: 'resource://drawable/notification_icon',
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
            allowWhileIdle: true,
          ),
        );

        if (!created) {
          throw Exception('Failed to schedule notification');
        }
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot create a notification for a past time. Please select a future time and try again.'),
          duration: Duration(seconds: 4),
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

  static int _getIntervalMinutes(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'once':
        return 0;
      case 'twice':
        return 30;
      case 'thrice':
        return 20;
      default:
        return 0;
    }
  }

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
