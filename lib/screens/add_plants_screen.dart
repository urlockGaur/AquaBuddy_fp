import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/species.dart';
import '../models/tank.dart';

class AddPlantsScreen extends StatefulWidget {
  final Tank tank;

  const AddPlantsScreen({Key? key, required this.tank}) : super(key: key);

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
                    final isInTank =
                    widget.tank.plantKeys.contains(species.key as int);

                    return ListTile(
                      title: Text(species.name),
                      subtitle: Text(species.scientificName),
                      trailing: IconButton(
                        icon: Icon(
                          isInTank ? Icons.check_box : Icons.check_box_outline_blank,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isInTank) {
                              widget.tank.plantKeys.remove(species.key as int);
                            } else {
                              widget.tank.plantKeys.add(species.key as int);
                            }
                            widget.tank.save();
                          });
                        },
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
