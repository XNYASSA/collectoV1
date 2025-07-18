import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_bar.dart';
import '../database/database_helper.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  _ViewUsersScreenState createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> users = await db.query('User');
    setState(() {
      _users = users;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigation logique basée sur l'index
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/view_users');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/settings'); // Exemple pour une page de paramètres
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'View Users'),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user['username']),
            subtitle: Text('ID: ${user['id']}'),
          );
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
