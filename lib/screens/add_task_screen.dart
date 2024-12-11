import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/tank.dart';
import '../models/user.dart';
import '../utils/alert_utils.dart';
import '../utils/badge_utils.dart';
import '../screens/create_account_screen.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedTankKey;

  @override
  Widget build(BuildContext context) {
    final tanksBox = Hive.box<Tank>('tanks');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Task',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10.0),
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Due Date'
                    : 'Due Date: ${_selectedDate!.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {
                    _selectedDate = selectedDate;
                  });
                },
              ),
            ),
            const SizedBox(height: 10.0),
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : 'Time: ${_selectedTime!.format(context)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.access_time, color: Colors.white),
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  setState(() {
                    _selectedTime = selectedTime;
                  });
                },
              ),
            ),
            const SizedBox(height: 10.0),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Assign to Tank',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              items: tanksBox.keys.cast<int>().map((key) {
                final tank = tanksBox.get(key);
                return DropdownMenuItem(
                  value: key,
                  child: Text(
                    tank!.name,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTankKey = value;
                });
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null) {
                  final tasksBox = Hive.box<Task>('tasks');
                  final scheduledDate = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  final newTask = Task(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: scheduledDate,
                    isCompleted: false,
                    tankKey: _selectedTankKey,
                  );

                  tasksBox.add(newTask);

                  final userBox = Hive.box<User>('users');
                  if (userBox.isNotEmpty) {
                    incrementActivityCount(activityType: 'task', userBox: userBox);
                    showCustomFlushbar(context, 'Task added successfully!',
                        icon: Icons.task_alt);
                  } else {
                    final bool? created = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateAccountScreen(),
                      ),
                    );
                    if (created == true) {
                      incrementActivityCount(activityType: 'task', userBox: userBox);
                      showCustomFlushbar(context, 'Task added successfully after account creation!',
                          icon: Icons.task_alt);
                    }
                  }

                  Navigator.pop(context);
                } else {
                  showCustomFlushbar(context, 'Please fill out all fields!',
                      icon: Icons.error, duration: Duration(seconds: 2));
                }
              },
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
