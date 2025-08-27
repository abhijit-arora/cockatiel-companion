import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// THIS IS THE CORRECTED IMPORT PATH
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // For Android 13 (API 33) and above
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
    // For iOS
    else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      await iOSImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // --- NOTIFICATION SCHEDULING LOGIC ---
  Future<void> scheduleAnniversaryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime eventDate,
    int leadDays = 7, // Our hardcoded lead time for now
  }) async {
    // 1. Calculate the next occurrence of the anniversary.
    final now = DateTime.now();
    DateTime nextAnniversary = DateTime(now.year, eventDate.month, eventDate.day);

    // If this year's anniversary has already passed, schedule for next year.
    if (nextAnniversary.isBefore(now)) {
      nextAnniversary = DateTime(now.year + 1, eventDate.month, eventDate.day);
    }

    // 2. Subtract the lead time to get the notification date.
    final notificationDate = nextAnniversary.subtract(Duration(days: leadDays));

    // 3. Ensure the notification date is still in the future.
    if (notificationDate.isBefore(now)) {
      debugPrint('Skipping notification ID $id because its schedule date is in the past.');
      return;
    }

    // 4. Convert to a timezone-aware TZDateTime.
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
      notificationDate,
      tz.local, // Use the device's local timezone.
    );

    // 5. Define notification details.
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'anniversary_channel', // A unique channel ID
      'Anniversary Reminders', // A user-facing channel name
      channelDescription: 'Reminders for your birds\' special days',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails();
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // 6. Schedule the notification.
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    debugPrint('Successfully scheduled notification ID $id for $scheduledDate');
  }

  // --- PLACEHOLDER FOR CANCELLATION LOGIC ---
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    debugPrint('Cancelled notification with id: $id');
  }
}