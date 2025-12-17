import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  // 1. Initialize at the start of the app (main.dart)
  static Future<void> init() async {
    tz.initializeTimeZones();

    String timeZoneName = 'Asia/Jakarta'; // default fallback

    try {
      // Ambil timezone dari sistem (API BARU)
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      timeZoneName = tzInfo.identifier;
      // atau: tzInfo.identifier
    } catch (e) {
      print(
        "Failed to get system timezone, falling back to Asia/Jakarta: $e",
      );
    }

    // Set timezone for the timezone package
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Final fallback if the timezone is strange
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notification.initialize(settings);
  }

  // 2. Function to Schedule a Notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // If the time has already passed, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notification.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_channel_id',
          'Goal Reminders',
          channelDescription: 'Notifications for goal deadlines',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 3. Cancel notification
  static Future<void> cancelNotification(int id) async {
    await _notification.cancel(id);
  }

  // 4. Cancel all notifications
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}
