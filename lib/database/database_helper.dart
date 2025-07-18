import 'package:sqflite/sqflite.dart'; // Importation d'une bibliothèque pour la gestion de bases de données SQLite
import 'package:path/path.dart'; // Importation pour manipuler les chemins de fichiers
import 'package:path_provider/path_provider.dart'; // Importation pour obtenir des répertoires spécifiques
import 'dart:io'; // Importation pour les opérations sur les fichiers et répertoires

// Classe pour gérer la base de données
class DatabaseHelper {
  // Instance unique de la classe (singleton)
  static final DatabaseHelper _instance = DatabaseHelper._internal(); // Variable statique
  factory DatabaseHelper() => _instance; // Constructeur factory pour retourner l'instance unique
  static Database? _database; // Variable statique pour stocker l'instance de la base de données

  // Constructeur privé
  DatabaseHelper._internal();

  // Getter pour accéder à la base de données
  Future<Database> get database async { // Fonction asynchrone
    if (_database != null) return _database!; // Vérification si la base de données est déjà initialisée
    try {
      _database = await _initDatabase(); // Initialisation de la base de données
      return _database!;
    } catch (e) {
      print('Erreur lors de l\'initialisation de la base de données : $e'); // Message d'erreur
      rethrow; // Relance de l'exception
    }
  }

  // Fonction pour initialiser la base de données
  Future<Database> _initDatabase() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory(); // Obtention du répertoire des documents
      String path = join(directory.path, 'collecto.db'); // Chemin du fichier de la base de données
      print('Database path: $path'); // Message de débogage
      return await openDatabase( // Ouverture de la base de données
        path,
        version: 2, // Augmentez la version de la base de données
        onCreate: _onCreate, // Fonction appelée lors de la création de la base
        onUpgrade: _onUpgrade, // Ajoutez une fonction pour gérer les migrations
      );
    } catch (e) {
      print('Erreur lors de l\'ouverture de la base de données : $e'); // Message d'erreur
      rethrow; // Relance de l'exception
    }
  }

  // Fonction appelée lors de la création de la base de données
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Création de la table User
      await db.execute('''
        CREATE TABLE User (
          id INTEGER PRIMARY KEY AUTOINCREMENT, -- Colonne id (clé primaire)
          username TEXT UNIQUE NOT NULL, -- Colonne username
          password TEXT NOT NULL -- Colonne password
        )
      ''');

      // Création de la table Client
      await db.execute('''
        CREATE TABLE Client (
          id INTEGER PRIMARY KEY AUTOINCREMENT, -- Colonne id (clé primaire)
          nom TEXT NOT NULL, -- Colonne nom
          prenom TEXT NOT NULL, -- Colonne prenom
          zone_number INTEGER NOT NULL -- Colonne zone_number
        )
      ''');

      // Création de la table Transactions
      await db.execute('''
        CREATE TABLE Transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          montant REAL NOT NULL,
          date TEXT NOT NULL,
          transaction_date TEXT NOT NULL,
          client_id INTEGER NOT NULL,
          collector_name TEXT NOT NULL,
          recu_numero INTEGER NOT NULL,
          client_zone_number INTEGER,
          UNIQUE (transaction_date, recu_numero),
          FOREIGN KEY (client_id) REFERENCES Client(id) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      // Création de la table Config pour stocker les configurations
      await db.execute('''
        CREATE TABLE Config (
          key TEXT PRIMARY KEY, -- Clé unique pour chaque configuration
          value TEXT NOT NULL -- Valeur associée à la clé
        )
      ''');
      print('Table Config créée.');
    } catch (e) {
      print('Erreur lors de la création des tables : $e'); // Message d'erreur
      rethrow; // Relance de l'exception
    }
  }

  // Fonction appelée lors de la mise à jour de la base de données
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ajout de la colonne transaction_date à la table Transactions
      await db.execute('''
        ALTER TABLE Transactions ADD COLUMN transaction_date TEXT
      ''');
      print('Colonne transaction_date ajoutée à la table Transactions.');

      // Ajoutez la colonne client_zone_number à la table Transactions
      await db.execute('''
        ALTER TABLE Transactions ADD COLUMN client_zone_number INTEGER
      ''');
      print('Colonne client_zone_number ajoutée à la table Transactions.');

      // Ajout de la table Config si elle n'existe pas
      await db.execute('''
        CREATE TABLE IF NOT EXISTS Config (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL
        )
      ''');
      print('Table Config ajoutée lors de la mise à jour.');
    }
  }

  // Fonction pour récupérer toutes les transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database; // Accès à la base de données
    return await db.query('Transactions'); // Requête pour récupérer les transactions
  }

  // Fonction pour récupérer tous les clients
  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database; // Accès à la base de données
    return await db.query('Client'); // Requête pour récupérer les clients
  }

  // Fonction pour ajouter une transaction
  Future<void> addTransaction(double montant, int clientId, String collectorName) async {
    final db = await database;

    // Récupérer la date actuelle
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    // Vérifier le dernier numéro de transaction pour la date actuelle
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT MAX(recu_numero) as last_recu_numero
      FROM Transactions
      WHERE transaction_date = ?
    ''', [today]);

    int newRecuNumero = 1; // Par défaut, le numéro commence à 1
    if (result.isNotEmpty && result.first['last_recu_numero'] != null) {
      newRecuNumero = result.first['last_recu_numero'] + 1; // Incrémenter le dernier numéro
    }

    // Ajouter la transaction avec le nouveau numéro
    await db.insert('Transactions', {
      'montant': montant,
      'date': now.toIso8601String(),
      'transaction_date': today, // Stocker la date de la transaction
      'client_id': clientId,
      'collector_name': collectorName,
      'recu_numero': newRecuNumero,
    });

    print('Transaction ajoutée avec le numéro de reçu : $newRecuNumero');
  }

  // Fonction pour ajouter un client
  Future<void> addClient(String nom, String prenom, int zoneNumber) async {
    final db = await database; // Accès à la base de données
    await db.insert('Client', { // Insertion dans la table Client
      'nom': nom, // Valeur pour la colonne nom
      'prenom': prenom, // Valeur pour la colonne prenom
      'zone_number': zoneNumber, // Valeur pour la colonne zone_number
    });
    print('Client ajouté : $nom $prenom (Zone: $zoneNumber)'); // Message de confirmation
  }

  // Fonction pour vérifier les tables existantes
  Future<void> checkTables() async {
    final db = await database; // Accès à la base de données
    final List<Map<String, dynamic>> tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table';" // Requête pour récupérer les noms des tables
    );
    print('Tables existantes : ${tables.map((t) => t['name']).toList()}'); // Affichage des tables
  }

  // Fonction pour récupérer une transaction avec les informations du client
  Future<Map<String, dynamic>> getTransactionWithClient(int transactionId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        t.id AS transaction_id,
        t.montant,
        t.date,
        t.collector_name,
        t.recu_numero,
        c.nom AS client_nom,
        c.prenom AS client_prenom,
        c.zone_number AS client_zone
      FROM Transactions t
      INNER JOIN Client c ON t.client_id = c.id
      WHERE t.id = ?
    ''', [transactionId]);

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Transaction non trouvée');
    }
  }

  // Fonction pour récupérer les informations de l'utilisateur connecté
  Future<Map<String, dynamic>> getLoggedInUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'User',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Utilisateur non trouvé');
    }
  }

  // Fonction pour supprimer la base de données
  Future<void> deleteDatabase() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory(); // Obtention du répertoire des documents
      String path = join(directory.path, 'collecto.db'); // Chemin du fichier de la base de données
      await File(path).delete(); // Suppression du fichier
      print('Base de données supprimée avec succès.'); // Message de confirmation
    } catch (e) {
      print('Erreur lors de la suppression de la base de données : $e'); // Message d'erreur
    }
  }

  // Fonction pour supprimer le fichier de base de données (pour développement uniquement)
  Future<void> deleteDatabaseFile() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'collecto.db');
    if (await File(path).exists()) {
      await File(path).delete();
      print('Base de données supprimée');
    }
  }

  // Modification pour ne pas supprimer les transactions existantes
  Future<void> resetRecuNumeroIfNeeded() async {
    final db = await database; // Accès à la base de données

    // Récupérer la date actuelle
    final now = DateTime.now();

    // Récupérer la dernière date de réinitialisation stockée dans une table de configuration
    final List<Map<String, dynamic>> result = await db.query(
      'Config',
      where: 'key = ?',
      whereArgs: ['last_reset_date'],
    );

    // Si aucune date n'est stockée, initialiser la table Config
    if (result.isEmpty) {
      await db.insert('Config', {
        'key': 'last_reset_date',
        'value': now.toIso8601String(),
      });
      return; // Pas besoin de réinitialiser pour la première exécution
    }

    // Récupérer la dernière date de réinitialisation
    final lastResetDate = DateTime.parse(result.first['value']);

    // Vérifier si la date actuelle est un nouveau jour par rapport à la dernière réinitialisation
    if (now.difference(lastResetDate).inDays >= 1) {
      // Réinitialiser uniquement le numéro de reçu
      await db.update(
        'Transactions',
        {'recu_numero': null}, // Réinitialiser le numéro de reçu à null ou 0
      );

      // Mettre à jour la dernière date de réinitialisation
      await db.update(
        'Config',
        {'value': now.toIso8601String()},
        where: 'key = ?',
        whereArgs: ['last_reset_date'],
      );
    }
  }
}