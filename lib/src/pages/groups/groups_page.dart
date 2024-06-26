import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomi/src/widgets/floating_add_button.dart';
import '../../services/groups_service.dart';
import '../../providers/groups_provider.dart';
import '../../providers/account_provider.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

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
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final groupsProvider = Provider.of<GroupsProvider>(context, listen: false);
    final userName = accountProvider.userName;
    if (userName.isNotEmpty) {
      final groups = await _groupService.getGroups(groupsProvider.userGroups);
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
                final accountProvider =
                    Provider.of<AccountProvider>(context, listen: false);
                final groupsProvider =
                    Provider.of<GroupsProvider>(context, listen: false);
                if (groupNameController.text.isNotEmpty &&
                    accountProvider.userName.isNotEmpty) {
                  await _groupService.addOrUpdateGroup(
                    groupNameController.text,
                    accountProvider.userName,
                  );
                  groupsProvider.addGroup(groupNameController.text);
                  setState(() {
                    _groups.add({
                      'name': groupNameController.text,
                      'users': [accountProvider.userName],
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
                final accountProvider =
                    Provider.of<AccountProvider>(context, listen: false);
                final groupsProvider =
                    Provider.of<GroupsProvider>(context, listen: false);
                await _groupService.leaveGroup(
                  group['name'],
                  accountProvider.userName,
                );
                groupsProvider.removeGroup(group['name']);
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

  void _setDefaultGroup(String groupName) {
    final groupsProvider = Provider.of<GroupsProvider>(context, listen: false);
    groupsProvider.setDefaultGroup(groupName);
  }

  @override
  Widget build(BuildContext context) {
    final groupsProvider = Provider.of<GroupsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          final group = _groups[index];
          final isDefault = group['name'] == groupsProvider.defaultGroup;
          return ListTile(
            title: Text(group['name']),
            subtitle: Text('Members: ${group['users'].length}'),
            tileColor: isDefault ? Colors.blue.withOpacity(0.1) : null,
            onTap: () {
              _showGroupDetailsDialog(group);
            },
            onLongPress: () {
              _setDefaultGroup(group['name']);
            },
          );
        },
      ),
      floatingActionButton: FloatingAddButton(
        onPressed: _showAddGroupDialog,
      ),
    );
  }
}
