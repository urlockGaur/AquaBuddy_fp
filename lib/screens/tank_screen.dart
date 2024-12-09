import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tank.dart';
import '../models/species.dart';
import 'add_fish_screen.dart';
import 'add_invertebrates_screen.dart';
import 'add_plants_screen.dart';
import 'add_tank_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TankScreen extends StatefulWidget {
  const TankScreen({super.key});

  @override
  _TankScreenState createState() => _TankScreenState();
}

class _TankScreenState extends State<TankScreen> {
  final tanksBox = Hive.box<Tank>('tanks');
  String searchQuery = '';

  List<Tank> getFilteredTanks() {
    final allTanks = tanksBox.values.toList();
    return allTanks
        .where((tank) =>
        tank.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Aquariums',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Tanks',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: tanksBox.listenable(),
              builder: (context, Box<Tank> box, _) {
                final filteredTanks = getFilteredTanks();

                if (filteredTanks.isEmpty) {
                  return Center(
                    child: Text(
                      'No tanks found.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredTanks.length,
                  itemBuilder: (context, index) {
                    final tank = filteredTanks[index];
                    return Card(
                      color: Color(tank.color),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              tank.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              'Water Type: ${tank.waterType}\nSize: ${tank.sizeInGallons} gallons',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                tank.delete();
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddFishScreen(tank: tank),
                                    ),
                                  );
                                },
                                child: const Text('Add Fish'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddInvertebratesScreen(tank: tank),
                                    ),
                                  );
                                },
                                child: const Text('Add Invertebrates'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddPlantsScreen(tank: tank),
                                    ),
                                  );
                                },
                                child: const Text('Add Plants'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0.0);
                  },
                );
              },
            ),
          ),
        ],
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
