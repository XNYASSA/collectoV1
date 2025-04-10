import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_bar.dart';
import 'collect_screen.dart';
import 'add_screen.dart';
import 'data_transfert_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username; // Nom de l'utilisateur connecté

  const HomeScreen({super.key, required this.username});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigation logique basée sur l'index
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/view_users');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/settings'); // Exemple pour une page de paramètres
    }
  }

  void _navigateTo(String route) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        switch (route) {
          case 'collect':
            return CollectScreen(collectorName: widget.username); // Transmettre dynamiquement le nom d'utilisateur
          case 'add':
            return const AddScreen();
          case 'dataTransfert':
            return const DataTransfertScreen();
          case 'report':
            return ReportScreen(username: widget.username);
          default:
            return HomeScreen(username: widget.username); // Passer dynamiquement le nom d'utilisateur
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Home'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connecté en tant que : ${widget.username}', // Affiche le nom de l'utilisateur connecté
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Espace entre le texte et les cartes
            const Center(
              child: Text(
                'Bienvenue sur Collecto !',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 40), // Espace entre le texte et les cartes
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Deux colonnes
                crossAxisSpacing: 16, // Espacement horizontal entre les cartes
                mainAxisSpacing: 16, // Espacement vertical entre les cartes
                children: [
                  _buildCard('Collecte', Icons.attach_money, 'collect'),
                  _buildCard('Ajouter client', Icons.person_add, 'add'),
                  _buildCard('Transfert Data', Icons.sync, 'dataTransfert'),
                  _buildCard('Statistique', Icons.bar_chart, 'report'),
                  _buildCard('Paramètres', Icons.settings, '/settings'), // Ajouter une carte pour les paramètres
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, String route) {
    return GestureDetector(
      onTap: () => _navigateTo(route),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: const Color.fromARGB(255, 13, 79, 133),
            ),
            const SizedBox(height: 8), // Espace entre l'icône et le texte
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const HomeScreen(username: 'NomUtilisateur'), // Ajout du paramètre username paramètre `username`
    ));
}