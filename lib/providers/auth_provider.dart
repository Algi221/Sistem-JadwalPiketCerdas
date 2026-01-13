import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../data/user_model.dart';

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

  void logout() {
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
