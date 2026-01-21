import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'notification_helper.dart';
import 'dart:io';

class CalendarHelper {
  static Future<bool> addPiketToCalendar({
    required String studentName,
    required String day,
    required DateTime date,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return false;

    try {
      final dayMap = {
        'Monday': 'Senin', 'Tuesday': 'Selasa', 'Wednesday': 'Rabu', 
        'Thursday': 'Kamis', 'Friday': 'Jumat',
      };

      final indoDay = dayMap[_getDayName(date)] ?? day;

      final Event event = Event(
        title: '🧹 JADWAL PIKET: $indoDay',
        description: '📌 PENGINGAT PIKET CERDAS\n\nHalo $studentName,\n\nHari ini jadwal piket kamu! 💪',
        location: 'Ruang Kelas 11-J',
        startDate: DateTime(date.year, date.month, date.day, 6, 15),
        endDate: DateTime(date.year, date.month, date.day, 7, 0),
        allDay: false,
        iosParams: const IOSParams(reminder: Duration(minutes: 30)),
        androidParams: const AndroidParams(emailInvites: []),
      );

      return await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      return false;
    }
  }

  static Future<int> addAllPiketSchedules({
    required String studentName,
    required String piketDay,
    int weeksAhead = 4,
  }) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) return 0;

    int successCount = 0;
    final today = DateTime.now();
    
    // Kirim notifikasi konfirmasi langsung biar user tau aplikasi kerja
    await NotificationHelper().showInstantNotification(
      '📅 Sinkronisasi Dimulai', 
      'Tunggu sebentar, sedang menyetel alarm untuk 4 minggu ke depan...'
    );

    for (int i = 0; i < weeksAhead * 7; i++) {
      final checkDate = today.add(Duration(days: i));
      if (_convertToIndonesian(_getDayName(checkDate)) == piketDay) {
        
        // Add ke kalender HP
        await addPiketToCalendar(studentName: studentName, day: piketDay, date: checkDate);

        // Setel Alarm Berbunyi (Jam 05:45)
        final alarmTime = DateTime(checkDate.year, checkDate.month, checkDate.day, 5, 45);
        if (alarmTime.isAfter(today)) {
           await NotificationHelper().scheduleAlarm(
            i, '⏰ ALARM PIKET: $piketDay', 'Bangun! Jadwal piket kamu jam 06:15 nanti.', alarmTime
          );
           successCount++;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return successCount;
  }

  static String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  static String _convertToIndonesian(String englishDay) {
    const dayMap = {
      'Monday': 'Senin', 'Tuesday': 'Selasa', 'Wednesday': 'Rabu', 
      'Thursday': 'Kamis', 'Friday': 'Jumat', 'Saturday': 'Sabtu', 'Sunday': 'Minggu',
    };
    return dayMap[englishDay] ?? englishDay;
  }
}
