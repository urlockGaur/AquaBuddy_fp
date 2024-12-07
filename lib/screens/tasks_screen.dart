import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/task.dart';

class TasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box<Task>('tasks');

    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No tasks added yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index);
              return CheckboxListTile(
                title: Text(task!.title),
                subtitle: Text(task.description),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
