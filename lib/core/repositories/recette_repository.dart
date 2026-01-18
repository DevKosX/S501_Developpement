import 'package:s501_developpement/core/models/ingredient_recette_model.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recette_model.dart';
import '../models/recette_aliment_model.dart';
import '../services/database_service.dart';
import 'dart:math';

/// Fichier: core/repositories/recette_repository.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 10 novembre 2025
///
/// j'ai créé ce fichier pour gérer toutes les interactions avec la base de données
/// concernant les recettes. c'est mon "Repository".
/// il fait l'intermédiaire entre mon Contrôleur (la logique) et ma BDD (le stockage).

// --- 1. LE CONTRAT ---
// j'ai défini une interface (abstract class) pour lister toutes les actions
// que mon repository DOIT savoir faire. c'est comme un cahier des charges.
abstract class RecetteRepository {
  Future<List<Recette>> getRecettes();
  Future<void> toggleFavori(Recette recette);
  Future<void> noterRecette(Recette recette, int note);
  Future<void> creerRecetteUtilisateur(Recette recette);
  Future<List<IngredientRecette>> getAllIngredientsRecettes();

  // Cette méthode s'occupe maintenant de TOUT : Calculer le score puis trier
  Future<Map<String, List<Recette>>> getRecettesTrieesParFrigo();

  Future<List<Recette>> getRecettesRecommandees();
  Future<List<IngredientRecette>> getIngredientsByRecette(int idRecette);
  Future<List<Map<String, dynamic>>> getIngredientsRaw(int idRecette);
  Future<void> addIngredientToRecette(RecetteAliment recetteAliment);
  Future<void> deleteIngredientsByRecette(int idRecette);
}

// --- 2. L'IMPLÉMENTATION RÉELLE (SQLite) ---
// ici, j'écris le vrai code qui va parler à SQLite.

class RecetteRepositoryImpl implements RecetteRepository {
  // j'ai besoin d'accéder à ma base de données. j'utilise donc mon
  // DatabaseService qui est un Singleton (une seule instance pour toute l'app).
  final DatabaseService _dbService = DatabaseService.instance;


  /// Méthode : getRecettes
  /// Rôle : Récupère toutes les recettes stockées dans la base SQLite.
  ///   Implémentation SQL
  /// SELECT * FROM Recettes


  @override
  Future<List<Recette>> getRecettes() async {
    // j'attends que la connexion à la BDD soit prête
    final db = await _dbService.database;

    // j'exécute une requête SQL simple : "SELECT * FROM Recettes"
    // cela me renvoie une liste de "Maps" (des dictionnaires clé-valeur).
    final List<Map<String, dynamic>> maps = await db.query('Recettes');

    // je dois transformer ces "Maps" bruts en vrais objets Dart "Recette".
    // j'utilise la méthode .fromMap() que j'ai codée dans mon Modèle pour ça.
    return List.generate(maps.length, (i) => Recette.fromMap(maps[i]));
  }

  

  /// -----------------------------------------------------------------------
  /// PARTIE 1 : CALCUL DU SCORE (MÉTHODE PRIVÉE)
  /// -----------------------------------------------------------------------
  /// Calcule le score en fonction de :
  /// 1. Note de base du recette (Attribut note_base)
  /// 2. Note que l'utilisateur a donné (Table FeedbackRecette)
  /// 3. La QUANTITÉ disponible dans le frigo vs requise (Table Frigo vs RecetteAliment)
  ///    (Avec conversion d'unités kg->g, l->ml, etc.)
  Future<void> _calculerEtMettreAJourScores(Database db) async {
    print("REPO: Début du recalcul (Avec Difficulté Texte & Temps)...");

    final recettesMaps = await db.query('Recettes');
    final liaisonsMaps = await db.query('RecetteAliment');
    final frigoMaps = await db.query('Frigo');
    final feedbacksMaps = await db.query('FeedbackRecette');
    final DateTime now = DateTime.now();

    for (var mapRecette in recettesMaps) {
      int idRecette = mapRecette['id_recette'] as int;

      // --- RÉCUPÉRATION DES DONNÉES ---
      double noteBase = (mapRecette['note_base'] as int? ?? 0).toDouble();
      
      // 1. Récupération du TEXTE pour la difficulté (Valeur par défaut : "Moyen")
      String difficulteTexte = (mapRecette['difficulte'] as String? ?? "Moyen");
      
      // 2. Récupération du temps (Valeur par défaut : 30 min)
      int tempsPrep = (mapRecette['temps_preparation'] as int? ?? 30);

      double scoreBrut = 0.0;

      // --- CRITÈRES NOTES & FAVORIS ---
      var feedbackList = feedbacksMaps.where((f) => f['id_recette'] == idRecette).toList();
      var feedback = feedbackList.isNotEmpty ? feedbackList.first : null;
      int noteUtilisateur = feedback != null ? (feedback['note'] as int? ?? 0) : 0;

      if (noteUtilisateur > 0) {
        scoreBrut += noteUtilisateur.toDouble() * 2;
      } else {
        scoreBrut += noteBase;
      }

      if (feedback != null && (feedback['favori'] as int? ?? 0) == 1) {
        scoreBrut += 5.0;
      }

      // ---------------------------------------------------------
      // --- NOUVEAUX CRITÈRES : DIFFICULTÉ (TEXTE) & TEMPS ---
      // ---------------------------------------------------------

      // A. Difficulté (Gestion des chaînes de caractères)
      // On met tout en minuscule et sans espaces pour être sûr de la comparaison
      String diffNorm = difficulteTexte.trim().toLowerCase();

      if (diffNorm == 'facile') {
        scoreBrut += 3.0; // Gros bonus pour la simplicité
      } else if (diffNorm == 'moyen') {
        scoreBrut += 1.0; // Petit bonus
      } else {
        // Cas 'difficile' ou autre : Pas de bonus (0.0)
      }

      // B. Temps de préparation
      if (tempsPrep <= 15) {
        scoreBrut += 4.0; // Bonus "Express"
      } else if (tempsPrep <= 30) {
        scoreBrut += 2.0; // Bonus "Rapide"
      } else if (tempsPrep > 60) {
        scoreBrut -= 2.0; // Malus "Long à faire"
      }

      // ---------------------------------------------------------
      // --- CRITÈRES FRIGO & PÉREMPTION (INCHANGÉ) ---
      // ---------------------------------------------------------
      var ingredientsDeLaRecette = liaisonsMaps.where((l) => l['id_recette'] == idRecette);

      for (var liaison in ingredientsDeLaRecette) {
        int idAlimentNecessaire = liaison['id_aliment'] as int;
        double qteRequise = (liaison['quantite'] as num).toDouble();
        String uniteRequise = (liaison['unite'] as String? ?? "").toLowerCase();

        var itemsFrigo = frigoMaps.where((f) => f['id_aliment'] == idAlimentNecessaire);

        for (var item in itemsFrigo) {
          double qteDispo = (item['quantite'] as num).toDouble();
          String uniteDispo = (item['unite'] as String? ?? "").toLowerCase();

          double qteRequiseNorm = _normaliserQuantite(qteRequise, uniteRequise);
          double qteDispoNorm = _normaliserQuantite(qteDispo, uniteDispo);

          if (qteDispoNorm >= qteRequiseNorm) {
            scoreBrut += 3.0;
          } else {
            scoreBrut += 1.0;
          }

          if (item['date_peremption'] != null) {
            try {
              DateTime datePeremption = DateTime.parse(item['date_peremption'] as String);
              int joursRestants = datePeremption.difference(now).inDays;

              if (joursRestants < 0) {
                scoreBrut -= 2.0;
              } else if (joursRestants <= 2) {
                scoreBrut += 13.0;
              } else if (joursRestants <= 5) {
                scoreBrut += 8.0;
              } else {
                scoreBrut += 2.0;
              }
            } catch (e) {
              print("Erreur parse date: $e");
            }
          }
        }
      }

      if (scoreBrut < 0) scoreBrut = 0.0;

      // ---------------------------------------------------------------------
      // --- APPLICATION DE LA TANGENTE HYPERBOLIQUE ---
      // ---------------------------------------------------------------------
      
      // J'ai augmenté la sensibilité à 40 car on ajoute potentiellement +7 points
      // avec la difficulté et le temps.
      double facteurSensibilite = 40.0;

      double x = scoreBrut / facteurSensibilite;
      double e2x = exp(2 * x);
      double tanhValue = (e2x - 1) / (e2x + 1);

      double scoreFinal = 5.0 * tanhValue;

      await db.update(
        'Recettes',
        {'score': double.parse(scoreFinal.toStringAsFixed(2))},
        where: 'id_recette = ?',
        whereArgs: [idRecette],
      );
    }
    print("REPO: Fin du recalcul (Scores lissés).");
  }
  /// Méthode utilitaire pour convertir les unités en standard
  /// Poids -> Grammes
  /// Volume -> Millilitres
  /// Autres (pcs, c.à.s) -> Valeur brute ou estimation
  double _normaliserQuantite(double qte, String unite) {
    String u = unite.trim().toLowerCase();

    switch (u) {
      // Poids
      case 'kg':
      case 'kilogramme':
      case 'kilo':
        return qte * 1000;
      case 'mg':
      case 'milligramme':
        return qte / 1000;
      case 'g':
      case 'gramme':
        return qte;

      // Volume
      case 'l':
      case 'litre':
        return qte * 1000;
      case 'dl':
      case 'décilitre':
        return qte * 100;
      case 'cl':
      case 'centilitre':
        return qte * 10;
      case 'ml':
      case 'millilitre':
        return qte;
      
      // Mesures ménagères (Estimations)
      case 'c.à.s':
      case 'cuillère à soupe':
        return qte * 15; // env. 15g/ml
      case 'c.à.c':
      case 'cuillère à café':
        return qte * 5; // env. 5g/ml
      
      // Par défaut (pcs, unités, ou inconnu), on ne touche pas
      default:
        return qte;
    }
  }


  /// -----------------------------------------------------------------------
  /// PARTIE 2 : RÉCUPÉRATION ET TRI (APPELLE PARTIE 1)
  /// -----------------------------------------------------------------------
  @override
  Future<Map<String, List<Recette>>> getRecettesTrieesParFrigo() async {
    final db = await _dbService.database;

    // ÉTAPE A : Mettre à jour les scores d'abord !
    await _calculerEtMettreAJourScores(db);

    // ÉTAPE B : Récupérer les recettes fraîchement notées
    // "ORDER BY score DESC" assure que les recettes avec le meilleur score (Note + Péremption) arrivent en premier
    final recettesMaps = await db.query('Recettes', orderBy: 'score DESC'); 
    final liaisonsMaps = await db.query('RecetteAliment');
    final frigoMaps = await db.query('Frigo');

    // 2. Je convertis les Recettes en objets Dart
    List<Recette> toutesLesRecettes = List.generate(
        recettesMaps.length, (i) => Recette.fromMap(recettesMaps[i]));


    List<Recette> faisables = [];
    List<Recette> manquantes = [];

    // ÉTAPE C : Séparer Cuisinable / À compléter (AVEC QUANTITÉS)
    for (var recette in toutesLesRecettes) {
      var ingredientsDeLaRecette = liaisonsMaps
          .where((l) => l['id_recette'] == recette.id_recette)
          .toList();

      int nbManquants = 0;

      for (var liaison in ingredientsDeLaRecette) {
        int idAlimentNecessaire = liaison['id_aliment'] as int;
        double qteRequise = (liaison['quantite'] as num).toDouble();
        String uniteRequise = (liaison['unite'] as String).toLowerCase();

        // 🔎 Recherche dans le frigo
        final itemFrigo = frigoMaps.firstWhere(
          (f) => f['id_aliment'] == idAlimentNecessaire,
          orElse: () => {},
        );

        // ❌ Aliment absent
        if (itemFrigo.isEmpty) {
          nbManquants++;
          continue;
        }

        double qteDispo = (itemFrigo['quantite'] as num).toDouble();
        String uniteDispo = (itemFrigo['unite'] as String).toLowerCase();

        // 🔄 Normalisation
        double qteRequiseNorm = _normaliserQuantite(qteRequise, uniteRequise);
        double qteDispoNorm = _normaliserQuantite(qteDispo, uniteDispo);

        // ❌ Quantité insuffisante
        if (qteDispoNorm < qteRequiseNorm) {
          nbManquants++;
        }
      }

      recette.nombreManquants = nbManquants;

      if (nbManquants == 0) {
        faisables.add(recette);
      } else {
        manquantes.add(recette);
      }
    }


    // Le tri "faisables" est déjà fait par le "ORDER BY score DESC" du SQL ci-dessus.

    // Pour les manquantes, on trie par "ce qu'il manque le moins" et "meilleur score" en second
    manquantes.sort((a, b) {
      // 1. Critère Principal : Nombre d'ingrédients manquants (Croissant / Petit vers Grand)
      int compareManquants = a.nombreManquants.compareTo(b.nombreManquants);
      
      if (compareManquants != 0) {
        // S'ils ont un nombre différent de manquants, on trie là-dessus
        return compareManquants;
      } else {
        // 2. Critère Secondaire : Si même nombre de manquants -> Score (Décroissant / Grand vers Petit)
        // Note l'inversion : b.compareTo(a)
        return b.score.compareTo(a.score);
      }
    });

    // 6. Je renvoie le tout
    return {
      "faisables": faisables,
      "manquantes": manquantes,
    };
  }


  /// Méthode : toggleFavori
  /// Rôle : permet d'activer ou désactivé le statut "favori" d’une recette.
  ///    Implémentation SQL :
  /// SELECT * FROM FeedbackRecette WHERE id_recette = ? UPDATE ou INSERT selon existence

  @override
  Future<void> toggleFavori(Recette recette) async {
    final db = await _dbService.database;
    final id = recette.id_recette;

    // je dois d'abord vérifier si j'ai DÉJÀ une ligne pour cette recette
    // dans ma table de feedback.
    var result = await db.query('FeedbackRecette', where: 'id_recette = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      // si ça existe déjà, je récupère la valeur actuelle du favori (0 ou 1)
      int currentStatus = result.first['favori'] as int? ?? 0;
      // j'inverse la valeur : si c'était 1 ça devient 0, et inversement.
      int newStatus = (currentStatus == 1) ? 0 : 1;

      // je mets à jour la ligne existante avec la nouvelle valeur.
      await db.update('FeedbackRecette', {'favori': newStatus}, where: 'id_recette = ?', whereArgs: [id]);
    } else {
      // si ça n'existait pas, c'est la première fois que l'utilisateur interagit.
      // je crée donc une nouvelle ligne et je mets favori à 1 (vrai).
      await db.insert('FeedbackRecette', {'id_recette': id, 'favori': 1});
    }
    print("REPO: favori mis à jour pour la recette $id");
  }

  /// Méthode : noterRecette
  /// Rôle : je veux enregistrer ou mettr à jour la note donnée par l’utilisateur à une recette je veux la changer en gros.
  ///   Implémentation SQL :
  /// SELECT * FROM FeedbackRecette WHERE id_recette = ?

  @override
  Future<void> noterRecette(Recette recette, int note) async {
    final db = await _dbService.database;
    final id = recette.id_recette;

    // même logique ici : je vérifie d'abord si une ligne existe déjà.
    var result = await db.query('FeedbackRecette', where: 'id_recette = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      // si elle existe, je mets juste à jour la colonne 'note'.
      await db.update('FeedbackRecette', {'note': note}, where: 'id_recette = ?', whereArgs: [id]);
    } else {
      // sinon, je crée la ligne. je mets 'favori' à 0 par défaut car
      // l'utilisateur a juste noté, il n'a pas forcément liké.
      await db.insert('FeedbackRecette', {'id_recette': id, 'note': note, 'favori': 0});
    }
    print("REPO: note $note enregistrée pour la recette $id");
  }

  /// Méthode : creerRecetteUtilisateur
  /// Rôle : methode qui ajoute une nouvelle recette par un utilisateur dans la base.
  ///    Implémentation SQL :
  /// INSERT INTO Recettes (...)

  @override
  Future<void> creerRecetteUtilisateur(Recette recette) async {
    final db = await _dbService.database;
    // pour insérer, j'utilise ma méthode .toMap() qui transforme
    // mon objet Recette en un format que SQLite comprend.
    // j'utilise conflictAlgorithm.replace pour éviter les erreurs si l'ID existe déjà.
    await db.insert(
      'Recettes',
      recette.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("REPO: nouvelle recette créée en BDD");
  }


   /// Méthode : getIngredientsByRecette
  ///
  /// Rôle :
  ///   Récupère la liste complète des ingrédients d’une recette donnée,
  ///   en fusionnant la table pivot RecetteAliment (quantité, unité, remarque)
  ///   avec la table Aliments (nom de l’aliment).
  ///
  /// Pourquoi on retourne une liste d'objets IngredientRecette :
  ///   - l’UI n’a pas besoin des IDs, nutriscore, catégorie ou marque
  ///   - seul le "nom", "quantité", "unité" et "remarque" sont utiles pour l’affichage
  ///   - cela évite de manipuler des Maps brutes dans l’interface
  ///   - facilite fortement l'affichage : “2 g de sucre”, “3 tomates”, etc.
  ///
  /// Implémentation SQL :
  /// SELECT A.nom,
  ///        RA.quantite,
  ///        RA.unite,
  ///        RA.remarque
  /// FROM RecetteAliment RA
  /// JOIN Aliments A ON A.id_aliment = RA.id_aliment
  /// WHERE RA.id_recette = ?
  ///
  /// Retour :
  ///   Une liste typée de IngredientRecette prête à être affichée dans l’UI.


  @override
Future<List<IngredientRecette>> getIngredientsByRecette(int idRecette) async {
  final db = await _dbService.database;

  final result = await db.rawQuery('''
    SELECT 
      A.nom,
      RA.quantite,
      RA.unite,
      RA.remarque
    FROM RecetteAliment RA
    JOIN Aliments A ON A.id_aliment = RA.id_aliment
    WHERE RA.id_recette = ?
  ''', [idRecette]);

  print("REPO: ${result.length} ingrédients trouvés pour la recette $idRecette");

  // Conversion en une liste d'objets IngredientRecette
  return result.map((row) {
    return IngredientRecette(
      nom: row["nom"] as String,
      quantite: (row["quantite"] as num).toDouble(),
      unite: row["unite"] as String,
      remarque: row["remarque"] as String?,
    );
  }).toList();
}

/// Version RAW pour la logique interne (ex: recommandations, frigo)
Future<List<Map<String, dynamic>>> getIngredientsRaw(int idRecette) async {
  final db = await _dbService.database;

  return await db.rawQuery('''
    SELECT 
      RA.id_aliment,
      RA.quantite,
      RA.unite,
      RA.remarque
    FROM RecetteAliment RA
    WHERE RA.id_recette = ?
  ''', [idRecette]);
}


  /// Méthode : addIngredientToRecette
  /// Rôle : je veux ajouter un ingrédient (ligne) dans la table pivot RecetteAliment avec ses attributs
  ///
  ///   Implémentation SQL :
  /// INSERT INTO RecetteAliment (id_recette, id_aliment, quantite, unite, remarque)
  /// VALUES (?, ?, ?, ?, ?)

  @override
  Future<void> addIngredientToRecette(RecetteAliment recetteAliment) async {
    final db = await _dbService.database;

    await db.insert(
      'RecetteAliment',
      recetteAliment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("REPO: ingrédient ajouté à la recette ${recetteAliment.idRecette}");
  }

  /// Méthode : deleteIngredientsByRecette
  /// Rôle : je veux supprimer toutes les lignes de la table pivot RecetteAliment liées à une recette.
  ///
  ///    Implémentation SQL :
  /// DELETE FROM RecetteAliment WHERE id_recette = ?

  @override
  Future<void> deleteIngredientsByRecette(int idRecette) async {
    final db = await _dbService.database;

    await db.delete('RecetteAliment', where: 'id_recette = ?', whereArgs: [idRecette]);
    print("REPO: ingrédients supprimés pour la recette $idRecette");
  }

  /// Méthode : getRecettesRecommandees
  /// Rôle : je veux récupérer une liste de recettes recommandées pour l'utilisateur
  /// en fonction de plusieurs critères : notes, favoris, historique, frigo.
  @override
  Future<List<Recette>> getRecettesRecommandees() async {
    // On force aussi le recalcul ici pour être sûr que les recommandations sont à jour
    final db = await _dbService.database;
    await _calculerEtMettreAJourScores(db);
    
    // On récupère simplement les recettes triées par le score calculé précédemment
    final maps = await db.query(
      'Recettes',
      orderBy: 'score DESC', // On utilise directement le score sauvegardé
      limit: 10
    );

    return List.generate(maps.length, (i) => Recette.fromMap(maps[i]));
  }


  @override
  Future<List<IngredientRecette>> getAllIngredientsRecettes() async {
    final db = await _dbService.database;

    final result = await db.rawQuery('''
      SELECT 
        A.nom,
        RA.quantite,
        RA.unite,
        RA.remarque
      FROM RecetteAliment RA
      JOIN Aliments A ON A.id_aliment = RA.id_aliment
    ''');

    return result.map((row) {
      return IngredientRecette(
        nom: row["nom"] as String,
        quantite: (row["quantite"] as num).toDouble(),
        unite: row["unite"] as String,
        remarque: row["remarque"] as String?,
      );
    }).toList();
  }



}