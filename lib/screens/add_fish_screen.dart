import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/species.dart';
import '../models/tank.dart';

class AddFishScreen extends StatefulWidget {
  final Tank tank; // Tank to which fish will be added

  const AddFishScreen({Key? key, required this.tank}) : super(key: key);

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
      } else {
        widget.tank.fishKeys = List.from(widget.tank.fishKeys)..add(fishKey);
      }
      widget.tank.save(); // Save changes to Hive
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
          // Display selected fish
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
                  height: 100.0, // Adjust height as needed
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: getSelectedFish().map((species) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                species.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                species.scientificName,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Display available fish with checkboxes
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
                      trailing: IconButton(
                        icon: Icon(
                          isInTank ? Icons.check_box : Icons.check_box_outline_blank,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () => toggleFishInTank(species),
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
