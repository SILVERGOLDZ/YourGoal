import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  // 1. Inisialisasi di awal aplikasi (main.dart)
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
        "Gagal mengambil timezone sistem, fallback ke Asia/Jakarta: $e",
      );
    }

    // Set timezone ke package timezone
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Fallback terakhir jika timezone aneh
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notification.initialize(settings);
  }

  // 2. Fungsi Menjadwalkan Notifikasi
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Jika waktu sudah lewat, jangan jadwalkan
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
          channelDescription: 'Notifikasi untuk deadline goal',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // 3. Batalkan notifikasi
  static Future<void> cancelNotification(int id) async {
    await _notification.cancel(id);
  }

  // 4. Batalkan semua notifikasi
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}
