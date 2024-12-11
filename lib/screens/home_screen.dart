import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/tank.dart';
import '../models/task.dart';
import '../models/user.dart';
import 'tasks_screen.dart';
import 'tank_screen.dart';
import 'user_profile_screen.dart';
import 'create_account_screen.dart'; // Import the separated CreateAccountScreen
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/badge_configuration.dart';

// Declare HomeScreen as a StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize _pages in initState
    _pages = [
      HomeDashboard(onProfileUpdated: _reloadDashboard),
      const TasksScreen(),
      const TankScreen(),
    ];
  }

  void _reloadDashboard() {
    setState(() {}); // Triggers rebuild
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onBottomNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
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

  @override
  Widget build(BuildContext context) {
    final tanksBox = Hive.box<Tank>('tanks');
    final tasksBox = Hive.box<Task>('tasks');
    final userBox = Hive.box<User>('users');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Account Card
            ValueListenableBuilder(
              valueListenable: userBox.listenable(),
              builder: (context, Box<User> box, _) {
                final user = box.values.isNotEmpty ? box.getAt(0) : null;

                return buildPreviewCard(
                  context: context,
                  title: user != null ? 'Welcome, ${user.username}' : 'Welcome!',
                  icon: Icons.account_circle,
                  content: [
                    if (user != null)
                      Text(
                        'Email: ${user.email}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 8.0),
                    if (user != null && user.badges.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      Text(
                        'Badges:',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0),
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: user.badges.map((badge) {
                          final badgeName = badge['name'] ?? 'Unknown';
                          final badgeIcon = badgeIcons[badgeName] ?? Icons.error;
                          final badgeColor = badgeColors[badgeName] ?? Theme.of(context).primaryColor;

                          return Icon(
                            badgeIcon,
                            size: 36.0,
                            color: badgeColor,
                          );
                        }).toList(),
                      ),
                    ] else if (user != null) const Text('No badges earned yet.'),
                    if (user == null) Text(
                      'No account found. Create one to track progress and earn badges!',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                  ],
                  menuItems: const [
                    PopupMenuItem(
                      value: 'View',
                      child: Text('Manage Account'),
                    ),
                  ],
                  onMenuSelected: (value) async {
                    if (value == 'View') {
                      final userExists = box.isNotEmpty;
                      if (!userExists) {
                        final bool? created = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                        if (created == true) {
                          onProfileUpdated();
                        }
                      } else {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserProfileScreen(),
                          ),
                        ).then((value) {
                          if (value == true) {
                            onProfileUpdated();
                          }
                        });
                      }
                    }
                  },
                );
              },
            ),

            // Tanks Overview Card
            ValueListenableBuilder(
              valueListenable: tanksBox.listenable(),
              builder: (context, Box<Tank> box, _) {
                final tanksPreview = box.values.take(3).map((tank) {
                  return Text(
                    '- ${tank.name} (${tank.sizeInGallons} gallons)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }).toList();

                return buildPreviewCard(
                  context: context,
                  title: 'Your Tanks',
                  icon: Icons.water,
                  content: tanksPreview.isNotEmpty
                      ? tanksPreview
                      : [const Text('No tanks created yet.')],
                  menuItems: const [
                    PopupMenuItem(
                      value: 'ViewTanks',
                      child: Text('View All Tanks'),
                    ),
                  ],
                  onMenuSelected: (value) {
                    if (value == 'ViewTanks') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TankScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),

            // Tasks Overview Card
            ValueListenableBuilder(
              valueListenable: tasksBox.listenable(),
              builder: (context, Box<Task> box, _) {
                final tasksPreview = box.values.take(3).map((task) {
                  return Text(
                    '- ${task.title} (Due: ${task.dueDate})',
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }).toList();

                return buildPreviewCard(
                  context: context,
                  title: 'Your Tasks',
                  icon: FontAwesomeIcons.listCheck,
                  content: tasksPreview.isNotEmpty
                      ? tasksPreview
                      : [const Text('No tasks created yet.')],
                  menuItems: const [
                    PopupMenuItem(
                      value: 'ViewTasks',
                      child: Text('View All Tasks'),
                    ),
                  ],
                  onMenuSelected: (value) {
                    if (value == 'ViewTasks') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TasksScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreviewCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> content,
    required List<PopupMenuEntry<String>> menuItems,
    required Function(String value) onMenuSelected,
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
                  onSelected: onMenuSelected,
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
}
