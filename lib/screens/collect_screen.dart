import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    try {
      if (_selectedClientId == null || _montantController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs')),
        );
        return;
      }

      final db = await DatabaseHelper().database;

      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      // Compter le nombre de transactions pour la date du jour
      final List<Map<String, dynamic>> todaysTransactions = await db.query(
        'Transactions',
        where: "date LIKE ?",
        whereArgs: ['$todayStr%'],
      );
      final int recuNumero = todaysTransactions.length + 1; // Le numéro repart à 1 chaque jour

      final client = _clients.firstWhere(
        (client) => client['id'] == _selectedClientId,
        orElse: () => {'nom': '', 'prenom': '', 'zone_number': ''},
      );

      final transactionDb = {
        'montant': double.parse(_montantController.text),
        'date': now.toIso8601String(),
        'client_id': _selectedClientId,
        'collector_name': widget.collectorName,
        'recu_numero': recuNumero,
        'client_zone_number': client['zone_number'],
      };

      await db.insert('Transactions', transactionDb);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction enregistrée avec le reçu n°$recuNumero')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            transaction: {
              ...transactionDb,
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
    } catch (e, stack) {
      print('Erreur dans _handleCollect: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
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
              onPressed: () async {
                // Ajout d'un print pour vérifier l'appel
                print('Bouton Valider la collecte cliqué');
                await _handleCollect();
              },
              child: const Text('Valider la collecte'),
            ),
          ],
        ),
      ),
    );
  }
}
            
