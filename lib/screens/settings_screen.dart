import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteDatabase() async {
    try {
      await DatabaseHelper().deleteDatabase();
      print('Base de données supprimée avec succès.');
    } catch (e) {
      print('Erreur lors de la suppression de la base de données : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _deleteDatabase,
          child: const Text('Supprimer la Base de Données'),
        ),
      ),
    );
  }
}
