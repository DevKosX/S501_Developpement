import 'package:flutter/material.dart';
import '../models/frigo_item_model.dart';
import '../models/aliment_model.dart';
import '../repositories/frigo_repository.dart';
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

      final nouvelItem = Frigo(
        id_frigo: 0,
        id_aliment: aliment.id_aliment,
        quantite: 1.0,
        unite: uniteParDefaut,
        date_ajout: DateTime.now(),
        date_peremption: DateTime.now().add(const Duration(days: 7)),
      );

      await _repository.addItemAuFrigo(nouvelItem);
    }

    await chargerContenuFrigo();
  }

  /// Définir une quantité spécifique pour un aliment
  Future<void> definirQuantite(Aliment aliment, double nouvelleQuantite) async {
    if (nouvelleQuantite <= 0) {
      // Si la quantité est 0 ou négative, on supprime l'item
      try {
        final itemExistant = _contenuFrigo.firstWhere(
                (item) => item.id_aliment == aliment.id_aliment
        );
        await _repository.deleteItemFrigo(itemExistant.id_frigo);
      } catch (e) {
        // L'item n'existe pas, rien à faire
      }
    } else {
      Frigo? itemExistant;
      try {
        itemExistant = _contenuFrigo.firstWhere(
                (item) => item.id_aliment == aliment.id_aliment
        );
      } catch (e) {
        itemExistant = null;
      }

      if (itemExistant != null) {
        // Mettre à jour la quantité existante
        final itemModifie = Frigo(
          id_frigo: itemExistant.id_frigo,
          id_aliment: itemExistant.id_aliment,
          quantite: nouvelleQuantite,
          unite: itemExistant.unite,
          date_ajout: itemExistant.date_ajout,
          date_peremption: itemExistant.date_peremption,
        );

        await _repository.updateItemFrigo(itemModifie);
      } else {
        // Créer un nouvel item avec la quantité spécifiée
        String uniteParDefaut = await _alimentRepository.getUniteParDefaut(aliment.id_aliment);

        final nouvelItem = Frigo(
          id_frigo: 0,
          id_aliment: aliment.id_aliment,
          quantite: nouvelleQuantite,
          unite: uniteParDefaut,
          date_ajout: DateTime.now(),
          date_peremption: DateTime.now().add(const Duration(days: 7)),
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
              (item) => item.id_aliment == idAliment
      );
      return item.unite;
    } catch (e) {
      return "pcs";
    }
  }
}