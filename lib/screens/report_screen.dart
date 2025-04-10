import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';



class ReportScreen extends StatefulWidget {
  final String username; // Nom de l'utilisateur connecté

  const ReportScreen({
    super.key,
    required this.username,
  });

  @override
  _ReportScreenState createState() => _ReportScreenState();
}



class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  List<Map<String, dynamic>> _transactions = [];
  double _totalMontant = 0.0; // Variable pour stocker le montant total des transactions du jour

  @override
  void initState() {
    super.initState();
  }

  Future<void> _authenticateUser() async {
    final db = await DatabaseHelper().database;

    // Vérifier si l'utilisateur existe dans la base de données avec le mot de passe
    final List<Map<String, dynamic>> result = await db.query(
      'User',
      where: 'username = ? AND password = ?',
      whereArgs: [widget.username, _passwordController.text],
    );

    if (result.isNotEmpty) {
      setState(() {
        _isAuthenticated = true;
      });
      _fetchTransactionsOfTheDay();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe incorrect.')),
      );
    }
  }

  Future<void> _fetchTransactionsOfTheDay() async {
    final db = await DatabaseHelper().database;

    // Récupérer la date actuelle
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();

    // Requête pour récupérer les transactions du jour
    final List<Map<String, dynamic>> transactions = await db.rawQuery('''
      SELECT t.recu_numero, t.montant, t.date, t.collector_name, c.nom AS client_nom, c.prenom AS client_prenom, c.zone_number AS client_zone
      FROM Transactions t
      INNER JOIN Client c ON t.client_id = c.id
      WHERE t.date >= ?
      ORDER BY t.date DESC
    ''', [todayStart]);

    // Calculer le montant total des transactions du jour
    double total = 0.0;
    for (var transaction in transactions) {
      total += transaction['montant'] ?? 0.0;
    }

    setState(() {
      _transactions = transactions;
      _totalMontant = total; // Mettre à jour le montant total
    });
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final dateTime = DateTime.parse(transaction['date']);
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final formattedTime = DateFormat('HH:mm:ss').format(dateTime);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de la Transaction n°${transaction['recu_numero']}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Montant : ${transaction['montant']} FCFA'),
              Text('Date : $formattedDate'), // Affiche la date
              Text('Heure : $formattedTime'), // Affiche l'heure
              Text('Collecteur : ${transaction['collector_name']}'),
              Text('Client : ${transaction['client_nom']} ${transaction['client_prenom']}'),
              Text('Zone : ${transaction['client_zone']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Authentification - ${widget.username}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Utilisateur : ${widget.username}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticateUser,
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques du jour'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Montant total des transactions : ${_totalMontant.toStringAsFixed(2)} FCFA',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text('Aucune transaction effectuée aujourd\'hui.'),
                  )
                : ListView.separated(
                    itemCount: _transactions.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.grey),
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Container(
                        color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                        child: ListTile(
                          title: Text('Reçu n°${transaction['recu_numero']}'),
                          onTap: () => _showTransactionDetails(transaction),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
