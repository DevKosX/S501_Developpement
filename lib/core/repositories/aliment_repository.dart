import 'package:sqflite/sqflite.dart';
import '../models/aliment_model.dart';
import '../services/database_service.dart';

abstract class AlimentRepository {
  Future<List<Aliment>> getAliments();
  Future<Aliment?> getAlimentById(int id);
  Future<List<String>> getUniqueCategories();
  List<String> getUnitesPourAliment(Aliment aliment);
}

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
  Future<List<String>> getUniqueCategories() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Aliments',
      columns: ['categorie'],
      distinct: true,
      where: 'categorie IS NOT NULL AND categorie != ?',
      whereArgs: [''],
    );
    return maps.map((map) => map['categorie'] as String).toList();
  }

  @override
  List<String> getUnitesPourAliment(Aliment aliment) {

    print("DEBUG UNITE: ${aliment.nom} (${aliment.typeGestion})");

    switch (aliment.typeGestion.trim()) {
      case 'volume':
        return ['L', 'ml', 'cl', 'c. à soupe'];
      case 'unite':
        return ['pièce'];
      case 'masse':
      default:
        return ['g', 'kg', 'c. à soupe', 'c. à café'];
    }
  }
}