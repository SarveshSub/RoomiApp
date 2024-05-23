import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}