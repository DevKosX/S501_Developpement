class UnitConversionService {
  /// Conversion vers grammes (unité pivot)
  static double toGrammes({
    required double quantite,
    required String unite,
    required double poidsUnitaire,
  }) {
    switch (unite) {
      // --- POIDS ---
      case 'g':
        return quantite;

      case 'kg':
        return quantite * 1000;

      // --- VOLUME (approximation eau) ---
      case 'ml':
        return quantite; // 1ml ≈ 1g
      case 'l':
        return quantite * 1000;

      // --- UNITÉS DISCRÈTES ---
      case 'pcs':
      case 'piece':
      case 'pièce':
        return quantite * poidsUnitaire;

      case 'tranche':
      case 'tranches':
        return quantite * poidsUnitaire;

      case 'gousse':
      case 'gousses':
        return quantite * poidsUnitaire;

      case 'pot':
      case 'pots':
        return quantite * poidsUnitaire;

      case 'pavé':
        return quantite * poidsUnitaire;

      case 'pincée':
        return quantite * (poidsUnitaire > 0 ? poidsUnitaire : 1);

      default:
        throw Exception("Unité non supportée: $unite");
    }
  }

  /// Conversion inverse depuis grammes vers unité d'origine du frigo
  static double fromGrammes({
    required double grammes,
    required String unite,
    required double poidsUnitaire,
  }) {
    switch (unite) {
      case 'g':
        return grammes;

      case 'kg':
        return grammes / 1000;

      case 'ml':
        return grammes;

      case 'l':
        return grammes / 1000;

      case 'pcs':
      case 'piece':
      case 'pièce':
      case 'tranche':
      case 'tranches':
      case 'gousse':
      case 'gousses':
      case 'pot':
      case 'pots':
      case 'pavé':
        if (poidsUnitaire <= 0) return 0;
        return grammes / poidsUnitaire;

      case 'pincée':
        return grammes; // on ne reconvertit pas finement

      default:
        throw Exception("Unité non supportée: $unite");
    }
  }
}
