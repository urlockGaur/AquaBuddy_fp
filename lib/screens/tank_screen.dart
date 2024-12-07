import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/tank.dart';
import 'add_tank_screen.dart';

class TankScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tanksBox = Hive.box<Tank>('tanks');

    return Scaffold(
      appBar: AppBar(
        title: Text('My Aquariums'),
      ),
      body: ValueListenableBuilder(
        valueListenable: tanksBox.listenable(),
        builder: (context, Box<Tank> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('No tanks added yet.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final tank = box.getAt(index);
              return Card(
                color: Color(tank!.color),
                child: ListTile(
                  title: Text(tank.name),
                  subtitle: Text('Water Type: ${tank.waterType}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => tank.delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTankScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
