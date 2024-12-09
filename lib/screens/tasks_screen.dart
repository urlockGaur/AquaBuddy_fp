import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/tank.dart';
import 'add_task_screen.dart'; // Import the AddTaskScreen
import '../services/notification_service.dart';

enum TaskFilter { all, completed, incomplete }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final tasksBox = Hive.box<Task>('tasks');
  final tanksBox = Hive.box<Tank>('tanks');
  TaskFilter _filter = TaskFilter.all;
  int? _selectedTankKey; // Updated to match task.tankKey type

  // Get tasks based on the selected filter and tank
  List<Task> _getFilteredTasks() {
    final allTasks = tasksBox.values.toList();
    var filteredTasks = allTasks;

    if (_selectedTankKey != null) {
      filteredTasks = filteredTasks.where((task) => task.tankKey == _selectedTankKey).toList();
    }

    switch (_filter) {
      case TaskFilter.completed:
        return filteredTasks.where((task) => task.isCompleted).toList();
      case TaskFilter.incomplete:
        return filteredTasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return filteredTasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          // Filter by Tank
          DropdownButton<int?>(
            value: _selectedTankKey,
            onChanged: (value) {
              setState(() {
                _selectedTankKey = value;
              });
            },
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Tanks'),
              ),
              ...tanksBox.keys.cast<int>().map((key) {
                final tank = tanksBox.get(key);
                return DropdownMenuItem(
                  value: key,
                  child: Text(tank!.name),
                );
              }),
            ],
          ),

          // Filter by Task Status
          DropdownButton<TaskFilter>(
            value: _filter,
            onChanged: (value) {
              setState(() {
                _filter = value!;
              });
            },
            items: const [
              DropdownMenuItem(value: TaskFilter.all, child: Text('All Tasks')),
              DropdownMenuItem(value: TaskFilter.completed, child: Text('Completed Tasks')),
              DropdownMenuItem(value: TaskFilter.incomplete, child: Text('Incomplete Tasks')),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, _) {
          final tasks = _getFilteredTasks();
          if (tasks.isEmpty) {
            return Center(
              child: Text(
                'No tasks found.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(
                  task.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${task.description}\nDue: ${task.dueDate.toLocal()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        setState(() {
                          task.isCompleted = value!;
                          task.save();
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          task.delete();
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddTaskScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
        foregroundColor: Theme.of(context).floatingActionButtonTheme.foregroundColor,
      ),
    );
  }
}
