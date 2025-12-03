import 'package:sqflite/sqflite.dart';
import '../models/aliment_model.dart';
import '../services/database_service.dart';

/// Interface abstraite - LE CONTRAT
abstract class AlimentRepository {
  Future<List<Aliment>> getAliments();
  Future<Aliment?> getAlimentById(int id);
  Future<String> getUniteParDefaut(int idAliment);
  Future<List<String>> getCategories(); // <-- Cette ligne doit être présente !
}

/// Implémentation concrète
class AlimentRepositoryImpl implements AlimentRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  Future<List<Aliment>> getAliments() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('Aliments');
    return List.generate(maps.length, (i) => Aliment.fromMap(maps[i]));
  }

  @override
  Future<Aliment?> getAlimentById(int id) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Aliments',
      where: 'id_aliment = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Aliment.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<String> getUniteParDefaut(int idAliment) async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT unite, COUNT(*) as count
      FROM RecetteAliment
      WHERE id_aliment = ?
      GROUP BY unite
      ORDER BY count DESC
      LIMIT 1
    ''', [idAliment]);

    if (result.isNotEmpty && result.first['unite'] != null) {
      return result.first['unite'] as String;
    }

    return "pcs";
  }

  @override
  Future<List<String>> getCategories() async {
    final db = await _dbService.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT categorie 
      FROM Aliments 
      WHERE categorie IS NOT NULL AND categorie != ''
      ORDER BY categorie ASC
    ''');

    List<String> categories = result
        .map((map) => map['categorie'] as String)
        .toList();

    return categories;
  }
}