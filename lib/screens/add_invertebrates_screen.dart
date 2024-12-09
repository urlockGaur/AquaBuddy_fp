import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import '../models/species.dart';
import '../models/tank.dart';

class AddInvertebratesScreen extends StatefulWidget {
  final Tank tank;

  const AddInvertebratesScreen({Key? key, required this.tank}) : super(key: key);

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
                    final isInTank =
                    widget.tank.invertebrateKeys.contains(species.key as int);

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
                              widget.tank.invertebrateKeys.remove(species.key as int);
                            } else {
                              widget.tank.invertebrateKeys.add(species.key as int);
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
