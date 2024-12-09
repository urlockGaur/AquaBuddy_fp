import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/species.dart';
import '../models/tank.dart';

class AddInvertebratesScreen extends StatefulWidget {
  final Tank tank;

  const AddInvertebratesScreen({super.key, required this.tank});

  @override
  _AddInvertebratesScreenState createState() => _AddInvertebratesScreenState();
}

class _AddInvertebratesScreenState extends State<AddInvertebratesScreen> {
  late Box<Species> invertebrateBox;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    invertebrateBox = Hive.box<Species>('invertebrates');
  }

  List<Species> getFilteredInvertebrates() {
    final allInvertebrates = invertebrateBox.values.toList();
    return allInvertebrates.where((species) {
      final nameLower = species.name.toLowerCase();
      final queryLower = searchQuery.toLowerCase();
      return nameLower.contains(queryLower);
    }).toList();
  }

  List<Species> getSelectedInvertebrates() {
    return widget.tank.invertebrateKeys.map((key) => invertebrateBox.get(key)!).toList();
  }

  void toggleInvertebrateInTank(Species species) {
    final invertebrateKey = species.key as int;

    setState(() {
      if (widget.tank.invertebrateKeys.contains(invertebrateKey)) {
        widget.tank.invertebrateKeys = List.from(widget.tank.invertebrateKeys)
          ..remove(invertebrateKey);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed ${species.name} from tank.')),
        );
      } else {
        widget.tank.invertebrateKeys = List.from(widget.tank.invertebrateKeys)
          ..add(invertebrateKey);
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
        title: const Text('Add Invertebrates'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Invertebrates',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const Divider(),
          // Selected Invertebrates Display
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Invertebrates:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 50.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: getSelectedInvertebrates().map((species) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          label: Text(
                            species.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onDeleted: () => toggleInvertebrateInTank(species),
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
          // Available Invertebrates List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: invertebrateBox.listenable(),
              builder: (context, Box<Species> box, _) {
                final filteredInvertebrates = getFilteredInvertebrates();

                if (filteredInvertebrates.isEmpty) {
                  return const Center(
                    child: Text('No invertebrates found.'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredInvertebrates.length,
                  itemBuilder: (context, index) {
                    final species = filteredInvertebrates[index];
                    final isInTank = widget.tank.invertebrateKeys.contains(species.key as int);

                    return ListTile(
                      title: Text(species.name),
                      subtitle: Text(species.scientificName),
                      trailing: Checkbox(
                        value: isInTank,
                        onChanged: (_) => toggleInvertebrateInTank(species),
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
