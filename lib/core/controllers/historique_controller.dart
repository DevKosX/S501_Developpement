import 'package:flutter/material.dart';
import '../models/historique_model.dart';
import '../repositories/historique_repository.dart';

class HistoriqueController extends ChangeNotifier {
  // Instance du repository qui gère les accès à la BDD
  final HistoriqueRepository _repository;

  // Liste des actions historiques à afficher dans la vue
  List<Historique> _historiqueList = [];
  
  // Booléen indiquant si les données sont en cours de chargement
  bool _isLoading = false;

  // Getter pour accéder à la liste depuis la vue
  List<Historique> get historiqueList => _historiqueList;
  
  // Getter pour savoir si la vue doit afficher un loader
  bool get isLoading => _isLoading;

  // Constructeur qui reçoit le repository et charge les données immédiatement
  HistoriqueController(this._repository) {
    chargerHistorique();
  }

  // Méthode asynchrone pour charger l'historique depuis la base de données
  Future<void> chargerHistorique() async {
    _isLoading = true;          // début de chargement
    notifyListeners();          // notifie la vue pour afficher un loader

    try {
      // appel au repository pour récupérer la liste historique
      _historiqueList = await _repository.getHistorique();
    } catch (e) {
      print("Erreur lors du chargement de l'historique : $e");
    }

    _isLoading = false;         // fin du chargement
    notifyListeners();          // notifie la vue que les données sont prêtes
  }

  // Enregistre une nouvelle action puis recharge la liste
  Future<void> enregistrerAction(Historique action) async {
    await _repository.enregistrerAction(action);
    await chargerHistorique();  // recharge après modification pour être à jour
  }
  Future<void> supprimerHistorique(int idHistorique) async {
    await _repository.supprimerHistorique(idHistorique);
    await chargerHistorique();
  }

}
