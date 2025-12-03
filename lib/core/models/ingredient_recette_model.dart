class IngredientRecette {
  final String nom;
  final double quantite;
  final String unite;
  final String? remarque;

  IngredientRecette({
    required this.nom,
    required this.quantite,
    required this.unite,
    this.remarque,
  });
}
