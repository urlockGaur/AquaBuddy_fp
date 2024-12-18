import 'dart:convert';
import 'package:aquabuddy/screens/splash_screen.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/tank.dart';
import 'models/task.dart';
import 'models/species.dart';
import 'package:flutter/material.dart';
import 'models/user.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(TankAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(SpeciesAdapter());
  Hive.registerAdapter(UserAdapter());

  // Open the boxes
  await Hive.openBox<Tank>('tanks');
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Species>('fish');
  await Hive.openBox<Species>('invertebrates');
  await Hive.openBox<Species>('plants');
  await Hive.openBox<User>('users');

  // Seed species data if required
  await seedSpeciesData();
  await NotificationService.initialize();

  runApp(const AquaBuddyApp());
}


Future<void> seedSpeciesData() async {
  final fishBox = Hive.box<Species>('fish');
  final invertebratesBox = Hive.box<Species>('invertebrates');
  final plantsBox = Hive.box<Species>('plants');

  // Only seed data if the box is empty
  if (fishBox.isEmpty && invertebratesBox.isEmpty && plantsBox.isEmpty) {
    final String data = await rootBundle.loadString('assets/species_data.json');
    final Map<String, dynamic> jsonResult = json.decode(data);

    for (var fish in jsonResult['fish']) {
      fishBox.add(Species(
        name: fish['name'],
        scientificName: fish['scientificName'],
      ));
    }

    for (var invert in jsonResult['invertebrates']) {
      invertebratesBox.add(Species(
        name: invert['name'],
        scientificName: invert['scientificName'],
      ));
    }

    for (var plant in jsonResult['plants']) {
      plantsBox.add(Species(
        name: plant['name'],
        scientificName: plant['scientificName'],
      ));
    }

    print("Seed data added successfully.");
  } else {
    print("Boxes are not empty. Skipping seed data.");
  }
}
class AquaBuddyApp extends StatelessWidget {
  const AquaBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaBuddy',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF007ACC),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF007ACC),
          unselectedItemColor: Colors.grey,
        ),
        textTheme: TextTheme(
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[300]),
          titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF007ACC), // Blue FAB background
          foregroundColor: Colors.white, // White icon
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007ACC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.all(const Color(0xFF007ACC)), // Use primary blue for checkboxes
          checkColor: WidgetStateProperty.all(Colors.white), // White checkmark
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue), // Match theme color
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!),
          ),
          labelStyle: TextStyle(color: Colors.grey[300]),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[700]!,
          labelStyle: const TextStyle(color: Colors.white),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          secondarySelectedColor: Colors.blue,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

