import 'package:flutter/material.dart';
import 'historique_model.dart'; // Adaptera le chemin si besoin

class HistoriqueController extends ChangeNotifier {
  // 1. L'état
  List<Historique> _historiqueActions = [];

  // 2. Getter
  List<Historique> get historiqueActions => _historiqueActions;

  // 3. Logique métier

  /// Charger historique simulé
  void chargerHistorique() {
    _historiqueActions = [
      Historique(id_historique: 1, date_action: DateTime.now().subtract(Duration(days: 1)), duree_totale_min: 40),
      Historique(id_historique: 2, date_action: DateTime.now().subtract(Duration(hours: 5)), duree_totale_min: 25),
    ];
    // notifyListeners();
  }

  /// Enregistrer une nouvelle action
  void enregistrerAction({
    required int idHistorique,
    required DateTime dateAction,
    required int dureeMin,
  }) {
    _historiqueActions.add(
      Historique(id_historique: idHistorique, date_action: dateAction, duree_totale_min: dureeMin),
    );
    // notifyListeners();
  }

  /// Récupérer une action spécifique
  Historique? getActionById(int id) {
    try {
      return _historiqueActions.firstWhere((h) => h.id_historique == id);
    } catch (e) {
      return null;
    }
  }

  /// Supprimer une action
  void supprimerAction(int id) {
    _historiqueActions.removeWhere((h) => h.id_historique == id);
    // notifyListeners();
  }
}
