import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/badge_configuration.dart';
import '../utils/badge_utils.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Add password controller
  late Box<User> userBox;
  User? user;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
    user = userBox.values.isNotEmpty ? userBox.getAt(0) : null;
    if (user != null) {
      _usernameController.text = user!.username;
      _emailController.text = user!.email;
      _passwordController.text = user!.password; // Populate password field
    }
  }

  @override
  Widget build(BuildContext context) {
    final badges = user?.badges.map((badge) {
      final badgeName = badge['name'] ?? 'Unknown';
      final icon = badgeIcons[badgeName] ?? Icons.error; // Use badgeIcons for resolution

      return Chip(
        label: Text(
          badgeName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        avatar: Icon(
          icon,
          size: 24.0,
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.all(8.0),
        backgroundColor: Theme.of(context).primaryColorLight,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                final updatedUser = User(
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  badges: user?.badges ?? [],
                );

                if (user == null) {
                  // Create a new user
                  userBox.add(updatedUser);

                  // Add the 'Account Created' badge
                  addBadge('Account Created', userBox);
                } else {
                  // Update the existing user
                  userBox.putAt(0, updatedUser);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account details saved!')),
                );

                // Trigger rebuild in parent widget
                Navigator.pop(context, true); // Pass true to indicate changes
              },
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Badges',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: badges ?? [const Text('No badges earned yet.')],
            ),
          ],
        ),
      ),
    );
  }
}
