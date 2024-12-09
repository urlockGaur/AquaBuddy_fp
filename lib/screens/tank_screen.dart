import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        .where((tank) => tank.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  // Compute text color dynamically based on background color
  Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
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
                    final textColor = getTextColor(Color(tank.color));

                    return Card(
                      color: Color(tank.color),
                      margin: const EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            // Left Column: Tank Info
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tank.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: textColor),
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    'Water Type: ${tank.waterType}\nSize: ${tank.sizeInGallons} gallons',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: textColor),
                                  ),
                                ],
                              ),
                            ),
                            // Right Column: Tankmates and Menu
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Livestock:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: textColor),
                                  ),
                                  const SizedBox(height: 8.0),
                                  _buildSpeciesSection(
                                    FontAwesomeIcons.fish,
                                    tank.fishKeys,
                                    'fish',
                                    textColor,
                                  ),
                                  _buildSpeciesSection(
                                    FontAwesomeIcons.shrimp,
                                    tank.invertebrateKeys,
                                    'invertebrates',
                                    textColor,
                                  ),
                                  _buildSpeciesSection(
                                    FontAwesomeIcons.leaf,
                                    tank.plantKeys,
                                    'plants',
                                    textColor,
                                  ),
                                ],
                              ),
                            ),
                            // Menu and Delete Buttons
                            Column(
                              children: [
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.edit, color: textColor),
                                  onSelected: (value) {
                                    if (value == 'Edit Fish') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddFishScreen(tank: tank),
                                        ),
                                      );
                                    } else if (value == 'Edit Invertebrates') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddInvertebratesScreen(tank: tank),
                                        ),
                                      );
                                    } else if (value == 'Edit Plants') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddPlantsScreen(tank: tank),
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Edit Fish',
                                      child: Text('Edit Fish'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Edit Invertebrates',
                                      child: Text('Edit Invertebrates'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'Edit Plants',
                                      child: Text('Edit Plants'),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: textColor),
                                  onPressed: () {
                                    tank.delete();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildSpeciesSection(
      IconData icon, List<int> speciesKeys, String boxName, Color textColor) {
    final box = Hive.box<Species>(boxName);
    final speciesList = speciesKeys.map((key) => box.get(key)).whereType<Species>().toList();

    return Row(
      children: [
        FaIcon(icon, color: textColor, size: 20), // FontAwesome icons
        const SizedBox(width: 8.0),
        Expanded(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: speciesList.map((species) {
              return Chip(
                label: Text(
                  species.name,
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF1E1E1E),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
