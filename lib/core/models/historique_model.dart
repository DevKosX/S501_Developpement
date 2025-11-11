
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

  // Méthodes UML
  static List<Historique> getHistoriqueComplet(List<Historique> historiques) {
    return historiques;
  }

  void enregistrerAction(int id_recette, int duree) {
    // Logique d'enregistrement (a implémenter)
    print("Action enregistrée : Recette $id_recette, Durée $duree minutes le $date_action");
  }

  // Helpers BDD
  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      id_historique: map['id_historique'],
      date_action: DateTime.parse(map['date_action']),
      duree_totale_min: map['duree_totale_min'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_historique': id_historique,
      'date_action': date_action.toIso8601String(),
      'duree_totale_min': duree_totale_min,
    };
  }
}