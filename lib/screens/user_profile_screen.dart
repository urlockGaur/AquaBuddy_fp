import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../utils/badge_configuration.dart';
import '../utils/alert_utils.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late Box<User> userBox;
  User? user;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    _loadUserProfile();
  }

  void _loadUserProfile() {
    user = userBox.values.isNotEmpty ? userBox.getAt(0) : null;
    if (user != null) {
      _usernameController.text = user!.username;
      _emailController.text = user!.email;
      _passwordController.text = user!.password;
    }
  }

  void _saveUserProfile() {
    final updatedUser = User(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      badges: user?.badges ?? [],
    );

    if (user == null) {
      userBox.add(updatedUser); // Create new user
    } else {
      userBox.putAt(0, updatedUser); // Update existing user
    }

    showCustomFlushbar(context, 'Profile updated successfully!',
        icon: Icons.check_circle);
    Navigator.pop(context, true); // Notify caller about the update
  }

  void _deleteAccount() async {
    if (user != null) {
      userBox.deleteAt(0);
      setState(() {
        user = null; // Clear user object to avoid stale data
      });

      // Show confirmation message
      showCustomFlushbar(
        context,
        'Account deleted successfully!',
        icon: Icons.delete,
        duration: const Duration(seconds: 2),
      );

      // Navigate after a short delay
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final badges = user?.badges.map((badge) {
      final badgeName = badge['name'] ?? 'Unknown';
      final icon = badgeIcons[badgeName] ?? Icons.error;
      final color = Theme.of(context).primaryColor;

      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 36.0,
                color: color,
              ),
              const SizedBox(width: 8.0),
              Text(
                badgeName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).cardColor, // Align with card color
                  titleTextStyle: Theme.of(context).textTheme.titleLarge, // Align title style
                  contentTextStyle: Theme.of(context).textTheme.bodyMedium, // Align body style
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0), // Match app's rounded corners
                  ),
                  title: const Text('Delete Account'),
                  content: const Text('Are you sure you want to delete your account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                // Call the delete account method
                _deleteAccount();
              }
            },
          )

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username Field
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 16.0),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16.0),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 32.0),

              // Save Button
              ElevatedButton(
                onPressed: _saveUserProfile,
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 32.0),

              // Badges Section
              Text(
                'Badges',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              badges != null && badges.isNotEmpty
                  ? Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: badges,
              )
                  : const Text('No badges earned yet.'),
            ],
          ),
        ),
      ),
    );
  }
}
