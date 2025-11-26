
class Historique {
  int? idhistorique;
  DateTime dateaction;
  int dureetotalemin;
  int idrecette;

  Historique({
    this.idhistorique,
    required this.dateaction,
    required this.dureetotalemin,
    required this.idrecette,
  });

  // Getters
  int? getIdHistorique() => idhistorique;
  DateTime getDateAction() => dateaction;
  int getDuree() => dureetotalemin;

  // Méthodes UML
  static List<Historique> getHistoriqueComplet(List<Historique> historiques) {
    return historiques;
  }

  void enregistrerAction(int idrecette, int duree) {
    // Logique d'enregistrement (a implémenter)
    print("Action enregistrée : Recette $idrecette, Durée $duree minutes le $dateaction");
  }

  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      idhistorique: map['id_historique'],
      idrecette: map['id_recette'],
      dateaction: DateTime.parse(map['date_action']),
      dureetotalemin: map['duree_totale_min'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_recette': idrecette,
      'date_action': dateaction.toIso8601String(),
      'duree_totale_min': dureetotalemin,
    };
  }


}