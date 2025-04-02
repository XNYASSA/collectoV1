class Client {
  final int? id;
  final String nom;
  final String prenom;
  final int zoneNumber;

  Client({this.id, required this.nom, required this.prenom, required this.zoneNumber});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'zone_number': zoneNumber,
    };
  }
}
