import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsProvider with ChangeNotifier {
  List<String> _userGroups = [];

  List<String> get userGroups => _userGroups;

  GroupsProvider() {
    _loadUserGroups();
  }

  void _loadUserGroups() async {
    final prefs = await SharedPreferences.getInstance();
    _userGroups = prefs.getStringList('userGroups') ?? [];
    notifyListeners();
  }

  void addGroup(String groupName) async {
    _userGroups.add(groupName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userGroups', _userGroups);
    notifyListeners();
  }

  void removeGroup(String groupName) async {
    _userGroups.remove(groupName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userGroups', _userGroups);
    notifyListeners();
  }
}
