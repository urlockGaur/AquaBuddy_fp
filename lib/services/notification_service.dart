import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones(); // Initialize timezones
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(
      initializationSettings,
    );

    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local); // Convert to TZDateTime
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'Main channel notifications',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
