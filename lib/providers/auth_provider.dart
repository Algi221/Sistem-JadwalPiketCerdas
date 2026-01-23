import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../database/user_model.dart';
import '../utils/notification_helper.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<bool> login(String nipd, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await DatabaseHelper.instance.getUser(nipd, password);
      if (user != null) {
        _currentUser = user;
        
        // --- JADWALKAN ALARM JIKA SISWA ---
        if (user.role == 'siswa') {
          await _setupPiketAlarms(user.id!);
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("Login Error: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _setupPiketAlarms(int userId) async {
    try {
      final schedules = await DatabaseHelper.instance.getSchedulesByUser(userId);
      final notificationHelper = NotificationHelper();
      
      // Bersihin dulu alarm lama biar gak double
      await notificationHelper.cancelAllNotifications();
      
      for (var schedule in schedules) {
        int weekday = _getDayNumber(schedule.day);
        if (weekday != -1) {
          await notificationHelper.scheduleWeeklyPiketAlarm(
            schedule.id ?? userId + weekday, // ID unik
            "Waktunya Piket! 🧹",
            "Halo ${_currentUser?.name}, jangan lupa hari ini jadwal piket kamu ya!",
            weekday,
          );
        }
      }
    } catch (e) {
      print("Error scheduling alarms: $e");
    }
  }

  int _getDayNumber(String day) {
    switch (day.toLowerCase()) {
      case 'senin': return DateTime.monday;
      case 'selasa': return DateTime.tuesday;
      case 'rabu': return DateTime.wednesday;
      case 'kamis': return DateTime.thursday;
      case 'jumat': return DateTime.friday;
      case 'sabtu': return DateTime.saturday;
      case 'minggu': return DateTime.sunday;
      default: return -1;
    }
  }

  void logout() {
    // Hapus semua alarm pas logout biar gak ganggu user lain
    NotificationHelper().cancelAllNotifications();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> changePassword(String newPassword) async {
      if (_currentUser == null || _currentUser!.id == null) return false;
      
      try {
          await DatabaseHelper.instance.updateUserPassword(_currentUser!.id!, newPassword);
          // update state lokal kalau perlu, tapi agak ribet tanpa copyWith sih
          // untuk sekarang, asumsi logout/login ulang atau percaya aja sama update DB
          // idealnya: _currentUser = _currentUser.copyWith(password: newPassword);
          return true;
      } catch (e) {
          return false;
      }
  }
}
