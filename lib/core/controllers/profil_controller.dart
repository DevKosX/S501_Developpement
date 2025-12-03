/// La logique calcul de l'IMC est placée ici.

import 'package:flutter/foundation.dart';
import '../models/profil_model.dart';
import '../repositories/profil_repository.dart';

class ProfilController extends ChangeNotifier {
  final ProfilRepository _repository;

  ProfilModel? profilUtilisateur;
  bool isLoading = false;

  /// Constructeur : le Repository est "injecté" (donné) de l'extérieur.
  /// Il charge le profil dès l'initialisation.
  ProfilController(this._repository) {
    chargerProfil();
  }

  // --- LOGIQUE MÉTIER (ex-Modèle) ---

  double get imc {
    if (profilUtilisateur != null && profilUtilisateur!.taille > 0) {
      double tailleOriginale = profilUtilisateur!.taille;
      double poids = profilUtilisateur!.poids;
      // On divise par 100 pour avoir des mètres (1.75), sinon la formule IMC est fausse.
      double tailleMetres = tailleOriginale > 3.0 ? tailleOriginale / 100 : tailleOriginale;
      return poids / (tailleMetres * tailleMetres);
    }
    return 0.0;
  }

  String get messageConseil {
    if (profilUtilisateur == null) return "Aucun profil chargé.";

    double monImc = imc;
    String objectif = profilUtilisateur!.objectif; // "Perte de poids", "Prise de masse", "Maintien"

    // --- SCÉNARIO 1 : PERTE DE POIDS ---
    if (objectif == "Perte de poids") {
      if (monImc > 30) {
        return "Votre IMC indique une obésité. L'activité douce (marche, natation) et un suivi nutritionnel sont recommandés.";
      } else if (monImc > 25) {
        return "Vous êtes en léger surpoids. Réduisez les sucres rapides et visez 30 min de marche active par jour.";
      } else if (monImc >= 18.5) {
        return "Bravo ! Vous avez atteint un poids santé. Ne cherchez pas à perdre plus, concentrez-vous sur le maintien.";
      } else {
        return "Attention : Votre poids est trop bas pour cet objectif. Perdre davantage pourrait être risqué.";
      }
    } 
    
    // --- SCÉNARIO 2 : PRISE DE MASSE ---
    else if (objectif == "Prise de masse") {
      if (monImc < 18.5) {
        return "Vous êtes en sous-poids. Augmentez votre apport calorique (bons gras, glucides) et faites de la musculation.";
      } else if (monImc >= 18.5 && monImc <= 25) {
        return "Base idéale ! Pour prendre du muscle, entraînez-vous lourd et consommez environ 1.5g à 2g de protéines par kg.";
      } else {
        return "Vous avez du volume. Assurez-vous que c'est du muscle ! Si c'est du gras, privilégiez une prise de masse 'propre'.";
      }
    } 
    
    // --- SCÉNARIO 3 : MAINTIEN (ou autre) ---
    else {
      if (monImc >= 18.5 && monImc <= 25) {
        return "Félicitations ! Votre poids est idéal pour votre taille. Continuez une alimentation équilibrée.";
      } else if (monImc > 25) {
        return "Un peu au-dessus de la moyenne. Rien de grave, essayez juste de bouger un peu plus au quotidien.";
      } else {
        return "Un peu maigre. N'hésitez pas à enrichir vos plats avec des noix, de l'avocat ou de l'huile d'olive.";
      }
    }
  }

  Future<void> chargerProfil() async {
    isLoading = true;
    notifyListeners(); // Prévient la Vue : "Chargement en cours"

    profilUtilisateur = await _repository.getProfil();

    isLoading = false;
    notifyListeners(); // Prévient la Vue : "Le profil est chargé"
  }

  Future<void> mettreAJourProfil(double poids, double taille, String objectif) async {
    // Crée un nouveau modèle (ou met à jour l'ancien)
    // On garde l'ID existant, ou 1 par défaut.
    final profilMaj = ProfilModel(
      id: profilUtilisateur?.id ?? 1,
      poids: poids,
      taille: taille,
      objectif: objectif,
    );

    isLoading = true;
    notifyListeners();

    // Juste l'appel au repository qui entre les données dans la BD
    await _repository.saveProfil(profilMaj);

    profilUtilisateur = profilMaj;
    isLoading = false;
    notifyListeners(); 
  }
}




































































// // 1. Il faut importer la bibliothèque de Flutter pour 'ChangeNotifier'
// // pour se connecter à la vue et l'actualiseer
// import 'package:flutter/foundation.dart';

// // 2. Importer modèle
// import '../models/profil_model.dart'; // Assurez-vous que le chemin est correct

// /// CONTRÔLEUR

// class ProfilController with ChangeNotifier {
  

//   // privée car la Vue ne doit jamais y accéder directement.
//   late ProfilModel _profil;

//   // --- CONSTRUCTEUR ---
//   ProfilController() {
//     // données fictive mais en réalité on pourra récupérer les données depuis une base de données locale
//     _profil = ProfilModel(
//       id: 1,
//       poids: 75.0,
//       taille: 1.80,
//       objectif: "Perdre du poids",
//     );
//   }

//   // MÉTHODES POUR LA VUE (Getters) 

//   public double getPoids() {
//     return _profil.getPoids();
//   }

//   public double getTaille() {
//     return _profil.getTaille();
//   }

//   public String getObjectif() {
//     return _profil.getObjectif();
//   }

//   public int getId() {
//     return _profil.getId();
//   }

//   public double getImc() {
//     return _profil.calculerIMC();
//   }
//   // MÉTHODES POUR LA VUE (Setters / Actions)

//   void mettreAJourObjectif(String nouvelObjectif) {
//     _profil.setObjectif(nouvelObjectif);
    
//     // 2. Notifier la Vue
//     notifyListeners();
//   }

//   void mettreAJourMensurations(double nouveauPoids, double nouvelleTaille) {
//     _profil.setMensurations(nouveauPoids, nouvelleTaille);
    
//     // 2. Notifier la Vue
//     notifyListeners();
//   }
// }