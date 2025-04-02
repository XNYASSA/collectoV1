import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'receipt_screen.dart';


class CollectScreen extends StatefulWidget {
  final String collectorName; // Nom de l'utilisateur connecté

  const CollectScreen({super.key, required this.collectorName});

  @override
  _CollectScreenState createState() => _CollectScreenState();
}

class _CollectScreenState extends State<CollectScreen> {
  final TextEditingController _montantController = TextEditingController();
  int? _selectedClientId;
  List<Map<String, dynamic>> _clients = [];

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> clients = await db.query('Client');
    setState(() {
      _clients = clients;
    });
  }

  Future<void> _handleCollect() async {
    if (_selectedClientId == null || _montantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> transactions = await db.query('Transactions');
    final int recuNumero = transactions.length + 1;

    // Récupérer les informations du client sélectionné
    final client = _clients.firstWhere(
      (client) => client['id'] == _selectedClientId,
      orElse: () => {'nom': '', 'prenom': '', 'zone_number': ''},
    );

    final transaction = {
      'montant': double.parse(_montantController.text),
      'date': DateTime.now().toIso8601String(),
      'client_id': _selectedClientId,
      'collector_name': widget.collectorName,
      'recu_numero': recuNumero,
      'client_zone_number': client['zone_number'], // Ajout du numéro de zone
    };

    await db.insert('Transactions', transaction);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction enregistrée avec le reçu n°$recuNumero')),
    );

    // Naviguer vers ReceiptScreen avec les détails de la transaction
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          transaction: {
            ...transaction,
            'client_nom': client['nom'],
            'client_prenom': client['prenom'],
          },
          username: widget.collectorName,
        ),
      ),
    );

    _montantController.clear();
    setState(() {
      _selectedClientId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collecte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connecté en tant que : ${widget.collectorName}', // Affiche dynamiquement le nom de l'utilisateur connecté
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Espace entre le texte et le formulaire
            DropdownButtonFormField<int>(
              value: _selectedClientId,
              items: _clients.map((client) {
                // Remplacez les valeurs nulles par une chaîne vide
                final nom = client['nom'] ?? '';
                final prenom = client['prenom'] ?? '';
                final zone = client['zone'] ?? ''; // Affiche une chaîne vide si la zone est absente
                return DropdownMenuItem<int>(
                  value: client['id'],
                  child: Text('$nom $prenom${zone.isNotEmpty ? ' ($zone)' : ''}'), // Affiche la zone uniquement si elle est présente
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClientId = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Sélectionner un client'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montantController,
              decoration: const InputDecoration(labelText: 'Montant'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleCollect,
              child: const Text('Valider la collecte'),
            ),
          ],
        ),
      ),
    );
  }
}
