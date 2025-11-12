import 'package:flutter/material.dart';

class AppRecettes extends StatelessWidget {
  const AppRecettes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Recettes',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const AccueilPage(),
      debugShowCheckedModeBanner: false,
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
