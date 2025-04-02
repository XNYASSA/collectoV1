class Transaction {
  final int? id;
  final double montant;
  final String date;
  final int clientId;
  final String collectorName;
  final int recuNumero;

  Transaction({
    this.id,
    required this.montant,
    required this.date,
    required this.clientId,
    required this.collectorName,
    required this.recuNumero,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      'date': date,
      'client_id': clientId,
      'collector_name': collectorName,
      'recu_numero': recuNumero,
    };
  }
}
