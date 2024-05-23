import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountProvider with ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  AccountProvider() {
    _loadUserName();
  }

  void _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('userName') ?? '';
    notifyListeners();
  }

  void setUserName(String userName) async {
    _userName = userName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', _userName);
    notifyListeners();
  }
}
