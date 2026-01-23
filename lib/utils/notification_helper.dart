import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    
    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Menampilkan notifikasi instan (Head-up)
  Future<void> showInstantNotification(String title, String body) async {
    if (kIsWeb) return;
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'piket_urgent_channel',
      'Piket Urgent',
      channelDescription: 'Notifikasi mendesak untuk piket',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      playSound: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
        
    await flutterLocalNotificationsPlugin.show(
      99,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  /// Jadwalkan alarm tunggal pada waktu tertentu
  Future<void> scheduleAlarm(int id, String title, String body, DateTime scheduledTime) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'piket_alarm_channel',
          'Piket Alarms',
          channelDescription: 'Alarm pengingat piket (Berbunyi)',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          visibility: NotificationVisibility.public,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Jadwalkan alarm mingguan (Untuk Jam 4 Sore)
  Future<void> scheduleWeeklyPiketAlarm(int id, String title, String body, int weekday) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    // Cari waktu jam 4 sore hari ini atau minggu depan pada hari yang ditentukan
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      16, // Jam 4 sore (16:00)
      0,
    );

    // Hitung selisih hari
    int dayDiff = weekday - scheduledDate.weekday;
    if (dayDiff < 0) {
      dayDiff += 7;
    } else if (dayDiff == 0 && scheduledDate.isBefore(now)) {
      dayDiff = 7;
    }
    
    scheduledDate = scheduledDate.add(Duration(days: dayDiff));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'piket_daily_reminder',
          'Pengingat Piket Harian',
          channelDescription: 'Alarm pengingat piket jam 4 sore',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'piket',
          visibility: NotificationVisibility.public,
          fullScreenIntent: true, // Biar ngambang/heads-up
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Ulang tiap mingggu
    );
    
    print("Alarm dijadwalkan untuk ID $id pada $scheduledDate (Repeat Mingguan)");
  }

  /// Menampilkan notifikasi yang TIDAK BISA DICLOSE (Ongoing)
  Future<void> showPersistentNotification(int id, String title, String body) async {
     if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return;

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
       const NotificationDetails(
        android: AndroidNotificationDetails(
          'piket_persistent_channel',
          'Notifikasi Wajib (Piket)',
          channelDescription: 'Notifikasi yang muncul saat belum lapor piket',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true,
          autoCancel: false,
          playSound: true,
          enableVibration: true,
          color: Color(0xFFFF5252),
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
