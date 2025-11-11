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

    final result = await db.rawQuery('''
      SELECT A.nom, A.marque, A.categorie, A.nutriscore, 
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
    print("REPO: ingrédient ajouté à la recette ${recetteAliment.id_recette}");
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
}