import '../models/ingredient_recette_model.dart';

class UnitService {
  // ---------------------------------------------------------------------------
  // NORMALISATION DES UNITÉS
  // ---------------------------------------------------------------------------

  static const Map<String, String> _unitAliases = {
    // poids
    'g': 'g',
    'gramme': 'g',
    'grammes': 'g',

    'kg': 'kg',
    'kilogramme': 'kg',
    'kilogrammes': 'kg',

    // volume
    'ml': 'ml',
    'millilitre': 'ml',
    'millilitres': 'ml',

    'cl': 'cl',
    'centilitre': 'cl',
    'centilitres': 'cl',

    'l': 'l',
    'litre': 'l',
    'litres': 'l',

    // unitaire
    'pcs': 'pcs',
    'pc': 'pcs',
    'piece': 'pcs',
    'pieces': 'pcs',
    'pièce': 'pcs',
    'pièces': 'pcs',
    'unité': 'pcs',
    'unités': 'pcs',
  };

  static String _normalizeUnit(String unit) {
    final cleaned = unit.trim().toLowerCase();
    if (cleaned.isEmpty) return '';
    return _unitAliases[cleaned] ?? cleaned;
  }

  // ---------------------------------------------------------------------------
  // ✅ NOUVELLE LOGIQUE : UNITÉS SELON TYPE_MESURE (FRIGO)
  // ---------------------------------------------------------------------------

  /// Utilisé dans la vue frigo / ajout d’aliment
  static List<String> getUnitsForTypeMesure(String typeMesure) {
    switch (typeMesure.toUpperCase()) {
      case 'UNITAIRE':
        return ['pcs'];

      case 'POIDS':
        return ['g', 'kg'];

      case 'VOLUME':
        return ['ml', 'cl', 'l'];

      case 'MIXTE':
        return ['pcs', 'g', 'kg'];

      case 'INCONNU':
      default:
        return ['pcs'];
    }
  }

  // ---------------------------------------------------------------------------
  // 🔙 COMPATIBILITÉ ANCIEN CODE (RECETTES)
  // ---------------------------------------------------------------------------

  /// ⚠️ À NE PAS SUPPRIMER (utilisé par RecetteController)
  static List<String> getUnitsAsList(
    List<IngredientRecette> ingredients,
  ) {
    final Set<String> units = {};

    for (final ingredient in ingredients) {
      final normalized = _normalizeUnit(ingredient.unite);
      if (normalized.isNotEmpty) {
        units.add(normalized);
      }
    }

    final result = units.isNotEmpty ? units.toList() : ['pcs'];
    result.sort();
    return result;
  }

  /// ⚠️ Méthode attendue par RecetteController
  static void clearCache() {
    // volontairement vide (compatibilité)
  }
}
