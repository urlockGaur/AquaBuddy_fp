import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/species.dart';
import '../models/tank.dart';
import '../utils/alert_utils.dart';

class AddPlantsScreen extends StatefulWidget {
  final Tank tank;

  const AddPlantsScreen({super.key, required this.tank});

  @override
  _AddPlantsScreenState createState() => _AddPlantsScreenState();
}

class _AddPlantsScreenState extends State<AddPlantsScreen> {
  late Box<Species> plantBox;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    plantBox = Hive.box<Species>('plants');
  }

  List<Species> getFilteredPlants() {
    final allPlants = plantBox.values.toList();
    return allPlants.where((species) {
      final nameLower = species.name.toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  List<Species> getSelectedPlants() {
    return widget.tank.plantKeys.map((key) => plantBox.get(key)!).toList();
  }

  void togglePlantInTank(Species species) {
    final plantKey = species.key as int;

    setState(() {
      if (widget.tank.plantKeys.contains(plantKey)) {
        widget.tank.plantKeys = List.from(widget.tank.plantKeys)..remove(plantKey);
        showCustomFlushbar(
          context,
          'Removed ${species.name} from tank.',
          icon: Icons.remove_circle,
        );
      } else {
        widget.tank.plantKeys = List.from(widget.tank.plantKeys)..add(plantKey);
        showCustomFlushbar(
          context,
          'Added ${species.name} to tank.',
          icon: Icons.add_circle,
        );
      }
      widget.tank.save();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Plants'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Plants',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const Divider(),
          // Selected Plants Display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Plants:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 50.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: getSelectedPlants().map((species) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          label: Text(
                            species.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onDeleted: () => togglePlantInTank(species),
                          backgroundColor: const Color(0xFF1E1E1E),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Available Plants List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: plantBox.listenable(),
              builder: (context, Box<Species> box, _) {
                final filteredPlants = getFilteredPlants();

                if (filteredPlants.isEmpty) {
                  return const Center(
                    child: Text('No plants found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredPlants.length,
                  itemBuilder: (context, index) {
                    final species = filteredPlants[index];
                    final isInTank = widget.tank.plantKeys.contains(species.key as int);

                    return ListTile(
                      title: Text(species.name),
                      subtitle: Text(species.scientificName),
                      trailing: Checkbox(
                        value: isInTank,
                        onChanged: (_) => togglePlantInTank(species),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
