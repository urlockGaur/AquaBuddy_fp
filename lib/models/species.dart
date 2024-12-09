import 'package:hive/hive.dart';

part 'species.g.dart';

@HiveType(typeId: 7)
class Species extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String scientificName;

  Species({required this.name, required this.scientificName});
}
