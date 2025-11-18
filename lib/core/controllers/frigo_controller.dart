import 'package:flutter/material.dart';
import '../models/frigo_item_model.dart';
import '../models/aliment_model.dart';
import '../repositories/frigo_repository.dart';

class FrigoController extends ChangeNotifier {
  final FrigoRepository _repository;

  List<Frigo> _contenuFrigo = [];
  bool _isLoading = false;

  List<Frigo> get contenuFrigo => _contenuFrigo;
  bool get isLoading => _isLoading;

  FrigoController(this._repository) {
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
        date_ajout: itemExistant.date_ajout,
        date_peremption: itemExistant.date_peremption,
      );

      await _repository.updateItemFrigo(itemModifie);
    } else {
      final nouvelItem = Frigo(
        id_frigo: 0,
        id_aliment: aliment.id_aliment,
        quantite: 1.0,
        date_ajout: DateTime.now(),
        date_peremption: DateTime.now().add(const Duration(days: 7)),
      );

      await _repository.addItemAuFrigo(nouvelItem);
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
}