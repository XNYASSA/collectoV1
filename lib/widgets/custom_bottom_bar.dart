import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Collecte',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Stat',
        ),
      ],
      currentIndex: currentIndex,
      selectedItemColor: const Color.fromARGB(255, 252, 252, 252),
      unselectedItemColor: const Color.fromARGB(255, 35, 46, 53),
      backgroundColor: const Color.fromARGB(255, 19, 133, 232), // Couleur bleue pour la BottomNavigationBar
      onTap: onTap,
    );
  }
}
