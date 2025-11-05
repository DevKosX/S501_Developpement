
class ProfilModel {
  // préfixe "_" rend la variable "privée"
  // à la bibliothèque (au fichier).
  int _id;
  double _poids;
  double _taille;
  String _objectif;

  // CONSTRUCTEUR 
  // Le diagramme UML ne montre pas de constructeur, mais c'est nécesssaire,
  // il est nécessaire pour initialiser les variables non-nullables.
  ProfilModel({
    required int id,
    required double poids,
    required double taille,
    required String objectif,
  })  : _id = id,
        _poids = poids,
        _taille = taille,
        _objectif = objectif;

  // MÉTHODES (Getters)

  int getId() {
    return _id;
  }

  double getPoids() {
    return _poids;
  }

  double getTaille() {
    return _taille;
  }

  String getObjectif() {
    return _objectif;
  }


  // MÉTHODES Setters

  void setObjectif(String objectif) {
    _objectif = objectif;
  }

  void setMensurations(double poids, double taille) {
    _poids = poids;
    _taille = taille;
  }

  double calculerIMC() {    
    // On vérifie que la taille n'est pas 0 pour éviter une division par zéro
    if (_taille <= 0) {
      return 0.0;
    }
    
    // calcul de l'imc 
    return _poids / (_taille * _taille);
  }
}