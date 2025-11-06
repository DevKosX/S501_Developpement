/// Fichier: core/models/recette_aliment__model.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 5/6 novembre 2025


class RecetteAliment {
  int id_RecetteAliment;
  double quantite;
  String unite;
  String remarque;

  RecetteAliment({
    required this.id_RecetteAliment,
    required this.quantite,
    required this.unite,
    required this.remarque,
  });
}