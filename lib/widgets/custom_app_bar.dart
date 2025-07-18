import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.blue[600], // Couleur bleue pour l'AppBar
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
