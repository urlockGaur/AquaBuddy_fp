import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import the animation package
import '../models/task.dart';
import '../models/tank.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart'; // Import the edit screen

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
          // Add padding around the Tank Filter
          Padding(
            padding: const EdgeInsets.only(right: 8.0), // Add padding to move filter inward
            child: DropdownButton<int?>(
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
              dropdownColor: Theme.of(context).cardColor, // Match dropdown background to theme
              style: Theme.of(context).textTheme.bodyMedium, // Match text style to theme
              icon: const Icon(Icons.filter_list, color: Colors.white), // Add filter icon
            ),
          ),

          // Add padding between filters and align the Task Status Filter
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Adjust space between filters
            child: DropdownButton<TaskFilter>(
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
              dropdownColor: Theme.of(context).cardColor, // Match dropdown background to theme
              style: Theme.of(context).textTheme.bodyMedium, // Match text style to theme
              icon: const Icon(Icons.filter_alt, color: Colors.white), // Add filter icon
            ),
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    '${task.description}'
                        '\nDue: ${DateFormat('MMM d, yyyy h:mm a').format(task.dueDate.toLocal())}'
                        '${task.tankKey != null ? '\nTank: ${tanksBox.get(task.tankKey)?.name ?? 'Unknown'}' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: task.isCompleted ? Colors.grey : null,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) {
                      if (value == 'Edit Task') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );
                      } else if (value == 'Delete Task') {
                        setState(() {
                          task.delete();
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'Edit Task', child: Text('Edit Task')),
                      const PopupMenuItem(value: 'Delete Task', child: Text('Delete Task')),
                    ],
                  ),
                ),
              )
                  .animate() // Add the animation
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0.0);
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
