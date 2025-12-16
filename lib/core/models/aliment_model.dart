class Aliment {
  int id_aliment;
  String nom;
  String categorie;
  String nutriscore;
  String image;
  double poids_unitaire;

  Aliment({
    required this.id_aliment,
    required this.nom,
    required this.categorie,
    required this.nutriscore,
    required this.image,
    required this.poids_unitaire,
  });

  int getIdAliment() {
    return id_aliment;
  }

  String getNom() {
    return nom;
  }

  String getCategorie() {
    return categorie;
  }

  String getNutriscore() {
    return nutriscore;
  }

  String getImage() {
    return image;
  }

  factory Aliment.fromMap(Map<String, dynamic> map) {
    return Aliment(
      id_aliment: map['id_aliment'],
      nom: map['nom'] ?? "",
      categorie: map['categorie'] ?? "Inconnue",
      nutriscore: map['nutriscore'] ?? "N/A",
      image: map['image'] ?? "",
      poids_unitaire: _toDoubleSafe(map['poids_unitaire']),
    );
  }

  /// --- AJOUT MINIMAL POUR EVITER L’ERREUR ---
  static double _toDoubleSafe(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();

    if (value is String) {
      if (value.trim().isEmpty) return 0.0;
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id_aliment': id_aliment,
      'nom': nom,
      'categorie': categorie,
      'nutriscore': nutriscore,
      'image': image,
      'poids_unitaire': poids_unitaire,
    };
  }
}
