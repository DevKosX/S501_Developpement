/// Service responsable de la gestion des unités de mesure
/// utilisées dans les recettes (extraites depuis recetteAliment).
class UnitService {
  /// Cache mémoire partagé dans toute l'application
  static Set<String>? _cachedUnits;

  /// Mapping pour normaliser les unités équivalentes
  /// (ex: "grammes" → "g")
  static const Map<String, String> _unitAliases = {
    'g': 'g',
    'gramme': 'g',
    'grammes': 'g',

    'kg': 'kg',
    'kilogramme': 'kg',
    'kilogrammes': 'kg',

    'ml': 'ml',
    'millilitre': 'ml',
    'millilitres': 'ml',

    'cl': 'cl',
    'centilitre': 'cl',
    'centilitres': 'cl',

    'l': 'l',
    'litre': 'l',
    'litres': 'l',

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
  };

  /// Extrait les unités depuis la table recette_aliment
  /// et les met en cache pour éviter tout recalcul.
  static Set<String> extractUnits(List<Map<String, dynamic>> recetteAliments) {
    // Si déjà calculé, on retourne directement le cache
    if (_cachedUnits != null) {
      return _cachedUnits!;
    }

    final Set<String> units = {};

    for (final ra in recetteAliments) {
      final rawUnit = ra['unite'];

      if (rawUnit == null) continue;

      final normalized = _normalizeUnit(rawUnit.toString());

      if (normalized.isNotEmpty) {
        units.add(normalized);
      }
    }

    _cachedUnits = units;
    return units;
  }

  /// Normalise une unité brute (CSV / DB)
  /// Exemple : " Grammes " → "g"
  static String _normalizeUnit(String unit) {
    final cleaned = unit.trim().toLowerCase();

    if (cleaned.isEmpty) return '';

    return _unitAliases[cleaned] ?? cleaned;
  }

  /// Retourne les unités sous forme de liste triée
  /// (utile directement pour un Dropdown)
  static List<String> getUnitsAsList(List<Map<String, dynamic>> recetteAliments) {
    final units = extractUnits(recetteAliments).toList();
    units.sort();
    return units;
  }

  /// Permet de vider le cache (utile si les recettes changent)
  static void clearCache() {
    _cachedUnits = null;
  }

  /// Vérifie si une unité est connue par le système
  static bool isUnitSupported(String unit) {
    final normalized = _normalizeUnit(unit);
    return _unitAliases.values.contains(normalized);
  }
}
