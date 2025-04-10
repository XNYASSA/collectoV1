import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunmi_printer_plugin/sunmi_printer_plugin.dart';
import '../database/database_helper.dart';

class ReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;
  final String username;

  const ReceiptScreen({
    super.key,
    required this.transaction,
    required this.username,
  });

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  void initState() {
    super.initState();
    _resetRecuNumeroIfNeeded(); // Appeler la méthode pour réinitialiser les numéros si nécessaire
    _initialiserImprimante();
  }

  Future<void> _resetRecuNumeroIfNeeded() async {
    final db = await DatabaseHelper().database;

    // Récupérer la date actuelle
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    // Vérifier la dernière date de réinitialisation stockée dans une table de configuration
    final List<Map<String, dynamic>> result = await db.query(
      'Config',
      where: 'key = ?',
      whereArgs: ['last_reset_date'],
    );

    if (result.isEmpty) {
      // Si aucune date n'est stockée, initialiser la table Config
      await db.insert('Config', {
        'key': 'last_reset_date',
        'value': today,
      });
      return;
    }

    // Récupérer la dernière date de réinitialisation
    final lastResetDate = DateTime.parse(result.first['value']);

    // Vérifier si la date actuelle est un nouveau jour par rapport à la dernière réinitialisation
    if (now.difference(lastResetDate).inDays >= 1) {
      // Réinitialiser les numéros de reçu pour les nouvelles transactions
      await db.update(
        'Transactions',
        {'recu_numero': null}, // Réinitialiser les numéros de reçu
      );

      // Mettre à jour la dernière date de réinitialisation
      await db.update(
        'Config',
        {'value': today},
        where: 'key = ?',
        whereArgs: ['last_reset_date'],
      );
    }
  }

  Future<void> _initialiserImprimante() async {
    try {
      await SunmiPrinter.bindingPrinter();
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de l\'imprimante : $e');
    }
  }

  Future<void> _imprimer() async {
    try {
      await SunmiPrinter.startTransactionPrint(true); // démarre une transaction

      // Premier reçu
      await SunmiPrinter.printText(
        "Reçu de Transactions",
      );
      await SunmiPrinter.lineWrap(1);

      await SunmiPrinter.printText('Reçu n°${widget.transaction['recu_numero'] ?? 'N/A'}');
      await SunmiPrinter.printText('Montant : ${_formatMontant(widget.transaction['montant'])} FCFA');
      await SunmiPrinter.printText('Date : ${_formatDate(widget.transaction['date'])}');
      await SunmiPrinter.printText('Collecteur : ${widget.username}');
      await SunmiPrinter.lineWrap(1);

      await SunmiPrinter.printText('Client : ${widget.transaction['client_nom'] ?? ''} ${widget.transaction['client_prenom'] ?? ''}');
      await SunmiPrinter.printText('Zone : ${widget.transaction['client_zone_number'] ?? ''}');
      await SunmiPrinter.lineWrap(2);

      // Séparation entre les deux reçus
      await SunmiPrinter.printText('------------------------------',);
      await SunmiPrinter.lineWrap(1);

      // Deuxième reçu
      await SunmiPrinter.printText(
        "Reçu de Transactions",
      );
      await SunmiPrinter.lineWrap(1);

      await SunmiPrinter.printText('Reçu n°${widget.transaction['recu_numero'] ?? 'N/A'}');
      await SunmiPrinter.printText('Montant : ${_formatMontant(widget.transaction['montant'])} FCFA');
      await SunmiPrinter.printText('Date : ${_formatDate(widget.transaction['date'])}');
      await SunmiPrinter.printText('Collecteur : ${widget.username}');
      await SunmiPrinter.lineWrap(1);

      await SunmiPrinter.printText('Client : ${widget.transaction['client_nom'] ?? ''} ${widget.transaction['client_prenom'] ?? ''}');
      await SunmiPrinter.printText('Zone : ${widget.transaction['client_zone_number'] ?? ''}');
      await SunmiPrinter.lineWrap(2);

      await SunmiPrinter.exitTransactionPrint(true); // termine la transaction

      debugPrint('Impression réussie avec séparation.');
    } catch (e) {
      debugPrint('Erreur lors de l\'impression : $e');
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'Date invalide';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy, HH:mm').format(parsedDate);
    } catch (e) {
      debugPrint('Erreur lors du formatage de la date : $e');
      return 'Date invalide';
    }
  }

  String _formatMontant(dynamic montant) {
    if (montant == null) return '0';
    try {
      final NumberFormat formatter = NumberFormat('#,##0', 'fr_FR');
      return formatter.format(montant);
    } catch (e) {
      debugPrint('Erreur lors du formatage du montant : $e');
      return '0';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu de Transactions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reçu n°${widget.transaction['recu_numero'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Montant : ${_formatMontant(widget.transaction['montant'])} FCFA'),
            Text('Date : ${_formatDate(widget.transaction['date'])}'),
            Text('Collecteur : ${widget.username}'),
            const SizedBox(height: 5),
            Text('Client : ${widget.transaction['client_nom'] ?? ''} ${widget.transaction['client_prenom'] ?? ''}'),
            Text('Zone : ${widget.transaction['client_zone_number'] ?? ''}'),
            const Spacer(),
            ElevatedButton(
              onPressed: _imprimer,
              child: const Text('Imprimer le Reçu'),
            ),
          ],
        ),
      ),
    );
  }
}

