import 'package:sqflite/sqflite.dart';
import '../models/feedback_recette_model.dart';
import '../services/database_service.dart';

abstract class FeedbackRecetteRepository {
  Future<List<FeedbackRecette>> getFeedbacks();
  Future<void> toggleFavori(FeedbackRecette feedback);
  Future<void> noterRecette(FeedbackRecette feedback, int note);
}

class FeedbackRecetteRepositoryImpl implements FeedbackRecetteRepository {
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  Future<List<FeedbackRecette>> getFeedbacks() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query('FeedbackRecette');
    return List.generate(maps.length, (i) => FeedbackRecette.fromMap(maps[i]));
  }

  @override
  Future<void> toggleFavori(FeedbackRecette feedback) async {
    final db = await _dbService.database;
    final id = feedback.id_recette;

    var result = await db.query('FeedbackRecette', where: 'id_recette = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      int currentStatus = result.first['favori'] as int? ?? 0;
      int newStatus = (currentStatus == 1) ? 0 : 1;

      await db.update('FeedbackRecette', {'favori': newStatus}, where: 'id_recette = ?', whereArgs: [id]);
    } else {
      await db.insert('FeedbackRecette', {'id_recette': id, 'favori': 1, 'note': 0});
    }
    print("REPO: favori mis à jour pour la recette $id");
  }

  @override
  Future<void> noterRecette(FeedbackRecette feedback, int note) async {
    final db = await _dbService.database;
    final id = feedback.id_recette;

    var result = await db.query('FeedbackRecette', where: 'id_recette = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      await db.update('FeedbackRecette', {'note': note}, where: 'id_recette = ?', whereArgs: [id]);
    } else {
      await db.insert('FeedbackRecette', {'id_recette': id, 'note': note, 'favori': 0});
    }
    print("REPO: note $note enregistrée pour la recette $id");
  }
}
