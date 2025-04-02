import 'package:flutter/material.dart';

class DataTransfertScreen extends StatelessWidget {
  const DataTransfertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfert de Données'),
      ),
      body: const Center(
        child: Text('Bienvenue sur l\'écran de transfert de données !'),
      ),
    );
  }
}
