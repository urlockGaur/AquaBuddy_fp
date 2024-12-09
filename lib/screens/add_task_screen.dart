import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/tank.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedTankKey; // Use tank's Hive key

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
            // Task Title
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

            // Task Description
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

            // Due Date Picker
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Due Date'
                    : 'Due Date: ${_selectedDate.toString().split(' ')[0]}',
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

            // Tank Assignment Dropdown
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

            // Save Task Button
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTankKey != null) {
                  final tasksBox = Hive.box<Task>('tasks');
                  final newTask = Task(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: _selectedDate!,
                    isCompleted: false,
                    tankKey: _selectedTankKey, // Assign the selected tank key
                  );
                  tasksBox.add(newTask);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all fields.')),
                  );
                }
              },
              child: const Text('Save Task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
