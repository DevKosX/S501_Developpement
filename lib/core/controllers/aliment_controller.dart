

import '../models/aliment-model.dart';

class AlimentController {
 
  Aliment aliment;

 
  AlimentController({required this.aliment});

  
  // Appels simples aux getters du modèle.

  /// Méthode : getIdAliment
  int getIdAliment() {
    return aliment.getIdAliment();
  }

  /// Méthode : getNom
  String getNom() {
    return aliment.getNom();
  }

  /// Méthode : getCategorie
  String getCategorie() {
    return aliment.getCategorie();
  }

  /// Méthode : getNutriscore
  String getNutriscore() {
    return aliment.getNutriscore();
  }

  /// Méthode : getImage
  String getImage() {
    return aliment.getImage();
  }



  /// Méthode : getAliments
  /// Appelle la méthode du modèle pour récupérer la liste.
  List<Aliment> getAliments() {
    /// Appel simple au modèle
    var liste = aliment.getAliments();
    /// On transmet la liste à la vue
    return liste;
  }

  /// Méthode : creerNouvelAliment
  /// Appelle la méthode statique du modèle.
  /// Note: celle-ci n'a pas besoin de l'attribut 'this.aliment'
  void creerNouvelAliment(int id, String nom, String categorie, String nutriscore, String image) {
    /// Appel simple à la méthode statique du modèle
    var nouvelAliment = Aliment.creerNouvelAliment(id, nom, categorie, nutriscore, image);
    /// TODO: Transmettre 'nouvelAliment' à la vue si besoin
  }
}