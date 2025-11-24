import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  DatabaseService._privateConstructor();
  static final DatabaseService instance = DatabaseService._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_recettes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.transaction((txn) async {

      await txn.execute('''
        CREATE TABLE Recettes (
          id_recette INTEGER PRIMARY KEY,
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
          id_aliment INTEGER PRIMARY KEY,
          nom TEXT,
          categorie TEXT,
          nutriscore TEXT,
          image TEXT,
          type_gestion TEXT
        );
      ''');


      await txn.execute('''
        CREATE TABLE RecetteAliment (
          id_RecetteAliment INTEGER PRIMARY KEY,
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
          unite TEXT,  
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

      await txn.rawInsert(
          'INSERT INTO Profil (id, poids, taille, objectif) VALUES (1, 0.0, 0.0, "Aucun")'
      );

      // IMPORTS CSV
      await _importerCSV(txn, 'assets/db/aliments.csv',
          'INSERT INTO Aliments (id_aliment, nom, categorie, nutriscore, image, type_gestion) VALUES (?, ?, ?, ?, ?, ?)'
      );

      await _importerCSV(txn, 'assets/db/recettes.csv',
          'INSERT INTO Recettes (id_recette, titre, instructions, type_recette, score, note_base, image, difficulte) VALUES (?, ?, ?, ?, ?, ?, ?, ?)'
      );

      await _importerCSV(txn, 'assets/db/recetteAliment.csv',
          'INSERT INTO RecetteAliment (id_RecetteAliment, id_recette, id_aliment, quantite, unite, remarque) VALUES (?, ?, ?, ?, ?, ?)'
      );
    });
  }

  Future<void> _importerCSV(Transaction txn, String assetPath, String sqlQuery) async {
    try {
      final csvData = await rootBundle.loadString(assetPath);
      List<List<dynamic>> rows = const CsvToListConverter(fieldDelimiter: ',', eol: '\n').convert(csvData);

      for (int i = 1; i < rows.length; i++) {
        List<dynamic> row = rows[i];
        if (row.length > 1) {

          if (row.length >= 6 && row[5] is String) {
            row[5] = row[5].toString().trim();
          }
          await txn.rawInsert(sqlQuery, row);
        }
      }
    } catch (e) {
      print("Erreur CSV $assetPath : $e");
    }
  }
}