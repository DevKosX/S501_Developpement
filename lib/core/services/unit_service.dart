import '../models/ingredient_recette_model.dart';
import '../models/aliment_model.dart';

class UnitService {
  // ---------------------------------------------------------------------------
  // NORMALISATION DES UNITÉS (RECETTES / CSV / DB)
  // ---------------------------------------------------------------------------

  static const Map<String, String> _unitAliases = {
    // --- POIDS ---
    'g': 'g',
    'gramme': 'g',
    'grammes': 'g',

    'kg': 'kg',
    'kilogramme': 'kg',
    'kilogrammes': 'kg',

    // --- VOLUME ---
    'ml': 'ml',
    'millilitre': 'ml',
    'millilitres': 'ml',

    'cl': 'cl',
    'centilitre': 'cl',
    'centilitres': 'cl',

    'l': 'l',
    'litre': 'l',
    'litres': 'l',

    // --- UNITAIRE ---
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
  // ✅ UTILISÉ PAR LA VUE FRIGO (AJOUT D’ALIMENT)
  // ---------------------------------------------------------------------------

  /// Retourne les unités disponibles selon type_mesure (Aliments)
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
  // 🔙 COMPATIBILITÉ ANCIEN CODE (RecetteController)
  // ⚠️ À NE SURTOUT PAS SUPPRIMER
  // ---------------------------------------------------------------------------

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

  /// Méthode attendue par l’ancien code (cache supprimé volontairement)
  static void clearCache() {
    // volontairement vide (compatibilité)
  }

  // ---------------------------------------------------------------------------
  // 🔥 CONVERSION MÉTIER (FRIGO ⇄ RECETTES)
  // ---------------------------------------------------------------------------

  /// Convertit une quantité vers une unité de base :
  /// - POIDS   → grammes
  /// - VOLUME  → millilitres
  /// - UNITAIRE → pièces
  static double toBase({
    required double quantite,
    required String unite,
    required Aliment aliment,
  }) {
    final u = unite.toLowerCase();

    switch (aliment.type_mesure.toUpperCase()) {

      case 'POIDS':
        if (u == 'kg') return quantite * 1000;
        if (u == 'g') return quantite;
        return quantite;

      case 'VOLUME':
        if (u == 'l') return quantite * 1000;
        if (u == 'cl') return quantite * 10;
        if (u == 'ml') return quantite;
        return quantite;

      case 'UNITAIRE':
        if (u == 'pcs') return quantite;

        // Conversion poids → unités si poids_unitaire connu
        if (aliment.poids_unitaire > 0) {
          if (u == 'g') return quantite / aliment.poids_unitaire;
          if (u == 'kg') return (quantite * 1000) / aliment.poids_unitaire;
        }
        return quantite;

      case 'MIXTE':
        if (u == 'kg') return quantite * 1000;
        if (u == 'g') return quantite;
        return quantite;

      default:
        return quantite;
    }
  }
}
