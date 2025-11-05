class Historique {
  int id_historique;
  DateTime date_action;
  int duree_totale_min;

  Historique({
    required this.id_historique,
    required this.date_action,
    required this.duree_totale_min,
  });

  // Getters
  int getIdHistorique() => id_historique;
  DateTime getDateAction() => date_action;
  int getDuree() => duree_totale_min;

  // Méthodes UML :
  // Typiquement, tu utiliserais une liste pour stocker l'historique complet
  static List<Historique> getHistoriqueComplet(List<Historique> historiques) {
    return historiques;
  }

  void enregistrerAction(int id_recette, int duree) {
    // Ici, logiquement, on pourrait rajouter l'action à une base de données ou une liste
    print("Action enregistrée : Recette $id_recette, Durée $duree minutes le ${date_action}");
  }
}
