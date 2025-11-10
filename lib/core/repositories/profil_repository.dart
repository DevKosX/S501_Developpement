
import '../models/profil_model.dart';

/// LE CONTRAT (Interface)
/// Définit toutes les actions possibles sur le profil.
abstract class ProfilRepository {
  /// Récupère le profil unique de l'utilisateur.
  /// Renvoie null s'il n'a pas encore été créé.
  Future<ProfilModel?> getProfil();

  /// Met à jour ou crée le profil de l'utilisateur.
  Future<void> saveProfil(ProfilModel profil);
}

/// L'IMPLÉMENTATION MOCK (Code Dur) 
/// C'est la fausse base de données, pour les tests et le développement de l'UI.
class MockProfilRepository implements ProfilRepository {

  // Simule donnée profil en cache
  ProfilModel _mockProfil = ProfilModel(
    id: 1,
    poids: 75.0,
    taille: 1.80,   
    objectif: "Perdre du poids (Mock)",
  );

  @override
  Future<ProfilModel?> getProfil() async {
    // Simule délai réseau ou BDD
    await Future.delayed(const Duration(milliseconds: 500));
    print("MOCK: Récupération du profil...");
    return _mockProfil;
  }

  @override
  Future<void> saveProfil(ProfilModel profil) async {
    // Simule un délai réseau ou BDD
    await Future.delayed(const Duration(milliseconds: 500));
    _mockProfil = profil; // Met à jour le "cache" mock
    print("MOCK: Profil sauvegardé avec succès !");
    print("  -> Poids: ${profil.poids}, Taille: ${profil.taille}, Objectif: ${profil.objectif}");
  }
}

/// --- 3. L'IMPLÉMENTATION RÉELLE (Exemple pour plus tard) ---
/*
class SQLiteProfilRepository implements ProfilRepository {
  final DatabaseService _dbService;

  SQLiteProfilRepository(this._dbService);

  @override
  Future<ProfilModel?> getProfil() async {
    // Vraie logique BDD (ex: _dbService.getProfil(1))
    // ...
  }

  @override
  Future<void> saveProfil(ProfilModel profil) async {
    // Vraie logique BDD (ex: _dbService.saveProfil(profil.toMap()))
    // ...
  }
}
*/