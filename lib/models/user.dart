import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1)
class User {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String password;

  @HiveField(3)
  final List<Map<String, String>> badges; // List of badge name and icon

  @HiveField(4) // Add new field for tanks created
  int tanksCreated;

  @HiveField(5) // Add new field for tasks created
  int tasksCreated;

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.badges,
    this.tanksCreated = 0, // Initialize new fields with default values
    this.tasksCreated = 0,
  });
}