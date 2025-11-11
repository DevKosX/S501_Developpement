import 'package:sqflite/sqflite.dart'; 
// pour la connexion à la BDD
import '../services/database_service.dart'; 
import '../models/profil_model.dart';


/// LE CONTRAT (Interface)

abstract class ProfilRepository {

  Future<ProfilModel?> getProfil();

  Future<void> saveProfil(ProfilModel profil);
}

/// Connexion à la BD 
class ProfilRepositoryImpl implements ProfilRepository {
  
  // Récupère instance unique  du service de BDD
  final DatabaseService _dbService = DatabaseService.instance;

  @override
  Future<ProfilModel?> getProfil() async {
    final db = await _dbService.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'Profil',
      limit: 1, 
    );

    if (maps.isNotEmpty) {
      return ProfilModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<void> saveProfil(ProfilModel profil) async {
    final db = await _dbService.database;
    
    // Utilise db.insert avec 'replace' pour faire un "UPSERT" :
    // Si le profil n'existe pas il est inséré
    // Si le profil existe déjà, il est remplacé 
    await db.insert(
      'Profil',
      profil.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("REPO: Profil sauvegardé/mis à jour dans la BDD.");
  }
}


