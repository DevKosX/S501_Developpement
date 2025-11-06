/// Fichier: core/models/recette_model.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 5/6 novembre 2025

class Recette {
  // --- ATTRIBUTS ---
  /// J'ai défini tous les attributs en public
  int id_recette;
  String titre;
  String instructions;
  String type_recette;
  double score;
  int note_base;
  String image;
  String difficulte;

  // --- CONSTRUCTEUR ---
  /// Puisque tous mes attributs sont non-nullables j'ai rendu tous les paramètres du constructeur 'required' pour avoir une recette bien complette
  Recette({
    required this.id_recette,
    required this.titre,
    required this.instructions,
    required this.type_recette,
    required this.score,
    required this.note_base,
    required this.image,
    required this.difficulte,
  });

}