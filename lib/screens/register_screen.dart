import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleRegister() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> existingUsers = await db.query(
      'User',
      where: 'username = ?',
      whereArgs: [_usernameController.text],
    );

    if (existingUsers.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username already exists')),
      );
      return;
    }

    try {
      await db.insert(
        'User',
        {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User registered successfully')),
      );
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering user: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _usernameController,
              labelText: 'Username',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Register',
              onPressed: _handleRegister,
            ),
          ],
        ),
      ),
    );
  }
}
