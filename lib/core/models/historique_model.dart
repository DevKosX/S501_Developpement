
class Historique {
  int idhistorique;
  DateTime dateaction;
  int dureetotalemin;
  int idrecette;

  Historique({
    required this.idhistorique,
    required this.dateaction,
    required this.dureetotalemin,
    required this.idrecette,
  });

  // Getters
  int getIdHistorique() => idhistorique;
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

  // Helpers BDD
  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      idhistorique: map['idhistorique'],
      idrecette: map['id_recette'] ?? 0,
      dateaction: DateTime.parse(map['dateaction']),
      dureetotalemin: map['dureetotalemin'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idhistorique': idhistorique,
      'idrecette': idrecette,
      'dateaction': dateaction.toIso8601String(),
      'dureetotalemin': dureetotalemin,
    };
  }
}