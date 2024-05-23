import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String _userName = '';

  String get userName => _userName;

  void setUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }
}
