import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupsProvider with ChangeNotifier {
  List<String> _userGroups = [];
  String? _defaultGroup;

  List<String> get userGroups => _userGroups;
  String? get defaultGroup => _defaultGroup;

  GroupsProvider() {
    _loadUserGroups();
  }

  void _loadUserGroups() async {
    final prefs = await SharedPreferences.getInstance();
    _userGroups = prefs.getStringList('userGroups') ?? [];
    _defaultGroup = prefs.getString('defaultGroup');
    notifyListeners();
  }

  void addGroup(String groupName) async {
    _userGroups.add(groupName);
    if (_userGroups.length == 1) {
      _defaultGroup = groupName;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('defaultGroup', _defaultGroup!);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userGroups', _userGroups);
    notifyListeners();
  }

  void removeGroup(String groupName) async {
    _userGroups.remove(groupName);
    if (_defaultGroup == groupName) {
      _defaultGroup = _userGroups.isNotEmpty ? _userGroups.first : null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('defaultGroup', _defaultGroup ?? '');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('userGroups', _userGroups);
    notifyListeners();
  }

  void setDefaultGroup(String groupName) async {
    _defaultGroup = groupName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultGroup', _defaultGroup!);
    notifyListeners();
  }
}
