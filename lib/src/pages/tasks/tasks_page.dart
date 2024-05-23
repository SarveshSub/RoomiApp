import 'package:flutter/material.dart';
import '../../widgets/floating_add_button.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  void _showAddCategoryDialog(context) {
    const s = SnackBar(
      content: Text('Add a task dialog'),
    );
    ScaffoldMessenger.of(context).showSnackBar(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      floatingActionButton: FloatingAddButton(
        onPressed: () => _showAddCategoryDialog(context),
      ),
    );
  }
}
