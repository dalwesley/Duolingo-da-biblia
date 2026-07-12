import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Lembretes diários para estudar.
class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _available = true;

  Future<void> init() async {
    if (_initialized || !_available) return;
    tz_data.initializeTimeZones();

    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      _initialized = true;
    } on MissingPluginException {
      _available = false;
    } catch (_) {
      _available = false;
    }
  }

  Future<void> scheduleDailyReminder({required bool enabled, int hour = 19, int minute = 0}) async {
    await init();
    if (!_available || !_initialized) return;
    const id = 1;
    if (!enabled) {
      await _plugin.cancel(id);
      return;
    }

    await _plugin.zonedSchedule(
      id,
      'Trilha',
      'Sua jornada pela Palavra te espera. Uma missão hoje?',
      _nextInstance(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'trilha_daily',
          'Lembretes diários',
          channelDescription: 'Lembrete para estudar a Bíblia',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }
}
