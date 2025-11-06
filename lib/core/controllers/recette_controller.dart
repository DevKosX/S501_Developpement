/// Fichier : core/controllers/recette_controller.dart
/// Auteur : Mohamed KOSBAR
/// Implémentation du 6 novembre 2025


/// Description :
/// Le contrôleur de la classe agit comme une couche intermédiaire entre la Vue (UI) et le Modèle spécifique.

/// faites vos codes en fonction en suivant sa uniquement les gars :
////  - Appeler les méthodes de votre modèle
////  - Récupérer leurs résultats
////  - Les transmettre à la vue (ou à une autre couche de présentation)
///
/// cela va nous permettre de garder le code structuré selon le modèle MVC.

import '../models/recette_model.dart';

class RecetteController {
  // --- ATTRIBUTS ---

  Recette recette;

  // --- CONSTRUCTEUR ---

  /// La mon constructeur recoit une instance
  RecetteController({required this.recette});

  // --- MÉTHODES DE CONTRÔLE ---

  /// Méthode : getTitre
  /// Retourne le titre de la recette.
  /// La méthode ne fait qu'appeler le getter du modèle sans logique supplémentaire.
  String getTitre() {
    String titre = recette.getTitre();
    return titre;
  }

  /// Méthode : getScore
  /// Retourne le score de la recette à partir du modèle.
  double getScore() {
    double score = recette.getScore();
    return score;
  }

  /// Méthode : getTypeRecette
  /// Retourne le type de la recette (entrée, plat, dessert...).
  String getTypeRecette() {
    String type = recette.getTypeRecette();
    return type;
  }

  /// Méthode : getImage
  /// Retourne le chemin ou l’URL de l’image associée à la recette.
  String getImage() {
    String image = recette.getImage();
    return image;
  }

  /// Méthode : getDifficulte
  /// Retourne le niveau de difficulté de la recette.
  String getDifficulte() {
    String diff = recette.getDifficulte();
    return diff;
  }

  // --- APPELS DES MÉTHODES DU MODÈLE ---
  /// Ces méthodes appellent simplement les fonctions du modèle
  /// sans implémenter de logique métier (le modèle s’en charge plus tard).

  /// Méthode : creerRecetteUtilisateur
  /// Appelle la méthode statique du modèle pour créer une recette utilisateur.
  void creerRecetteUtilisateur(String titre, String instructions, List<String> ingredients) {
    /// Appel simple au modèle sans logique ici
    var creation = Recette.creerRecetteUtilisateur(titre, instructions, ingredients);
    /// Possibilité de transmettre la variable 'creation' à la vue si besoin
  }

  /// Méthode : toggleFavori
  /// Appelle la méthode du modèle pour activer/désactiver une recette favorite.
  void toggleFavori() {
    var resultat = recette.toggleFavori();
    /// Ici, on pourrait renvoyer 'resultat' à la vue pour mettre à jour l’état d’un bouton par exemple
  }

  /// Méthode : noterRecette
  /// Appelle la méthode du modèle pour attribuer une note à la recette.
  void noterRecette(int note) {
    var resultat = recette.noterRecette(note);
    /// On ne fait qu’appeler la méthode du modèle et éventuellement
    /// transmettre 'resultat' à la couche supérieure
  }
}
