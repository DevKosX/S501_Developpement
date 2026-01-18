import 'package:s501_developpement/core/models/ingredient_recette_model.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recette_model.dart';
import '../models/recette_aliment_model.dart';
import '../services/database_service.dart';
import 'dart:math';
import '../services/unit_conversion_service.dart'; // <--- AJOUT POUR LA CONVERSION

/// Fichier: core/repositories/recette_repository.dart
/// Author: Mohamed KOSBAR , Rafi BETTAIEB
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

  // --- MÉTHODES UTILITAIRES (NOUVELLES) POUR ÉVITER LES CRASHs DE TYPAGE ---
  // Ces méthodes convertissent n'importe quoi (String, int, null) en double/int propre.
  double _toDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _toIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

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
  /// PARTIE 1 : CALCUL DU SCORE (MÉTHODE PRIVÉE SÉCURISÉE & AMÉLIORÉE)
  /// -----------------------------------------------------------------------
  /// Calcule le score en fonction de :
  /// 1. Note de base du recette (Attribut note_base)
  /// 2. Note que l'utilisateur a donné (Table FeedbackRecette)
  /// 3. La QUANTITÉ disponible dans le frigo vs requise (Table Frigo vs RecetteAliment)
  ///    (Avec conversion d'unités kg->g, l->ml, pcs->g via UnitConversionService)
  Future<void> _calculerEtMettreAJourScores(Database db) async {
    print("REPO: Début du recalcul précis (Safe Mode + UnitService)...");

    final recettesMaps = await db.query('Recettes');
    final liaisonsMaps = await db.query('RecetteAliment');
    final frigoMaps = await db.query('Frigo');
    final feedbacksMaps = await db.query('FeedbackRecette');
    
    // [NOUVEAU] Récupérer les aliments pour connaître leurs poids unitaires
    final alimentsMaps = await db.query('Aliments');
    final profilMaps = await db.query('Profil', limit: 1);
    String userObjectif = ""; 
    if (profilMaps.isNotEmpty) {
      userObjectif = profilMaps.first['objectif'] as String? ?? "";
    }
    
    // Création de la Map de poids avec conversion sécurisée
    final Map<int, double> poidsAlimentsMap = {
      for (var a in alimentsMaps) 
        _toIntSafe(a['id_aliment']): _toDoubleSafe(a['poids_unitaire'])
    };

    final DateTime now = DateTime.now();

    for (var mapRecette in recettesMaps) {
      int idRecette = _toIntSafe(mapRecette['id_recette']);

      // --- CRITÈRES STATIQUES (Avec conversion sécurisée) ---
      double noteBase = _toDoubleSafe(mapRecette['note_base']);
      
      // 1. Récupération du TEXTE pour la difficulté (Valeur par défaut : "Moyen")
      String difficulteTexte = (mapRecette['difficulte'] as String? ?? "Moyen");
      
      // 2. Récupération du temps (Valeur par défaut : 30 min)
      int tempsPrep = _toIntSafe(mapRecette['temps_preparation']);
      if (tempsPrep == 0) tempsPrep = 30;

      double scoreBrut = 0.0;

      // --- CRITÈRES FEEDBACK ---
      var feedbackList = feedbacksMaps.where((f) => _toIntSafe(f['id_recette']) == idRecette).toList();
      var feedback = feedbackList.isNotEmpty ? feedbackList.first : null;
      int noteUtilisateur = feedback != null ? _toIntSafe(feedback['note']) : 0;

      if (noteUtilisateur > 0) {
        scoreBrut += noteUtilisateur.toDouble() * 2;
      } else {
        scoreBrut += noteBase;
      }

      if (feedback != null && _toIntSafe(feedback['favori']) == 1) {
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
      // C. Densité Nutritionnelle (Calories)
      int calories = _toIntSafe(mapRecette['calories']);
      
      // On n'applique le bonus/malus que si les calories sont renseignées (> 0)
      // Logique selon l'objectif (Perte de poids / Prise de masse) ---
      // On ne fait rien si l'utilisateur n'a pas d'objectif ou si la recette n'a pas de calories
      if (userObjectif.isNotEmpty && calories > 0) {
        switch (userObjectif) {
          case "Perte de poids":
            if (calories < 400) scoreBrut += 4.0;       // Bonus léger
            else if (calories < 600) scoreBrut += 2.0;  // Petit bonus
            else if (calories > 800) scoreBrut -= 3.0;  // Malus trop riche
            break;

          case "Prise de masse":
            if (calories > 600) scoreBrut += 4.0;       // Bonus calorique
            else if (calories < 400) scoreBrut -= 2.0;  // Malus trop léger
            break;

          case "Maintien":
            if (calories >= 500 && calories <= 750) scoreBrut += 3.0; // Bonus équilibre
            break;
        }
      }

      // ---------------------------------------------------------
      // D. COMPLEXITÉ RÉELLE & ONE POT
      // ---------------------------------------------------------
      
      String instructions = mapRecette['instructions'] as String? ?? "";
      String titre = mapRecette['titre'] as String? ?? "";

      // 1. Comptage dynamique des étapes (basé sur "1. ", "2. ", etc.)
      final regexEtapes = RegExp(r'(\d+)\.\s');
      int nombreEtapes = regexEtapes.allMatches(instructions).length;

      // Si aucune numérotation trouvée, on suppose 1 étape (pour éviter division par 0 ou ratio infini)
      if (nombreEtapes == 0 && instructions.isNotEmpty) nombreEtapes = 1;

      // 2. Calcul du Ratio (Étapes / Minutes)
      if (tempsPrep > 0) {
        double ratio = nombreEtapes / tempsPrep;
        
        if (ratio > 0.5) {
          scoreBrut -= 2.0; // Pénalité : Recette trop complexe pour le temps imparti
        }
        else {
          scoreBrut += 1.0; // Bonus : Recette bien équilibrée
        }
      }

      // 3. Bonus "One Pot" (Peu de vaisselle)
      // On cherche des mots clés dans le titre ou les instructions
      bool isOnePot = titre.toLowerCase().contains("one pot") || 
                      titre.toLowerCase().contains("tout en un") ||
                      instructions.toLowerCase().contains("tout mettre dans") ||
                      instructions.toLowerCase().contains("cuire ensemble");

      if (isOnePot) {
        scoreBrut += 2.0; // Gros bonus confort !
      }

      // ---------------------------------------------------------
      // E CRITÈRES FRIGO & PÉREMPTION (AMÉLIORÉ AVEC SERVICE) ---
      // ---------------------------------------------------------
      var ingredientsDeLaRecette = liaisonsMaps.where((l) => _toIntSafe(l['id_recette']) == idRecette);

      for (var liaison in ingredientsDeLaRecette) {
        int idAliment = _toIntSafe(liaison['id_aliment']);
        double qteRequise = _toDoubleSafe(liaison['quantite']);
        String uniteRequise = (liaison['unite'] as String? ?? "").toLowerCase();

        // On récupère le poids unitaire
        double poidsUnitaire = poidsAlimentsMap[idAliment] ?? 0.0;

        var itemsFrigo = frigoMaps.where((f) => _toIntSafe(f['id_aliment']) == idAliment);

        for (var item in itemsFrigo) {
          double qteDispo = _toDoubleSafe(item['quantite']);
          String uniteDispo = (item['unite'] as String? ?? "").toLowerCase();

          // Conversion sécurisée via le Service
          double qteRequiseNorm = UnitConversionService.toGrammes(
            quantite: qteRequise,
            unite: uniteRequise,
            poidsUnitaire: poidsUnitaire
          );

          double qteDispoNorm = UnitConversionService.toGrammes(
            quantite: qteDispo,
            unite: uniteDispo,
            poidsUnitaire: poidsUnitaire
          );

          // Comparaison précise
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
                scoreBrut += 13.0; // Urgence !
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
    print("REPO: Fin du recalcul (Safe Mode).");
  }


  /// -----------------------------------------------------------------------
  /// PARTIE 2 : RÉCUPÉRATION ET TRI (APPELLE PARTIE 1 AMÉLIORÉE)
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
    final alimentsMaps = await db.query('Aliments');

    // [NOUVEAU] Map de poids sécurisée pour le tri
    final Map<int, double> poidsAlimentsMap = {
      for (var a in alimentsMaps) 
        _toIntSafe(a['id_aliment']): _toDoubleSafe(a['poids_unitaire'])
    };

    // 2. Je convertis les Recettes en objets Dart
    List<Recette> toutesLesRecettes = List.generate(
        recettesMaps.length, (i) => Recette.fromMap(recettesMaps[i]));

    List<Recette> faisables = [];
    List<Recette> manquantes = [];

    // ÉTAPE C : Séparer Cuisinable / À compléter (AVEC QUANTITÉS PRÉCISES)
    for (var recette in toutesLesRecettes) {
      var ingredientsDeLaRecette = liaisonsMaps
          .where((l) => _toIntSafe(l['id_recette']) == recette.id_recette)
          .toList();

      int nbManquants = 0;

      for (var liaison in ingredientsDeLaRecette) {
        int idAliment = _toIntSafe(liaison['id_aliment']);
        double qteRequise = _toDoubleSafe(liaison['quantite']);
        String uniteRequise = (liaison['unite'] as String? ?? "").toLowerCase();
        double poidsUnitaire = poidsAlimentsMap[idAliment] ?? 0.0;

        // 🔎 Recherche dans le frigo
        final itemsFrigo = frigoMaps.where((f) => _toIntSafe(f['id_aliment']) == idAliment);

        // ❌ Aliment absent
        if (itemsFrigo.isEmpty) {
          nbManquants++;
          continue;
        }

        // On additionne tout ce qu'on a au frigo pour cet aliment (converti en grammes)
        double totalGrammesDispo = 0.0;
        for(var item in itemsFrigo) {
           totalGrammesDispo += UnitConversionService.toGrammes(
             quantite: _toDoubleSafe(item['quantite']), 
             unite: (item['unite'] as String? ?? "").toLowerCase(), 
             poidsUnitaire: poidsUnitaire
           );
        }

        double grammesRequis = UnitConversionService.toGrammes(
          quantite: qteRequise, 
          unite: uniteRequise, 
          poidsUnitaire: poidsUnitaire
        );
        
        // ❌ Quantité insuffisante (avec petite marge d'erreur flottante de 0.1g)
        // C'est ici que l'amélioration est critique : on compare des GRAMMES
        if (totalGrammesDispo < (grammesRequis - 0.1)) {
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
      int currentStatus = _toIntSafe(result.first['favori']);
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
        quantite: _toDoubleSafe(row["quantite"]),
        unite: row["unite"] as String? ?? "",
        remarque: row["remarque"] as String?,
      );
    }).toList();
  }

  /// Version RAW pour la logique interne (ex: recommandations, frigo)
  @override
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
        quantite: _toDoubleSafe(row["quantite"]),
        unite: row["unite"] as String? ?? "",
        remarque: row["remarque"] as String?,
      );
    }).toList();
  }
}