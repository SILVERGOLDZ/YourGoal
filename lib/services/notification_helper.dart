import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  // 1. Inisialisasi di awal aplikasi (main.dart)
  static Future<void> init() async {
    tz.initializeTimeZones();
    String timeZoneName;
    try {
      // Coba ambil timezone dari sistem
      timeZoneName = await FlutterTimezone.getLocalTimezone();
    } catch (e) {
      // Jika gagal (seperti error di Windows tadi), gunakan default Jakarta
      print("Gagal mengambil timezone, menggunakan fallback Asia/Jakarta");
      timeZoneName = 'Asia/Jakarta';
    }
    // Validasi apakah timezone dikenali oleh database timezone
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      // Jika string timezone sistem aneh, fallback lagi
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
    // -----------------------------
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Tambahkan setting Linux/Windows agar tidak null (Opsional tapi bagus)
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      // iOS, macOS, linux bisa ditambah di sini jika perlu
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

  // 3. Batalkan notifikasi (jika goal selesai/dihapus)
  static Future<void> cancelNotification(int id) async {
    await _notification.cancel(id);
  }

  // 4. Batalkan semua (opsional, untuk refresh)
  static Future<void> cancelAll() async {
    await _notification.cancelAll();
  }
}