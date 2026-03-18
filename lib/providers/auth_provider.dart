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
    final savedIdKey = prefs.getString('saved_id_key');
    final savedLastFour = prefs.getString('saved_last_four');
    if (savedIdKey != null && savedLastFour != null) {
      try {
        _user = await MockService.login(savedIdKey, savedLastFour);
        notifyListeners();
      } catch (_) {
        await prefs.remove('saved_id_key');
        await prefs.remove('saved_last_four');
      }
    }
  }

  Future<bool> login(String idKey, String lastFour) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await MockService.login(idKey, lastFour);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_id_key', idKey);
      await prefs.setString('saved_last_four', lastFour);
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
    await prefs.remove('saved_id_key');
    await prefs.remove('saved_last_four');
    _user = null;
    notifyListeners();
  }
}
