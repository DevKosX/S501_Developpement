import 'package:flutter/material.dart';
import 'package:s501_developpement/core/models/ingredient_recette_model.dart';
import '../models/frigo_item_model.dart';
import '../models/aliment_model.dart';
import '../repositories/frigo_repository.dart';
import '../services/unit_conversion_service.dart';
import '../repositories/aliment_repository.dart';

class FrigoController extends ChangeNotifier {
  final FrigoRepository _repository;
  final AlimentRepository _alimentRepository;

  List<Frigo> _contenuFrigo = [];
  bool _isLoading = false;

  List<Frigo> get contenuFrigo => _contenuFrigo;
  bool get isLoading => _isLoading;

  FrigoController(this._repository, this._alimentRepository) {
    chargerContenuFrigo();
  }

  Future<bool> consommerIngredientsPourRecette(
    List<IngredientRecette> ingredientsRecette,
    List<Aliment> aliments,
  ) async {
    // 🔒 1. Vérification AVANT déduction
    for (final ingredient in ingredientsRecette) {
      try {
        final aliment = aliments.firstWhere(
          (a) => a.nom.toLowerCase() == ingredient.nom.toLowerCase()

        );

        final itemFrigo = _contenuFrigo.firstWhere(
          (item) => item.id_aliment == aliment.id_aliment,
        );

        final frigoGrammes = UnitConversionService.toGrammes(
          quantite: itemFrigo.quantite,
          unite: itemFrigo.unite,
          poidsUnitaire: aliment.poids_unitaire,
        );

        final recetteGrammes = UnitConversionService.toGrammes(
          quantite: ingredient.quantite,
          unite: ingredient.unite,
          poidsUnitaire: aliment.poids_unitaire,
        );

        if (frigoGrammes < recetteGrammes) {
          return false; // ❌ pas assez d’ingrédient
        }
      } catch (e) {
        return false; // ingrédient absent du frigo
      }
    }

    // ✅ 2. Déduction réelle
    for (final ingredient in ingredientsRecette) {
      final aliment = aliments.firstWhere(
        (a) => a.nom.toLowerCase() == ingredient.nom.toLowerCase()

      );

      final itemFrigo = _contenuFrigo.firstWhere(
        (item) => item.id_aliment == aliment.id_aliment,
      );

      final frigoGrammes = UnitConversionService.toGrammes(
        quantite: itemFrigo.quantite,
        unite: itemFrigo.unite,
        poidsUnitaire: aliment.poids_unitaire,
      );

      final recetteGrammes = UnitConversionService.toGrammes(
        quantite: ingredient.quantite,
        unite: ingredient.unite,
        poidsUnitaire: aliment.poids_unitaire,
      );

      final resteGrammes = frigoGrammes - recetteGrammes;

      final nouvelleQuantite = UnitConversionService.fromGrammes(
        grammes: resteGrammes,
        unite: itemFrigo.unite,
        poidsUnitaire: aliment.poids_unitaire,
      );

      await definirQuantite(
        aliment,
        nouvelleQuantite,
        unite: itemFrigo.unite,
      );
    }

    await chargerContenuFrigo();
    notifyListeners();
    return true;
  }


  
  Future<void> chargerContenuFrigo() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contenuFrigo = await _repository.getContenuFrigo();
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// [NOUVEAU] Calcule la date par défaut selon la catégorie (Approche Hybride)
  DateTime calculerDatePeremptionParDefaut(Aliment aliment) {
    final now = DateTime.now();
    int jours = 7; // Valeur par défaut de sécurité

    // On normalise la catégorie pour éviter les soucis de majuscules
    String cat = aliment.categorie.toLowerCase().trim();

    switch (cat) {
      // Produits très périssables (3-4 jours)
      case 'viande':
      case 'poisson':
      case 'boulangerie': // Pain, etc.
        jours = 3;
        break;

      // Produits frais standards (1 semaine)
      case 'fruit':
      case 'légume':
      case 'crèmerie':
      case 'charcuterie': // Jambon, etc.
        jours = 7;
        break;

      // Produits avec conservation moyenne (2-4 semaines)
      case 'boisson':
        jours = 30; // 1 mois pour les boissons ouvertes
        break;

      // Longue conservation (6 mois et +)
      case 'épicerie':
      case 'condiment':
        jours = 180; // ~6 mois
        break;

      default:
        jours = 7; // Pour "Autre" ou catégories inconnues
    }

    return now.add(Duration(days: jours));
  }

  Future<void> ajouterAlimentDuCatalogue(Aliment aliment) async {
    Frigo? itemExistant;
    try {
      itemExistant = _contenuFrigo.firstWhere(
              (item) => item.id_aliment == aliment.id_aliment
      );
    } catch (e) {
      itemExistant = null;
    }

    if (itemExistant != null) {
      final itemModifie = Frigo(
        id_frigo: itemExistant.id_frigo,
        id_aliment: itemExistant.id_aliment,
        quantite: itemExistant.quantite + 1.0,
        unite: itemExistant.unite,
        date_ajout: itemExistant.date_ajout,
        date_peremption: itemExistant.date_peremption,
      );

      await _repository.updateItemFrigo(itemModifie);
    } else {
      String uniteParDefaut = await _alimentRepository.getUniteParDefaut(aliment.id_aliment);
      
      // Utilise le calcul par défaut lors de l'ajout rapide
      final dateDefaut = calculerDatePeremptionParDefaut(aliment);

      final nouvelItem = Frigo(
        id_frigo: 0,
        id_aliment: aliment.id_aliment,
        quantite: 1.0,
        unite: uniteParDefaut,
        date_ajout: DateTime.now(),
        date_peremption: dateDefaut,
      );

      await _repository.addItemAuFrigo(nouvelItem);
    }

    await chargerContenuFrigo();
  }

  /// Définir une quantité spécifique pour un aliment
  /// [MODIFIE] Accepte maintenant une datePeremption optionnelle
  Future<void> definirQuantite(Aliment aliment, double nouvelleQuantite, {DateTime? datePeremption},{required String unite,}) async {
    if (nouvelleQuantite <= 0) {
      try {
        final itemExistant = _contenuFrigo.firstWhere(
          (item) => item.id_aliment == aliment.id_aliment,
        );
        await _repository.deleteItemFrigo(itemExistant.id_frigo);
      } catch (e) {}
    } else {
      Frigo? itemExistant;
      try {
        itemExistant = _contenuFrigo.firstWhere(
          (item) => item.id_aliment == aliment.id_aliment,
        );
      } catch (e) {
        itemExistant = null;
      }

      // Calcul de la date finale à utiliser
      DateTime dateFinale;
      if (datePeremption != null) {
        dateFinale = datePeremption;
      } else if (itemExistant != null) {
        dateFinale = itemExistant.date_peremption; // On garde l'ancienne
      } else {
        dateFinale = calculerDatePeremptionParDefaut(aliment); // Nouveau calcul
      }

      if (itemExistant != null) {
        final itemModifie = Frigo(
          id_frigo: itemExistant.id_frigo,
          id_aliment: itemExistant.id_aliment,
          quantite: nouvelleQuantite,
          unite: unite, 
          date_ajout: itemExistant.date_ajout,
          date_peremption: dateFinale, // <-- Mise à jour avec la date
        );

        await _repository.updateItemFrigo(itemModifie);
      } else {
        final nouvelItem = Frigo(
          id_frigo: 0,
          id_aliment: aliment.id_aliment,
          quantite: nouvelleQuantite,
          unite: unite, 
          date_ajout: DateTime.now(),
          date_peremption: dateFinale, // <-- Utilisation de la date calculée/choisie
        );

        await _repository.addItemAuFrigo(nouvelItem);
      }
    }

    await chargerContenuFrigo();
  }


  Future<void> diminuerQuantite(Aliment aliment) async {
    try {
      final itemExistant = _contenuFrigo.firstWhere(
              (item) => item.id_aliment == aliment.id_aliment
      );

      if (itemExistant.quantite > 1) {
        final itemModifie = Frigo(
          id_frigo: itemExistant.id_frigo,
          id_aliment: itemExistant.id_aliment,
          quantite: itemExistant.quantite - 1.0,
          unite: itemExistant.unite,
          date_ajout: itemExistant.date_ajout,
          date_peremption: itemExistant.date_peremption,
        );
        await _repository.updateItemFrigo(itemModifie);
      } else {
        await _repository.deleteItemFrigo(itemExistant.id_frigo);
      }

      await chargerContenuFrigo();
    } catch (e) {
      print(e);
    }
  }

  Future<void> supprimerItem(int idFrigo) async {
    await _repository.deleteItemFrigo(idFrigo);
    await chargerContenuFrigo();
  }


  String getUniteAliment(int idAliment) {
    try {
      final item = _contenuFrigo.firstWhere(
        (item) => item.id_aliment == idAliment,
      );
      return item.unite;
    } catch (e) {
      return "pcs";
    }
  }

}