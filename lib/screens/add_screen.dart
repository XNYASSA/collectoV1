import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  int? _selectedZoneNumber; // Variable pour stocker le numéro de zone sélectionné

  Future<void> _addClient() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _selectedZoneNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final db = await DatabaseHelper().database;
      await db.insert('Client', {
        'nom': _nomController.text,
        'prenom': _prenomController.text,
        'zone_number': _selectedZoneNumber,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client ajouté avec succès')),
      );

      _nomController.clear();
      _prenomController.clear();
      setState(() {
        _selectedZoneNumber = null;
      });
    } catch (e) {
      print('Erreur lors de l\'ajout du client : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout du client : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedZoneNumber,
              items: List.generate(15, (index) => index + 1)
                  .map((zone) => DropdownMenuItem<int>(
                        value: zone,
                        child: Text('Zone $zone'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedZoneNumber = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Numéro de Zone'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addClient,
              child: const Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
