/// Service responsable de la gestion des unités de mesure
/// utilisées dans les recettes (extraites depuis RecetteAliment / IngredientRecette)
///
/// Objectifs :
/// - Centraliser les unités existantes
/// - Normaliser les unités équivalentes (grammes → g)
/// - Mettre en cache pour éviter les recalculs
/// - Fournir une liste prête pour un Dropdown UI

import '../models/ingredient_recette_model.dart';

class UnitService {
  /// Cache mémoire partagé dans toute l'application
  static Set<String>? _cachedUnits;

  /// Mapping pour normaliser les unités équivalentes
  /// (clé = valeur brute, valeur = unité canonique)
  static const Map<String, String> _unitAliases = {
    // --- POIDS ---
    'g': 'g',
    'gramme': 'g',
    'grammes': 'g',

    'kg': 'kg',
    'kilogramme': 'kg',
    'kilogrammes': 'kg',

    'mg': 'mg',
    'milligramme': 'mg',
    'milligrammes': 'mg',

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

    // --- UNITÉS ---
    'pcs': 'pcs',
    'pc': 'pcs',
    'piece': 'pcs',
    'pieces': 'pcs',
    'pièce': 'pcs',
    'pièces': 'pcs',
    'unite': 'pcs',
    'unites': 'pcs',
    'unité': 'pcs',
    'unités': 'pcs',

    // --- MESURES MÉNAGÈRES ---
    'c.à.s': 'c.à.s',
    'cuillère à soupe': 'c.à.s',

    'c.à.c': 'c.à.c',
    'cuillère à café': 'c.à.c',
  };

  // ---------------------------------------------------------------------------
  // EXTRACTION & CACHE
  // ---------------------------------------------------------------------------

  /// Extrait les unités depuis des objets IngredientRecette
  /// et les met en cache pour éviter tout recalcul.
  static Set<String> extractUnitsFromIngredients(
    List<IngredientRecette> ingredients,
  ) {
    // Si déjà calculé → on retourne le cache
    if (_cachedUnits != null) {
      return _cachedUnits!;
    }

    final Set<String> units = {};

    for (final ingredient in ingredients) {
      final rawUnit = ingredient.unite;

      if (rawUnit.isEmpty) continue;

      final normalized = _normalizeUnit(rawUnit);

      if (normalized.isNotEmpty) {
        units.add(normalized);
      }
    }

    _cachedUnits = units;
    return units;
  }

  /// Retourne les unités sous forme de liste triée
  /// directement exploitable dans un DropdownButton
  static List<String> getUnitsAsList(
    List<IngredientRecette> ingredients,
  ) {
    final units = extractUnitsFromIngredients(ingredients).toList();
    units.sort();
    return units;
  }

  // ---------------------------------------------------------------------------
  // UTILITAIRES
  // ---------------------------------------------------------------------------

  /// Normalise une unité brute (CSV / DB / saisie utilisateur)
  /// Exemple : " Grammes " → "g"
  static String _normalizeUnit(String unit) {
    final cleaned = unit.trim().toLowerCase();

    if (cleaned.isEmpty) return '';

    return _unitAliases[cleaned] ?? cleaned;
  }

  /// Vérifie si une unité est connue par le système
  static bool isUnitSupported(String unit) {
    final normalized = _normalizeUnit(unit);
    return _unitAliases.values.contains(normalized);
  }

  /// Vide le cache (à appeler si les recettes / ingrédients changent)
  static void clearCache() {
    _cachedUnits = null;
  }
}
