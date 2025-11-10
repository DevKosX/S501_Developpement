// Fichier: aliment-model.dart

class Aliment {
  -
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

 -
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

 
  /// Modifie le nom de l'aliment
  void setNom(String nouveauNom) {
    this.nom = nouveauNom;
  }

  /// Modifie la catégorie de l'aliment
  void setCategorie(String nouvelleCategorie) {
    this.categorie = nouvelleCategorie;
  }

  /// Modifie le nutriscore de l'aliment
  void setNutriscore(String nouveauNutriscore) {
    this.nutriscore = nouveauNutriscore;
  }

  /// Modifie l'image de l'aliment
  void setImage(String nouvelleImage) {
    this.image = nouvelleImage;
  }
  

  
  List<Aliment> getAliments() {
    // TODO: Logique à implémenter
    return [];
  }

  static Aliment creerNouvelAliment(int id, String nom, String categorie, String nutriscore, String image) {
    return Aliment(
      id_aliment: id,
      nom: nom,
      categorie: categorie,
      nutriscore: nutriscore,
      image: image,
    );
  }
}