import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/tank.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task; // Pass the task to edit

  const EditTaskScreen({super.key, required this.task});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _selectedTankKey;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description);
    _selectedDate = widget.task.dueDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.task.dueDate);
    _selectedTankKey = widget.task.tankKey;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tanksBox = Hive.box<Tank>('tanks');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Task',
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
                    : 'Due Date: ${_selectedDate!.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
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

            // Time Picker
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
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                  );
                  setState(() {
                    _selectedTime = selectedTime;
                  });
                },
              ),
            ),
            const SizedBox(height: 10.0),

            // Tank Assignment Dropdown
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: 'Assign to Tank (Optional)',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                border: const OutlineInputBorder(),
              ),
              value: _selectedTankKey,
              items: [
                const DropdownMenuItem(value: null, child: Text('No Tank')),
                ...tanksBox.keys.cast<int>().map((key) {
                  final tank = tanksBox.get(key);
                  return DropdownMenuItem(
                    value: key,
                    child: Text(
                      tank!.name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedTankKey = value;
                });
              },
            ),
            const SizedBox(height: 20.0),

            // Save Changes Button
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _selectedDate != null &&
                    _selectedTime != null) {
                  // Combine date and time
                  final updatedDate = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  widget.task.title = _titleController.text;
                  widget.task.description = _descriptionController.text;
                  widget.task.dueDate = updatedDate;
                  widget.task.tankKey = _selectedTankKey;
                  widget.task.save(); // Save updates to Hive
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill out all required fields.')),
                  );
                }
              },
              child: const Text('Save Changes'),
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
