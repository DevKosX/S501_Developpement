
import 'package:flutter/material.dart';
import '../models/frigo_item_model.dart';
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



  /// Charge (ou recharge) la liste des items du frigo.
  Future<void> chargerContenuFrigo() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contenuFrigo = await _repository.getContenuFrigo();
    } catch (e) {
      print("ERREUR chargement frigo: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Demande au repository d'ajouter un item.
  Future<void> ajouterItem(Frigo item) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.addItemAuFrigo(item);
      // Après l'ajout, on recharge toute la liste
      await chargerContenuFrigo(); 
    } catch (e) {
      print("ERREUR ajout item frigo: $e");
      _isLoading = false;
      notifyListeners();
    }
    // isLoading est remis à false par chargerContenuFrigo
  }

  /// Demande au repository de supprimer un item.
  Future<void> supprimerItem(int id_frigo) async {
    try {
      await _repository.deleteItemFrigo(id_frigo);
      // Recharge la liste pour mettre à jour l'UI
      await chargerContenuFrigo();
    } catch (e) {
      print("ERREUR suppression item frigo: $e");
    }
  }

  /// Demande au repository de mettre à jour un item.
  Future<void> mettreAJourItem(Frigo item) async {
    try {
      await _repository.updateItemFrigo(item);
      // Recharge la liste
      await chargerContenuFrigo();
    } catch (e) {
      print("ERREUR màj item frigo: $e");
    }
  }
}