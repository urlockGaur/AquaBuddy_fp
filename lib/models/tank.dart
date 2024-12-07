import 'package:hive/hive.dart';

part 'tank.g.dart';

@HiveType(typeId: 0)
class Tank extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String waterType;

  @HiveField(2)
  final int color;

  Tank({required this.name, required this.waterType, required this.color});
}
