/// Fichier: core/models/recette_aliment__model.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 5/6 novembre 2025

/// ce modele est une classe pivot qui sert de liaison entre les recettess et les aliments dans ces recettes

class RecetteAliment {
  int id_RecetteAliment;
  double quantite;
  String unite;
  String remarque;

  // --- CONSTRUCTEUR ---

  RecetteAliment({
    required this.id_RecetteAliment,
    required this.quantite,
    required this.unite,
    required this.remarque,
  });


// --- GETTERS ---


  int getIdRecetteAliment() {
    return id_RecetteAliment;
  }

  double getQuantite() {
    return quantite;
  }

  String getUnite() {
    return unite;
  }

  String getRemarque() {
    return remarque;
  }

  // J'ajoute les getters pour les IDs de liaison on en aura sûrement besoin les gars.
  int getIdRecette() {
    return id_recette;
  }
  // pareil
  int getIdAliment() {
    return id_aliment;
  }

}