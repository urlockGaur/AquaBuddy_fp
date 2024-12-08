import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/tank.dart';
import 'add_tank_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TankScreen extends StatelessWidget {
  const TankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tanksBox = Hive.box<Tank>('tanks');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Aquariums',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: tanksBox.listenable(),
        builder: (context, Box<Tank> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text(
                'No tanks added yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final tank = box.getAt(index);
              return Card(
                color: Color(tank!.color),
                child: ListTile(
                  title: Text(tank.name, style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(
                    'Water Type: ${tank.waterType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => tank.delete(),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0.0);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTankScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
