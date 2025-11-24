import 'package:sqflite/sqflite.dart';
import '../models/recette_model.dart';
import '../models/recette_aliment_model.dart';
import '../services/database_service.dart';

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
  Future<Map<String, List<Recette>>> getRecettesTrieesParFrigo();
  Future<List<Recette>> getRecettesRecommandees();


  ///ajout de 3 methodes essenetielles pour recette_aliments

  Future<List<Map<String, dynamic>>> getIngredientsByRecette(int idRecette);
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


  @override
  Future<Map<String, List<Recette>>> getRecettesTrieesParFrigo() async {
    final db = await _dbService.database;

    // 1. Je récupère TOUT ce dont j'ai besoin (3 requêtes SQL)
    final recettesMaps = await db.query('Recettes');
    final liaisonsMaps = await db.query('RecetteAliment');
    final frigoMaps = await db.query(
        'Frigo'); // Je regarde directement la table Frigo

    // 2. Je convertis les Recettes en objets Dart
    List<Recette> toutesLesRecettes = List.generate(
        recettesMaps.length, (i) => Recette.fromMap(recettesMaps[i]));

    // 3. Je fais une liste simple des IDs d'aliments qui sont dans mon frigo
    // (Set est plus rapide pour la recherche)
    Set<int> idsDansFrigo = frigoMaps
        .map((e) => e['id_aliment'] as int)
        .toSet();

    List<Recette> faisables = [];
    List<Recette> manquantes = [];


    for (var recette in toutesLesRecettes) {
      // Je trouve les ingrédients nécessaires pour cette recette
      var ingredientsDeLaRecette = liaisonsMaps
          .where((l) => l['id_recette'] == recette.id_recette)
          .toList();

      int nbManquants = 0;

      for (var liaison in ingredientsDeLaRecette) {
        int idAlimentNecessaire = liaison['id_aliment'] as int;

        // Si l'aliment n'est PAS dans le frigo, ça manque !
        if (!idsDansFrigo.contains(idAlimentNecessaire)) {
          nbManquants++;
        }
      }

      // Je stocke le résultat dans l'objet pour l'afficher plus tard
      recette.nombreManquants = nbManquants;

      if (nbManquants == 0) {
        faisables.add(recette);
      } else {
        manquantes.add(recette);
      }
    }

    manquantes.sort((a, b) => a.nombreManquants.compareTo(b.nombreManquants));

    // 6. Je renvoie le tout
    return {
      "faisables": faisables,
      "manquantes": manquantes,
    };
  }


  // --------------------------------------------------------------------------
  // === NOUVELLES MÉTHODES LIÉES À RecetteAliment ===
  // --------------------------------------------------------------------------

  /// Méthode : getIngredientsByRecette
  /// Rôle : je veu récupèrer une liste complète des ingrdients (avec quantité, unité, remarque) pour une recette donnée.
  ///
  ///   Implémentation SQL :
  /// SELECT A.nom, A.marque, A.categorie, A.nutriscore,
  ///        RA.quantite, RA.unite, RA.remarque
  /// FROM RecetteAliment RA
  /// JOIN Aliments A ON A.id_aliment = RA.id_aliment
  /// WHERE RA.id_recette = ?

  @override
  Future<List<Map<String, dynamic>>> getIngredientsByRecette(int idRecette) async {
    final db = await _dbService.database;

    //j'ai ajoute l'id_aliment
    final result = await db.rawQuery('''
      SELECT A.id_aliment,A.nom, A.marque,A.categorie, A.nutriscore, 
             RA.quantite, RA.unite, RA.remarque
      FROM RecetteAliment RA
      JOIN Aliments A ON A.id_aliment = RA.id_aliment
      WHERE RA.id_recette = ?
    ''', [idRecette]);

    print("REPO: ${result.length} ingrédients trouvés pour la recette $idRecette");
    return result;
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
    final db = await _dbService.database;

    // 1. Récupération des données
    final List<Recette> toutesLesRecettes = await getRecettes();
    final List<Map<String, dynamic>> rawFrigo = await db.query('Frigo');
    final List<Map<String, dynamic>> rawHistorique = await db.query('Historique');
    final List<Map<String, dynamic>> rawFeedbacks = await db.query('FeedbackRecette');

    List<Map<String, dynamic>> recettesAvecScore = [];

    // 2. Calcul du score pour chaque recette
    for (var recette in toutesLesRecettes) {
      double score = 0.0;

      // A. Notes & Favoris
      var feedbackList = rawFeedbacks.where((f) => f['id_recette'] == recette.id_recette).toList();
      var feedback = feedbackList.isNotEmpty ? feedbackList.first : null;

      if (feedback != null) {
        int noteUser = feedback['note'] as int? ?? 0;
        score += (noteUser > 0) ? noteUser.toDouble() : recette.noteBase;
        if ((feedback['favori'] as int? ?? 0) == 1) score += 20.0;
      } else {
        score += recette.noteBase;
      }

      // B. Historique (+1 par réalisation)
      int nbFoisFaite = rawHistorique.where((h) => h['id_recette'] == recette.id_recette).length;
      score += nbFoisFaite * 1.0;

      // C. Frigo & Anti-Gaspi
      List<Map<String, dynamic>> ingredientsRecette = await getIngredientsByRecette(recette.id_recette);

      for (var ingredient in ingredientsRecette) {
        int idAlimentRecette = ingredient['id_aliment'];
        var itemsCorrespondants = rawFrigo.where((item) => item['id_aliment'] == idAlimentRecette);

        if (itemsCorrespondants.isNotEmpty) {
          score += 10.0; // Présent dans le frigo

          var itemFrigo = itemsCorrespondants.first;
          if (itemFrigo['date_peremption'] != null) {
            DateTime datePeremption = DateTime.parse(itemFrigo['date_peremption']);
            DateTime now = DateTime.now();
            Duration difference = datePeremption.difference(now);

            // Bonus urgence (périme dans <= 3 jours)
            if (difference.inDays <= 3 && difference.inDays > -2) {
              score += 15.0;
            }
          }
        }
      }

      recettesAvecScore.add({'recette': recette, 'score': score});
    }

    // 3. Tri (Score décroissant)
    recettesAvecScore.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return recettesAvecScore.map((e) => e['recette'] as Recette).toList();
  }


}