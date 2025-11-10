

import 'package:sqflite/sqflite.dart';
import '../models/frigo_item_model.dart';
import '../services/database_service.dart';


abstract class FrigoRepository {
  /// Récupère tous les items présents dans le frigo.
  Future<List<Frigo>> getContenuFrigo();
  
  /// Ajoute un nouvel item au frigo.
  Future<void> addItemAuFrigo(Frigo item);

  /// Met à jour un item (ex: quantité, date de péremption).
  Future<void> updateItemFrigo(Frigo item);

  /// Supprime un item du frigo par son ID.
  Future<void> deleteItemFrigo(int id_frigo);
}


class FrigoRepositoryImpl implements FrigoRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  Future<List<Frigo>> getContenuFrigo() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('Frigo');
    return List.generate(maps.length, (i) => Frigo.fromMap(maps[i]));
  }

  @override
  Future<void> addItemAuFrigo(Frigo item) async {
    final db = await _dbService.database;
    // On utilise toMap() pour insérer
    await db.insert(
      'Frigo',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("REPO: Item (ID Alim: ${item.id_aliment}) ajouté au frigo.");
  }

  @override
  Future<void> updateItemFrigo(Frigo item) async {
    final db = await _dbService.database;
    await db.update(
      'Frigo',
      item.toMap(),
      where: 'id_frigo = ?', // On met à jour par l'ID du frigo
      whereArgs: [item.id_frigo],
    );
    print("REPO: Item ${item.id_frigo} mis à jour.");
  }

  @override
  Future<void> deleteItemFrigo(int id_frigo) async {
    final db = await _dbService.database;
    await db.delete(
      'Frigo',
      where: 'id_frigo = ?',
      whereArgs: [id_frigo],
    );
    print("REPO: Item $id_frigo supprimé.");
  }
}