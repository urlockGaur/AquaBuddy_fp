import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  int? tankKey;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    this.tankKey,
  });
}

