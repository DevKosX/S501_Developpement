
class Historique {
  int? idhistorique;
  DateTime dateaction;
  int dureetotalemin;
  int idrecette;

  int? note;
  String? commentaire;
  bool favori;

  Historique({
    this.idhistorique,
    required this.dateaction,
    required this.dureetotalemin,
    required this.idrecette,
    this.note,
    this.commentaire,
    this.favori = false,
  });

  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      idhistorique: map['id_historique'],
      idrecette: map['id_recette'],
      dateaction: DateTime.parse(map['date_action']),
      dureetotalemin: map['duree_totale_min'],
      note: map['note'],
      commentaire: map['commentaire'],
      favori: map['favori'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_recette': idrecette,
      'date_action': dateaction.toIso8601String(),
      'duree_totale_min': dureetotalemin,
      'note': note,
      'commentaire': commentaire,
      'favori': favori ? 1 : 0,
    };
  }


}
