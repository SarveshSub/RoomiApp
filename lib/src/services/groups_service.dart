import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> addOrUpdateGroup(String groupName, String userName) async {
    final ref = _database.ref('Groups/$groupName');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      List<String> users = List<String>.from(snapshot
          .child('users')
          .value as List);
      if (!users.contains(userName)) {
        users.add(userName);
        await ref.update({'users': users});
      }
    } else {
      await ref.set({
        'name': groupName,
        'users': [userName],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getGroups(List<String> groupNames) async {
    final ref = _database.ref('Groups');
    final snapshot = await ref.get();

    List<Map<String, dynamic>> groups = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        if (groupNames.contains(key)) {
          groups.add({'name': key, 'users': value['users']});
        }
      });
    }

    return groups;
  }

  Future<void> leaveGroup(String groupName, String userName) async {
    final ref = _database.ref('Groups/$groupName');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      List<String> users = List<String>.from(snapshot
          .child('users')
          .value as List);
      users.remove(userName);

      if (users.isEmpty) {
        await ref.remove();
      } else {
        await ref.update({'users': users});
      }
    }
  }
}