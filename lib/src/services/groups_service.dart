import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> addOrUpdateGroup(String groupName, String user) async {
    final ref = _database.ref('Groups/$groupName');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      List<String> users = List<String>.from(snapshot.child('users').value as List);
      if (!users.contains(user)) {
        users.add(user);
        await ref.update({'users': users});
      }
    } else {
      await ref.set({
        'name': groupName,
        'users': [user],
      });
    }
  }

  Future<List<Map<String, dynamic>>> getUserGroups(User user) async {
    final ref = _database.ref('Groups');
    final snapshot = await ref.get();

    List<Map<String, dynamic>> groups = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        List<dynamic> users = value['users'];
        if (users.contains(user.email)) {
          groups.add({'name': key, 'users': users});
        }
      });
    }

    return groups;
  }
}
