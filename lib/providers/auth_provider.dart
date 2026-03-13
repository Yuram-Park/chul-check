import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/mock_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('saved_phone');
    if (savedPhone != null) {
      try {
        _user = await MockService.login(savedPhone);
        notifyListeners();
      } catch (_) {
        await prefs.remove('saved_phone');
      }
    }
  }

  Future<bool> login(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await MockService.login(phone);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_phone', phone);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_phone');
    _user = null;
    notifyListeners();
  }
}
