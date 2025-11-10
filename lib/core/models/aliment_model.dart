

class Aliment {
 
  int id_aliment;
  String nom;
  String categorie;
  String nutriscore;
  String image;

 
  Aliment({
    required this.id_aliment,
    required this.nom,
    required this.categorie,
    required this.nutriscore,
    required this.image,
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
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id_aliment': id_aliment,
      'nom': nom,
      'categorie': categorie,
      'nutriscore': nutriscore,
      'image': image,
    };
  }
}