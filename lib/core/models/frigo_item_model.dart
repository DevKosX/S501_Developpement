class Frigo {

  int id_frigo;
  int id_aliment;
  double quantite;
  String unite;
  DateTime date_ajout;
  DateTime date_peremption;


  Frigo({
    required this.id_frigo,
    required this.id_aliment,
    required this.quantite,
    required this.unite,
    required this.date_ajout,
    required this.date_peremption,
  });

  // GETTERS 
  int getIdFrigo() {
    return id_frigo;
  }

  int getIdAliment() {
    return id_aliment;
  }

  double getQuantite() {
    return quantite;
  }

  String getUnite(){
    return unite;
  }

  DateTime getDateAjout() {
    return date_ajout;
  }

  DateTime getDatePeremption() {
    return date_peremption;
  }

  factory Frigo.fromMap(Map<String, dynamic> map) {
    return Frigo(
      id_frigo: map['id_frigo'],
      id_aliment: map['id_aliment'],
      quantite: (map['quantite'] is int) 
          ? (map['quantite'] as int).toDouble() 
          : (map['quantite'] ?? 0.0),
      unite: map['unite'] ?? "",
      date_ajout: DateTime.parse(map['date_ajout']),
      date_peremption: DateTime.parse(map['date_peremption']),
    );
  }


  Map<String, dynamic> toMap() {
    final map = {
      'id_aliment': id_aliment,
      'quantite': quantite,
      'unite' : unite,
      'date_ajout': date_ajout.toIso8601String(),
      'date_peremption': date_peremption.toIso8601String(),
    };


    if (id_frigo != 0) {
      map['id_frigo'] = id_frigo;
    }

    return map;
  }
}