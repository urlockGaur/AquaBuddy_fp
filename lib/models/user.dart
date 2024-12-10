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

  User({
    required this.username,
    required this.email,
    required this.password,
    required this.badges,
  });
}
