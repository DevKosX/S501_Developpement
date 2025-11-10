

class Frigo {
  //  ATTRIBUTS 
  int id_frigo;
  int id_aliment; // Clé étrangère
  double quantite;
  DateTime date_ajout;
  DateTime date_peremption;

  //  CONSTRUCTEUR 
  Frigo({
    required this.id_frigo,
    required this.id_aliment,
    required this.quantite,
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

  DateTime getDateAjout() {
    return date_ajout;
  }

  DateTime getDatePeremption() {
    return date_peremption;
  }

  // HELPERS BDD 

  /// Crée une instance de Frigo à partir d'un map (lu depuis la BDD).
  /// La BDD stocke les dates comme Texte (ISO 8601).
  factory Frigo.fromMap(Map<String, dynamic> map) {
    return Frigo(
      id_frigo: map['id_frigo'],
      id_aliment: map['id_aliment'],
      quantite: (map['quantite'] is int) 
          ? (map['quantite'] as int).toDouble() 
          : (map['quantite'] ?? 0.0),
      date_ajout: DateTime.parse(map['date_ajout']),
      date_peremption: DateTime.parse(map['date_peremption']),
    );
  }

  /// Convertit l'instance de Frigo en map (pour écrire dans la BDD).
  Map<String, dynamic> toMap() {
    return {
      'id_frigo': id_frigo,
      'id_aliment': id_aliment,
      'quantite': quantite,
      'date_ajout': date_ajout.toIso8601String(), // Stocke en texte
      'date_peremption': date_peremption.toIso8601String(), // Stocke en texte
    };
  }
}