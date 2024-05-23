import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/groups_service.dart';
import '../../providers/auth_provider.dart';

class GroupsPage extends StatefulWidget {
  final List<String> userGroups;

  const GroupsPage({super.key, required this.userGroups});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<Map<String, dynamic>> _groups = [];
  final GroupService _groupService = GroupService();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final groups = await _groupService.getGroups(widget.userGroups);
      setState(() {
        _groups = groups;
      });
    }
  }

  void _showAddGroupDialog() {
    final TextEditingController groupNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Group'),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(labelText: 'Group Name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
                if (groupNameController.text.isNotEmpty &&
                    authProvider.user != null) {
                  await _groupService.addOrUpdateGroup(
                    groupNameController.text,
                    authProvider.userName,
                  );
                  final prefs = await SharedPreferences.getInstance();
                  final userGroups = prefs.getStringList('userGroups') ?? [];
                  userGroups.add(groupNameController.text);
                  await prefs.setStringList('userGroups', userGroups);
                  setState(() {
                    _groups.add({
                      'name': groupNameController.text,
                      'users': [authProvider.userName],
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showGroupDetailsDialog(Map<String, dynamic> group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(group['name']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Members:'),
              ...group['users'].map((user) => Text(user)).toList(),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Invite Member'),
              onPressed: () {
                // TODO: Implement invite member functionality
              },
            ),
            TextButton(
              child: const Text('Leave Group'),
              onPressed: () async {
                final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
                await _groupService.leaveGroup(
                  group['name'],
                  authProvider.userName,
                );
                final prefs = await SharedPreferences.getInstance();
                final userGroups = prefs.getStringList('userGroups') ?? [];
                userGroups.remove(group['name']);
                await prefs.setStringList('userGroups', userGroups);
                setState(() {
                  _groups.removeWhere((g) => g['name'] == group['name']);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_groups[index]['name']),
            subtitle: Text('Members: ${_groups[index]['users'].length}'),
            onTap: () {
              _showGroupDetailsDialog(_groups[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}