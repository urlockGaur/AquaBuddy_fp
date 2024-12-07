import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddTankScreen extends StatefulWidget {
  const AddTankScreen({super.key});

  @override
  _AddTankScreenState createState() => _AddTankScreenState();
}

class _AddTankScreenState extends State<AddTankScreen> {
  String _tankName = '';
  Color _selectedColor = Colors.blue;
  String _waterType = 'Freshwater';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Tank'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Tank Name'),
              onChanged: (value) => _tankName = value,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Water Type:'),
                DropdownButton<String>(
                  value: _waterType,
                  items: ['Freshwater', 'Saltwater']
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _waterType = value!),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Tank Color:'),
            BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Save tank details to database
                Navigator.pop(context);
              },
              child: const Text('Save Tank'),
            ),
          ],
        ),
      ),
    );
  }
}
