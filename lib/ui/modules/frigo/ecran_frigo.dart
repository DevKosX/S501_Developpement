import 'package:flutter/material.dart';

class EcranFrigo extends StatelessWidget {
  // Le constructeur 'const' est important car on l'appelle avec 'const' dans l'écran principal
  const EcranFrigo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Frigo"),
        backgroundColor: Colors.orange, // Orange pour matcher l'onglet
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text(
              "Votre frigo est vide pour l'instant",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}