import 'package:hive/hive.dart';

part 'tank.g.dart';

@HiveType(typeId: 0)
class Tank extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String waterType;

  @HiveField(2)
  int color;

  @HiveField(3)
  int sizeInGallons;

  @HiveField(4)
  List<int> fishKeys; // Mutable list of species keys

  @HiveField(5)
  List<int> invertebrateKeys;

  @HiveField(6)
  List<int> plantKeys;

  Tank({
    required this.name,
    required this.waterType,
    required this.color,
    required this.sizeInGallons,
    this.fishKeys = const [],
    this.invertebrateKeys = const [],
    this.plantKeys = const [],
  });
}
