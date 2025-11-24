class Aliment {
  int id_aliment;
  String nom;
  String categorie;
  String nutriscore;
  String image;
  String typeGestion;

  Aliment({
    required this.id_aliment,
    required this.nom,
    required this.categorie,
    required this.nutriscore,
    required this.image,
    required this.typeGestion,
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
      categorie: map['categorie'] ?? "Autre",
      nutriscore: map['nutriscore'] ?? "",
      image: map['image'] ?? "",
      typeGestion: map['type_gestion'] ?? "masse",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_aliment': id_aliment,
      'nom': nom,
      'categorie': categorie,
      'nutriscore': nutriscore,
      'image': image,
      'type_gestion': typeGestion,
    };
  }
}