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

  // Méthode du diagramme : getAliments
  // Elle retourne une liste vide pour l'instant,
  // car sa logique n'est pas définie ici.
  List<Aliment> getAliments() {
    // TODO: La logique de cette méthode est à définir
    // (elle devrait sûrement être dans une autre classe)
    return [];
  }

 
  // On crée une méthode statique pour correspondre au diagramme.
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