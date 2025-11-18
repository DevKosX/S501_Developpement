import 'package:flutter/material.dart';
import 'ui/static/ecran_principal.dart'; // On appelle la structure globale

class AppRecettes extends StatelessWidget {
  const AppRecettes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Recettes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Au lieu d'afficher une page simple, on affiche la STRUCTURE (avec le menu en bas)
      home: const EcranPrincipal(),
    );
  }
}

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil des Recettes")),
      body: const Center(
        child: Text(
          "Bienvenue dans l'application Recettes ! 🎉",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
