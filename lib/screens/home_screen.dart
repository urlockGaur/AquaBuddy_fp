import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tank.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../utils/badge_configuration.dart';
import 'tasks_screen.dart';
import 'tank_screen.dart';
import 'user_profile_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Dynamically update the HomeDashboard
  List<Widget> get _pages => [
    HomeDashboard(onProfileUpdated: _reloadDashboard), // Pass the callback
    const TasksScreen(),
    const TankScreen(),
  ];

  // Method to trigger a rebuild
  void _reloadDashboard() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.water),
            label: 'Tanks',
          ),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final VoidCallback onProfileUpdated;

  const HomeDashboard({super.key, required this.onProfileUpdated});

  Widget buildPreviewCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> content,
    required List<PopupMenuEntry<String>> menuItems,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40.0, color: Theme.of(context).primaryColor),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'View') {
                      if (icon == Icons.account_circle) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserProfileScreen()),
                        ).then((value) {
                          if (value == true) {
                            onProfileUpdated(); // Refresh HomeDashboard
                          }
                        });
                      } else if (icon == Icons.water) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TankScreen()),
                        );
                      } else if (icon == FontAwesomeIcons.tasks) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TasksScreen()),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => menuItems,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ...content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tanksBox = Hive.box<Tank>('tanks');
    final tasksBox = Hive.box<Task>('tasks');
    final userBox = Hive.box<User>('users');
    final user = userBox.values.isNotEmpty ? userBox.getAt(0) : null;

    final tanksPreview = tanksBox.values.take(3).map((tank) {
      return Text(
        '- ${tank.name} (${tank.sizeInGallons} gallons)',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }).toList();

    final tasksPreview = tasksBox.values.take(3).map((task) {
      return Text(
        '- ${task.title} (Due: ${task.dueDate})',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }).toList();

    final badges = user?.badges.map((badge) {
      final badgeName = badge['name'] ?? 'Unknown';
      final icon = badgeIcons[badgeName] ?? Icons.error; // Use badgeIcons for resolution
      final color = badgeColors[badgeName] ?? Theme.of(context).primaryColor;

      return Icon(
        icon,
        size: 36.0, // Enlarged size for visibility
        color: color,
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Overview Card
          buildPreviewCard(
            context: context,
            title: user != null && user.username.isNotEmpty
                ? 'Welcome, ${user.username}'
                : 'Welcome!',
            icon: Icons.account_circle,
            content: [
              if (user != null)
                Text('Email: ${user.email}',
                    style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8.0),
              if (badges != null && badges.isNotEmpty) ...[
                const SizedBox(height: 16.0),
                Text(
                  'Badges', // Subtitle for badges
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 12.0, // Adjust spacing for better layout
                  runSpacing: 12.0,
                  children: badges,
                ),
              ],
              if (badges == null || badges.isEmpty)
                const Text('No badges earned yet.'),
            ],
            menuItems: const [
              PopupMenuItem(
                value: 'View',
                child: Text('Manage Account'),
              ),
            ],
          ),

          // Tanks Overview Card
          buildPreviewCard(
            context: context,
            title: 'Your Tanks',
            icon: Icons.water,
            content: tanksPreview.isNotEmpty
                ? tanksPreview
                : [const Text('No tanks created yet.')],
            menuItems: const [
              PopupMenuItem(
                value: 'View',
                child: Text('View All Tanks'),
              ),
            ],
          ),

          // Tasks Overview Card
          buildPreviewCard(
            context: context,
            title: 'Your Tasks',
            icon: FontAwesomeIcons.tasks,
            content: tasksPreview.isNotEmpty
                ? tasksPreview
                : [const Text('No tasks created yet.')],
            menuItems: const [
              PopupMenuItem(
                value: 'View',
                child: Text('View All Tasks'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
