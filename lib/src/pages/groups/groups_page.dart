import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/groups_service.dart';
import '../../providers/auth_provider.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({Key? key}) : super(key: key);

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
      final groups = await _groupService.getUserGroups(authProvider.user!);
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
          title: const Text('Add Group'),
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
              child: const Text('Add'),
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                if (groupNameController.text.isNotEmpty && authProvider.user != null) {
                  await _groupService.addOrUpdateGroup(groupNameController.text, authProvider.user!);
                  Navigator.of(context).pop();
                  _loadGroups();
                }
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
        title: const Text('Groups'),
      ),
      body: ListView.builder(
        itemCount: _groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_groups[index]['name']),
            subtitle: Text('Members: ${_groups[index]['users'].join(', ')}'),
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
