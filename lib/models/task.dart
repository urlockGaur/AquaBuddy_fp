import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  bool isCompleted; // Now mutable

  Task({
    required this.title,
    required this.description,
    this.isCompleted = false,
  });
}

