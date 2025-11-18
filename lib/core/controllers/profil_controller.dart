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
      double tailleMetres = profilUtilisateur!.taille;
      double poids = profilUtilisateur!.poids;
      return poids / (tailleMetres * tailleMetres);
    }
    return 0.0;
  }


  String get messageConseil {
      if (profilUtilisateur == null) return "Aucun profil chargé.";

      double monImc = imc;
      String objectif = profilUtilisateur!.objectif; // Ex: "Perdre du poids", "Prendre de la masse", "Maintenir"


      if (objectif == "Perte de poids") {
        if (monImc > 25) {
          return "Tu es au-dessus de la normale. Continue tes efforts, l'exercice et l'alimentation finiront par payer !";
        } else if (monImc >= 18.5 && monImc <= 25) {
          return "Bravo ! Tu as atteint un poids santé. Tu dois maintenant le maintenir.";
        } else {
          return "Attention, ton IMC est bas. Perdre plus de poids pourrait être dangereux.";
        }
      } 


      else if (objectif == "Prise de masse") {
        if (monImc < 18.5) {
          return "Tu es en sous-poids. Il faut augmenter ton apport calorique et continuer l'entraînement.";
        } else if (monImc >= 18.5 && monImc <= 25) {
          return "Tu es dans la bonne zone ! Continue la musculation pour transformer ce poids en muscle.";
        } else {
          return "Ton poids est élevé. Assure-toi que c'est du muscle et non du gras (surveille ton % de graisse).";
        }
      } 
      

      else {
        // cas par défault
        if (monImc >= 18.5 && monImc <= 25) {
          return "Tu es au top ! Ton poids est idéal pour ta taille.";
        } else {
          return "Ton poids n'est pas tout à fait dans la norme, mais l'important est de se sentir bien.";
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