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

  /// J'ai créé cette méthode pour convertir un Map en objet dart
  factory RecetteAliment.fromMap(Map<String, dynamic> map) {
    return RecetteAliment(
      id_RecetteAliment: map['id_RecetteAliment'] as int,
      quantite: map['quantite'] as double,
      unite: map['unite'] as String,
      remarque: map['remarque'] as String,
      id_recette: map['id_recette'] as int,
      id_aliment: map['id_aliment'] as int,
    );
  }

  /// J'ai créé cette méthode pour convertir l'objet Dart en Map pour l'ecrire en sql
  Map<String, dynamic> toMap() {
    return {
      'id_RecetteAliment': id_RecetteAliment,
      'quantite': quantite,
      'unite': unite,
      'remarque': remarque,
      'id_recette': id_recette,
      'id_aliment': id_aliment,
    };
  }

}