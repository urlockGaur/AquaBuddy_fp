import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/task.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box<Task>('tasks');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No tasks added yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index);
              return CheckboxListTile(
                title: Text(task!.title, style: Theme.of(context).textTheme.bodyLarge),
                subtitle: Text(task.description, style: Theme.of(context).textTheme.bodyMedium),
                value: task.isCompleted,
                onChanged: (value) {
                  task.isCompleted = value!;
                  task.save();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Task Page
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

