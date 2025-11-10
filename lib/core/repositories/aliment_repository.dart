

import 'package:sqflite/sqflite.dart';
import '../models/aliment_model.dart';
import '../services/database_service.dart'; 


abstract class AlimentRepository {
  /// Récupère l'intégralité du catalogue d'aliments.
  Future<List<Aliment>> getAliments();

  /// Récupère un aliment par son ID.
  Future<Aliment?> getAlimentById(int id);
  
 
  // Future<void> addAliment(Aliment aliment);
}


class AlimentRepositoryImpl implements AlimentRepository {
  // Accès au Singleton de la BDD
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  Future<List<Aliment>> getAliments() async {
    final db = await _dbService.database;
    
    // Requête SQL pour lire toute la table 'Aliments'
    final List<Map<String, dynamic>> maps = await db.query('Aliments');

    // Transformation des Maps en objets Aliment
    return List.generate(maps.length, (i) => Aliment.fromMap(maps[i]));
  }

  @override
  Future<Aliment?> getAlimentById(int id) async {
    final db = await _dbService.database;
    
    // Requête SQL pour trouver UN aliment par son ID
    final List<Map<String, dynamic>> maps = await db.query(
      'Aliments',
      where: 'id_aliment = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Aliment.fromMap(maps.first);
    }
    return null; // Retourne null si non trouvé
  }
  
  // Exemple d'implémentation pour un ajout
  /*
  @override
  Future<void> addAliment(Aliment aliment) async {
    final db = await _dbService.database;
    await db.insert(
      'Aliments',
      aliment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  */
}