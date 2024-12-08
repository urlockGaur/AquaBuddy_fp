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

  Tank({required this.name, required this.waterType, required this.color});
}
