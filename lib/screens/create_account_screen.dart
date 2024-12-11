import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user.dart';
import '../utils/badge_utils.dart';
import '../utils/alert_utils.dart'; // Import the updated snackbar utility

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late Box<User> userBox;

  @override
  void initState() {
    super.initState();
    userBox = Hive.box<User>('users');
  }

  void _createAccount() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      showCustomFlushbar(context, 'Please fill out all fields.', icon: Icons.error);
      return;
    }

    // Create new user
    final newUser = User(
      username: username,
      email: email,
      password: password,
      badges: [],
    );

    userBox.add(newUser);

    // Add the "Account Created" badge
    addBadge('Account Created', userBox);

    // Show confirmation message
    showCustomFlushbar(context, 'Account created successfully!', icon: Icons.check_circle);

    // Navigate back after a short delay
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pop(context, true); // Notify caller about success
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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

            // Create Account Button
            ElevatedButton(
              onPressed: _createAccount,
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
