import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive/hive.dart';
import '../models/tank.dart';
import 'package:uuid/uuid.dart';

class AddTankScreen extends StatefulWidget {
  const AddTankScreen({super.key});

  @override
  _AddTankScreenState createState() => _AddTankScreenState();
}

class _AddTankScreenState extends State<AddTankScreen> {
  String _tankName = '';
  Color _selectedColor = Colors.blue;
  String _waterType = 'Freshwater';
  int _sizeInGallons = 0; // New field for tank size

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Tank', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Tank Name',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              onChanged: (value) => _tankName = value,
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Tank Size (in gallons)',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => _sizeInGallons = int.tryParse(value) ?? 0,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Water Type:', style: Theme.of(context).textTheme.bodyMedium),
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
            Text('Tank Color:', style: Theme.of(context).textTheme.bodyMedium),
            BlockPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) => setState(() => _selectedColor = color),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_tankName.isNotEmpty && _sizeInGallons > 0) {
                  final tank = Tank(
                    name: _tankName,
                    waterType: _waterType,
                    color: _selectedColor.value,
                    sizeInGallons: _sizeInGallons,
                  );

                  final tanksBox = Hive.box<Tank>('tanks');
                  await tanksBox.add(tank); // Save tank to Hive box
                }

                Navigator.pop(context); // Return to TankScreen
              },
              child: const Text('Save Tank'),
            ),
          ],
        ),
      ),
    );
  }
}
