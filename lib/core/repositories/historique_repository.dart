import 'package:sqflite/sqflite.dart';
import '../models/historique_model.dart';
import '../services/database_service.dart';

abstract class HistoriqueRepository {
  Future<List<Historique>> getHistorique();
  Future<void> enregistrerAction(Historique action);
  Future<void> supprimerHistorique(int idHistorique);

}

class HistoriqueRepositoryImpl implements HistoriqueRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  Future<List<Historique>> getHistorique() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('Historique');
    return List.generate(maps.length, (i) => Historique.fromMap(maps[i]));
  }

  @override
  Future<void> enregistrerAction(Historique action) async {
    final db = await _dbService.database;
    await db.insert(
      'Historique',
      action.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("REPO: action enregistrée en BDD");
  }

  @override
  Future<void> supprimerHistorique(int idHistorique) async {
    final db = await _dbService.database;
    await db.delete(
      'Historique',
      where: 'id_historique = ?',
      whereArgs: [idHistorique],
    );
  }

}
