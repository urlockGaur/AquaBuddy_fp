import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/species.dart';
import '../models/tank.dart';

class AddFishScreen extends StatefulWidget {
  final Tank tank;

  const AddFishScreen({super.key, required this.tank});

  @override
  _AddFishScreenState createState() => _AddFishScreenState();
}

class _AddFishScreenState extends State<AddFishScreen> {
  late Box<Species> fishBox;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fishBox = Hive.box<Species>('fish');
  }

  List<Species> getFilteredFish() {
    final allFish = fishBox.values.toList();
    return allFish.where((species) {
      final nameLower = species.name.toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  List<Species> getSelectedFish() {
    return widget.tank.fishKeys.map((key) => fishBox.get(key)!).toList();
  }

  void toggleFishInTank(Species species) {
    final fishKey = species.key as int;

    setState(() {
      if (widget.tank.fishKeys.contains(fishKey)) {
        widget.tank.fishKeys = List.from(widget.tank.fishKeys)..remove(fishKey);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed ${species.name} from tank.')),
        );
      } else {
        widget.tank.fishKeys = List.from(widget.tank.fishKeys)..add(fishKey);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${species.name} to tank.')),
        );
      }
      widget.tank.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fish'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Fish',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const Divider(),
          // Selected Fish Display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Fish:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 50.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: getSelectedFish().map((species) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          label: Text(
                            species.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onDeleted: () => toggleFishInTank(species),
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
          // Available Fish List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: fishBox.listenable(),
              builder: (context, Box<Species> box, _) {
                final filteredFish = getFilteredFish();

                if (filteredFish.isEmpty) {
                  return const Center(
                    child: Text('No fish found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredFish.length,
                  itemBuilder: (context, index) {
                    final species = filteredFish[index];
                    final isInTank = widget.tank.fishKeys.contains(species.key as int);

                    return ListTile(
                      title: Text(species.name),
                      subtitle: Text(species.scientificName),
                      trailing: Checkbox(
                        value: isInTank,
                        onChanged: (_) => toggleFishInTank(species),
                        activeColor: Theme.of(context).primaryColor, // Primary color for checkbox
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
