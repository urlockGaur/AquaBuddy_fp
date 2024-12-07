import 'package:flutter/material.dart';
import 'package:aquabuddy/screens/home_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/tank.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TankAdapter());
  Hive.registerAdapter(TaskAdapter());

  await Hive.openBox<Tank>('tanks');
  await Hive.openBox<Task>('tasks');

  runApp(AquaBuddyApp());
}

class AquaBuddyApp extends StatelessWidget {
  const AquaBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaBuddy',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}