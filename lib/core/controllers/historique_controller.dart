import '../models/historique_action_model.dart';

class HistoriqueController {
  Historique historique;

  HistoriqueController({required this.historique});

  // Appelle le getter id_historique
  int getIdHistorique() {
    return historique.getIdHistorique();
  }

  // Appelle le getter date_action
  DateTime getDateAction() {
    return historique.getDateAction();
  }

  // Appelle le getter duree_totale_min
  int getDuree() {
    return historique.getDuree();
  }

  // Appelle la méthode statique pour récupérer l'historique complet
  List<Historique> getHistoriqueComplet() {
    return Historique.getHistoriqueComplet();
  }

  // Enregistre une action avec la méthode du modèle
  void enregistrerAction(int idRecette, int duree) {
    historique.enregistrerAction(idRecette, duree);
  }
}
