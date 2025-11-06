// 1. Il faut importer la bibliothèque de Flutter pour 'ChangeNotifier'
// pour se connecter à la vue et l'actualiseer
import 'package:flutter/foundation.dart';

// 2. Importer modèle
import '../models/profil_model.dart'; // Assurez-vous que le chemin est correct

/// CONTRÔLEUR

class ProfilController with ChangeNotifier {
  

  // privée car la Vue ne doit jamais y accéder directement.
  late ProfilModel _profil;

  // --- CONSTRUCTEUR ---
  ProfilController() {
    // données fictive mais en réalité on pourra récupérer les données depuis une base de données locale
    _profil = ProfilModel(
      id: 1,
      poids: 75.0,
      taille: 1.80,
      objectif: "Perdre du poids",
    );
  }

  // MÉTHODES POUR LA VUE (Getters) 

  public double getPoids() {
    return _profil.getPoids();
  }

  public double getTaille() {
    return _profil.getTaille();
  }

  public String getObjectif() {
    return _profil.getObjectif();
  }

  public int getId() {
    return _profil.getId();
  }

  public double getImc() {
    return _profil.calculerIMC();
  }
  // MÉTHODES POUR LA VUE (Setters / Actions)

  void mettreAJourObjectif(String nouvelObjectif) {
    _profil.setObjectif(nouvelObjectif);
    
    // 2. Notifier la Vue
    notifyListeners();
  }

  void mettreAJourMensurations(double nouveauPoids, double nouvelleTaille) {
    _profil.setMensurations(nouveauPoids, nouvelleTaille);
    
    // 2. Notifier la Vue
    notifyListeners();
  }
}