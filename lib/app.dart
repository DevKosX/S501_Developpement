import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ui/static/ecran_principal.dart';
import 'core/controllers/feedback_recette_controller.dart';
import 'core/controllers/historique_controller.dart';
import 'core/repositories/feedback_recette_repository.dart';
import 'core/repositories/historique_repository.dart';

class AppRecettes extends StatelessWidget {
  const AppRecettes({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FeedbackRecetteController(
            FeedbackRecetteRepositoryImpl(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoriqueController(
            HistoriqueRepositoryImpl(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'App Recettes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const EcranPrincipal(),
      ),
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
