class UnitConversionService {
  /// Conversion vers grammes (unité pivot pour les calculs)
  static double toGrammes({
    required double quantite,
    required String unite,
    required double poidsUnitaire,
  }) {
    // Nettoyage de la chaîne (minuscule + trim)
    final u = unite.toLowerCase().trim();

    switch (u) {
      // --- POIDS ---
      case 'g':
      case 'gr':
      case 'gramme':
      case 'grammes':
        return quantite;

      case 'kg':
      case 'kilo':
      case 'kilogramme':
      case 'kilogrammes':
        return quantite * 1000;

      case 'mg':
      case 'milligramme':
      case 'milligrammes':
        return quantite / 1000;

      // --- VOLUME (approximation eau : 1ml = 1g) ---
      case 'ml':
      case 'millilitre':
      case 'millilitres':
        return quantite; 
      
      case 'cl':
      case 'centilitre':
      case 'centilitres':
        return quantite * 10;
        
      case 'dl':
      case 'decilitre':
      case 'décilitre':
        return quantite * 100;

      case 'l':
      case 'litre':
      case 'litres':
        return quantite * 1000;

      // --- MESURES MÉNAGÈRES (Estimations standards) ---
      case 'c.s.':
      case 'cs':
      case 'c.à.s':
      case 'cuillère à soupe':
      case 'cuillere a soupe':
      case 'cuillères à soupe':
        return quantite * 15; // ~15g

      case 'c.c.':
      case 'cc':
      case 'c.à.c':
      case 'cuillère à café':
      case 'cuillere a cafe':
      case 'cuillères à café':
        return quantite * 5; // ~5g

      case 'pincée':
      case 'pincee':
      case 'pincées':
        return quantite * 0.5; // ~0.5g (négligeable mais non nul)

      // --- UNITÉS DISCRÈTES (nécessite un poids unitaire) ---
      // Si l'aliment a un poids défini en base (ex: 1 pomme = 150g), on multiplie.
      // Sinon (poidsUnitaire = 0), on garde la quantité brute (ex: 1 filet d'huile).
      
      case 'pcs':
      case 'pc':
      case 'piece':
      case 'pièce':
      case 'pièces':
      case 'unité':
      case 'unités':
      
      case 'tranche':
      case 'tranches':
      
      case 'gousse':
      case 'gousses':
      
      case 'pot':
      case 'pots':
      
      case 'pavé':
      case 'pavés':
      
      case 'boite':
      case 'boîte':
      case 'boites':
      
      case 'filet':   // Ajouté (ex: filet de poulet OU filet de citron)
      case 'filets':
      
      case 'botte':   // Ajouté (ex: botte de radis)
      case 'bottes':
      
      case 'feuille': // Ajouté (ex: feuille de laurier/gélatine)
      case 'feuilles':
        return quantite * (poidsUnitaire > 0 ? poidsUnitaire : 1);

      default:
        // Au lieu de planter, on loggue l'erreur et on renvoie la quantité brute
        print("UnitConversionService: Unité inconnue '$unite', conversion brute appliquée.");
        return quantite;
    }
  }

  /// Conversion inverse (Grammes -> Unité d'origine)
  /// Utile si on veut afficher "Il vous manque 200g (environ 2 pommes)"
  static double fromGrammes({
    required double grammes,
    required String unite,
    required double poidsUnitaire,
  }) {
    final u = unite.toLowerCase().trim();

    switch (u) {
      // Poids
      case 'g':
      case 'gr':
      case 'gramme':
      case 'grammes':
        return grammes;

      case 'kg':
      case 'kilo':
        return grammes / 1000;
        
      case 'mg':
        return grammes * 1000;

      // Volume
      case 'ml':
        return grammes;
      case 'cl':
        return grammes / 10;
      case 'dl':
        return grammes / 100;
      case 'l':
      case 'litre':
        return grammes / 1000;

      // Ménager
      case 'c.s.':
      case 'cs':
      case 'c.à.s':
        return grammes / 15;

      case 'c.c.':
      case 'cc':
      case 'c.à.c':
        return grammes / 5;

      // Pièces / Autres
      case 'pcs':
      case 'piece':
      case 'pièce':
      case 'tranche':
      case 'tranches':
      case 'gousse':
      case 'pot':
      case 'pavé':
      case 'filet':
      case 'filets':
      case 'botte':
      case 'feuille':
      case 'feuilles':
        if (poidsUnitaire <= 0) return grammes; 
        return grammes / poidsUnitaire;

      case 'pincée':
        return grammes; 

      default:
        return grammes;
    }
  }
}