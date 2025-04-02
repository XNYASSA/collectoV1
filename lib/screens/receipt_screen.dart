import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour le formatage de la date et du montant


class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final String username;

  const ReceiptScreen({
    super.key,
    required this.transaction,
    required this.username,
  });

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
              'Reçu n°${transaction['recu_numero'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Montant : ${_formatMontant(transaction['montant'])} FCFA'),
            Text('Date : ${_formatDate(transaction['date'])}'),
            Text('Collecteur : $username'),
            const SizedBox(height: 16),
            Text('Client : ${transaction['client_nom'] ?? ''} ${transaction['client_prenom'] ?? ''}'),
            Text('Zone : ${transaction['client_zone_number'] ?? ''}'), // Affiche le numéro de zone du client
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

