import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Fichier: core/services/database_service.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 11 novembre 2025
///
/// j'ai créé ce service comme un Singleton pour gérer la connexion
/// unique à la base de données SQLite. c'est le seul endroit qui connaît le SQL.

class DatabaseService {
  // --- Singleton ---
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  // getter pour la base de données : j'assure qu'elle est ouverte
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // initialisation et connexion au fichier .db
  Future<Database> _initDatabase() async {
    // 1. je trouve l'endroit sécurisé où stocker le fichier
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'app_recettes.db');

    // 2. j'ouvre (ou crée) la base de données à la version 1
    return await openDatabase(
      path,
      version: 1, // version initiale
      onCreate: _onCreate, // méthode appelée seulement si le fichier BDD n'existe pas
    );
  }

  // --- CRÉATION DU SCHÉMA (Migration V1) ---
  /// c'est ici que je crée toutes mes tables ET que j'insère les données
  /// de base fournies dans `test_database.sql`.
  Future<void> _onCreate(Database db, int version) async {
    print("BDD: Exécution de la migration V1 (CREATE TABLE + INSERT DATA)");

    // j'utilise une transaction pour m'assurer que tout
    // s'exécute correctement en une seule fois.
    await db.transaction((txn) async {

      // --- 1. CRÉATION DES TABLES (Syntaxe SQLite) ---

      await txn.execute('''
        CREATE TABLE Recettes (
          id_recette INTEGER PRIMARY KEY AUTOINCREMENT,
          titre TEXT,
          instructions TEXT,
          type_recette TEXT,
          score REAL,
          note_base INTEGER,
          image TEXT,
          difficulte TEXT
        );
      ''');

      await txn.execute('''
        CREATE TABLE Aliments (
          id_aliment INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT,
          categorie TEXT,
          nutriscore TEXT,
          image TEXT
        );
      ''');

      await txn.execute('''
        CREATE TABLE RecetteAliment (
          id_RecetteAliment INTEGER PRIMARY KEY AUTOINCREMENT,
          id_recette INTEGER,
          id_aliment INTEGER,
          quantite REAL,
          unite TEXT,
          remarque TEXT,
          FOREIGN KEY (id_recette) REFERENCES Recettes(id_recette),
          FOREIGN KEY (id_aliment) REFERENCES Aliments(id_aliment)
        );
      ''');

      await txn.execute('''
        CREATE TABLE Profil (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          poids REAL,
          taille REAL,
          objectif TEXT
        );
      ''');

      await txn.execute('''
        CREATE TABLE Frigo (
          id_frigo INTEGER PRIMARY KEY AUTOINCREMENT,
          id_aliment INTEGER,
          quantite REAL,
          date_ajout TEXT,
          date_peremption TEXT,
          FOREIGN KEY (id_aliment) REFERENCES Aliments(id_aliment)
        );
      ''');

      await txn.execute('''
        CREATE TABLE Historique (
          id_historique INTEGER PRIMARY KEY AUTOINCREMENT,
          id_recette INTEGER,
          date_action TEXT,
          duree_totale_min INTEGER,
          FOREIGN KEY (id_recette) REFERENCES Recettes(id_recette)
        );
      ''');

      await txn.execute('''
        CREATE TABLE FeedbackRecette (
          id_recette INTEGER PRIMARY KEY,
          favori INTEGER,
          note INTEGER,
          FOREIGN KEY (id_recette) REFERENCES Recettes(id_recette)
        );
      ''');

      // --- 2. INSERTION DES DONNÉES DE BASE ---

      // j'initialise le profil (table singleton)
      await txn.rawInsert(
          'INSERT INTO Profil (id, poids, taille, objectif) VALUES (1, 0.0, 0.0, "Aucun")'
      );

      // j'insère les recettes
      await txn.rawInsert(
          '''INSERT INTO Recettes (titre, instructions, type_recette, score, note_base, image, difficulte) VALUES
        ('No-Bake Nut Cookies', 'In a heavy saucepan, mix brown sugar, milk, vanilla, and butter. Bring to boil...', 'Dessert', 4.5, 10, 'https://loremflickr.com/320/240/cookie', 'Facile'),
        ('Jewell Ball''S Chicken', 'Place chipped beef on bottom of baking dish. Arrange chicken over beef...', 'Plat principal', 4.2, 8, 'https://loremflickr.com/320/240/chicken', 'Moyenne'),
        ('Creamy Corn', 'In a slow cooker, combine all ingredients. Cook until creamy...', 'Accompagnement', 4.6, 9, 'https://loremflickr.com/320/240/corn', 'Facile'),
        ('Chicken Funny', 'Boil and debone chicken. Mix with soup and serve hot...', 'Plat principal', 4.0, 7, 'https://loremflickr.com/320/240/chicken', 'Facile'),
        ('Reeses Cups (Candy)', 'Combine first four ingredients and press in pan...', 'Dessert', 4.8, 10, 'https://loremflickr.com/320/240/chocolate', 'Facile'),
        ('Quick Chili', 'Brown beef, add beans, tomato sauce, and chili powder...', 'Plat principal', 4.3, 9, 'https://loremflickr.com/320/240/chili', 'Moyenne'),
        ('Pineapple Pie', 'Mix pineapple, sugar, and eggs. Pour into crust and bake...', 'Dessert', 4.7, 9, 'https://loremflickr.com/320/240/pie', 'Moyenne'),
        ('Garlic Butter Shrimp', 'Sauté shrimp in garlic butter sauce for 5 minutes...', 'Plat principal', 4.9, 10, 'https://loremflickr.com/320/240/shrimp', 'Facile'),
        ('Vegetable Soup', 'Combine all vegetables, broth, and spices. Simmer for 30 minutes...', 'Soupe', 4.4, 8, 'https://loremflickr.com/320/240/soup', 'Facile'),
        ('Chocolate Mousse', 'Melt chocolate, mix with cream and eggs, chill 2 hours...', 'Dessert', 4.9, 10, 'https://loremflickr.com/320/240/mousse', 'Moyenne')'''
      );

      // j'insère les aliments
      await txn.rawInsert(
          '''INSERT INTO Aliments (nom, categorie, nutriscore, image) VALUES
        ('brown sugar', 'sucre', 'D', 'https://loremflickr.com/320/240/sugar'),
        ('milk', 'produit laitier', 'B', 'https://loremflickr.com/320/240/milk'),
        ('vanilla', 'arôme', 'A', 'https://loremflickr.com/320/240/vanilla'),
        ('butter', 'matière grasse', 'C', 'https://loremflickr.com/320/240/butter'),
        ('chicken', 'viande', 'B', 'https://loremflickr.com/320/240/chicken'),
        ('corn', 'légume', 'A', 'https://loremflickr.com/320/240/corn'),
        ('peanut butter', 'fruit sec', 'B', 'https://loremflickr.com/320/240/peanutbutter'),
        ('beef', 'viande', 'C', 'https://loremflickr.com/320/240/beef'),
        ('pineapple', 'fruit', 'A', 'https://loremflickr.com/320/240/pineapple'),
        ('shrimp', 'fruit de mer', 'B', 'https://loremflickr.com/320/240/shrimp'),
        ('vegetables', 'légume', 'A', 'https://loremflickr.com/320/240/vegetable'),
        ('chocolate', 'sucre', 'E', 'https://loremflickr.com/320/240/chocolate')'''
      );

      // j'insère les liaisons recette-aliment
      await txn.rawInsert(
          '''INSERT INTO RecetteAliment (id_recette, id_aliment, quantite, unite, remarque) VALUES
        (1, 1, 1.0, 'cup', 'firmly packed'),
        (1, 2, 0.5, 'cup', 'evaporated'),
        (1, 3, 1.0, 'tsp', ''),
        (1, 4, 0.5, 'cup', 'melted'),
        (2, 5, 4.0, 'pcs', 'boned and skinned'),
        (2, 8, 1.0, 'jar', 'chipped beef'),
        (3, 6, 16.0, 'oz', 'frozen'),
        (3, 4, 1.0, 'tbsp', 'melted'),
        (4, 5, 1.0, 'whole', ''),
        (4, 3, 1.0, 'tsp', ''),
        (5, 7, 1.0, 'cup', ''),
        (5, 1, 0.75, 'cup', ''),
        (5, 4, 0.5, 'cup', ''),
        (6, 8, 500.0, 'g', ''),
        (6, 11, 200.0, 'g', ''),
        (6, 4, 1.0, 'tbsp', ''),
        (7, 9, 1.0, 'cup', ''),
        (7, 1, 0.5, 'cup', ''),
        (7, 2, 0.25, 'cup', ''),
        (8, 10, 200.0, 'g', ''),
        (8, 4, 1.0, 'tbsp', ''),
        (8, 3, 0.5, 'tsp', ''),
        (9, 11, 300.0, 'g', ''),
        (9, 2, 2.0, 'cup', ''),
        (9, 4, 1.0, 'tbsp', ''),
        (10, 12, 200.0, 'g', ''),
        (10, 2, 1.0, 'cup', ''),
        (10, 4, 1.0, 'tbsp', '')'''
      );

    });
  }

// --- FUTURES MÉTHODES CRUD (à implémenter dans les Repositories) ---
// je laisse cet espace pour que les Repositories puissent appeler
// des méthodes CRUD génériques ou spécifiques de ce service.
}