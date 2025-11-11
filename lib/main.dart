import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. J'importe le service de BDD
import 'core/services/database_service.dart';

// 2. J'importe TOUS les modèles de repositories (Contrats ET Implémentations)

import 'core/models/feedback_recette_model.dart';
import 'core/models/frigo_item_model.dart';
import 'core/models/aliment_model.dart';
import 'core/models/historique_model.dart';
import 'core/models/profil_model.dart';
import 'core/models/recette_model.dart';
import 'core/models/recette_aliment_model.dart';


import 'core/repositories/aliment_repository.dart';
import 'core/repositories/feedback_recette_repository.dart';
import 'core/repositories/frigo_repository.dart';
import 'core/repositories/historique_repository.dart';
import 'core/repositories/profil_repository.dart';
import 'core/repositories/recette_repository.dart';

// 3. J'importe TOUS les contrôleurs
import 'core/controllers/aliment_controller.dart';
import 'core/controllers/feedback_recette_controller.dart';
import 'core/controllers/frigo_controller.dart';
import 'core/controllers/historique_controller.dart';
import 'core/controllers/profil_controller.dart';
import 'core/controllers/recette_controller.dart';

// 4. J'importe mon App (MaterialApp)
import 'app.dart'; // (le fichier lib/app.dart)

/// Fichier: main.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 11 novembre 2025
///
/// c'est le point d'entrée de l'application.
/// j'initialise la BDD et je fournis tous mes Repositories
/// et Contrôleurs à l'application en utilisant MultiProvider.

void main() async {
  // j'assure que Flutter est prêt
  WidgetsFlutterBinding.ensureInitialized();

  // j'initialise la BDD et j'attends qu'elle soit créée
  await DatabaseService.instance.database;

  runApp(
    // j'utilise MultiProvider pour injecter tous nos services
    // et contrôleurs dans l'arbre de widgets.
    MultiProvider(

      // --- COUCHE 1 : REPOSITORIES (Services de données) ---
      // je fournis les implémentations réelles (Impl)
      // que les contrôleurs vont utiliser.
      providers: [
        Provider<AlimentRepository>(
          create: (_) => AlimentRepositoryImpl(),
        ),
        Provider<FeedbackRecetteRepository>(
          create: (_) => FeedbackRecetteRepositoryImpl(),
        ),
        Provider<FrigoRepository>(
          create: (_) => FrigoRepositoryImpl(),
        ),
        Provider<HistoriqueRepository>(
          create: (_) => HistoriqueRepositoryImpl(),
        ),
        Provider<ProfilRepository>(
          create: (_) => ProfilRepositoryImpl(),
        ),
        Provider<RecetteRepository>(
          create: (_) => RecetteRepositoryImpl(),
        ),
      ],

      // --- COUCHE 2 : CONTRÔLEURS (Logique/État) ---
      // je crée une nouvelle liste de providers pour les contrôleurs.
      // c'est important de les séparer pour la clarté.
      child: MultiProvider(
        providers: [
          // j'utilise ChangeNotifierProvider pour les contrôleurs
          // car ils vont notifier l'UI des changements.

          ChangeNotifierProvider(
            create: (context) => AlimentController(
              context.read<AlimentRepository>(), // j'injecte le repo
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => FeedbackRecetteController(
              context.read<FeedbackRecetteRepository>(), // j'injecte le repo
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => FrigoController(
              context.read<FrigoRepository>(), // j'injecte le repo
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => HistoriqueController(
              context.read<HistoriqueRepository>(), // j'injecte le repo
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => ProfilController(
              context.read<ProfilRepository>(), // j'injecte le repo
            ),
          ),
          ChangeNotifierProvider(
            create: (context) => RecetteController(
              context.read<RecetteRepository>(), // j'injecte le repo
            ),
          ),
        ],
        // enfin, je lance l'application
        child: const AppRecettes(), // (ton fichier app.dart)
      ),
    ),
  );
}