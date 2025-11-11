import 'package:flutter/material.dart';
import '../models/recette_model.dart';
import '../repositories/recette_repository.dart';
import '../models/recette_aliment_model.dart';


/// Fichier: core/controllers/recette_controller.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 10 novembre 2025
///
/// j'ai refait ce contrôleur pour qu'il suive notre nouvelle architecture MVVM.
/// il est maintenant le "cerveau" qui gère toute la liste des recettes.
/// il utilise le repository pour parler à la BDD et 'ChangeNotifier' pour
/// dire à la Vue de se mettre à jour.

class RecetteController extends ChangeNotifier {
  // j'ai besoin du Repository pour accéder aux vraies données
  final RecetteRepository _repository;

  // --- ÉTAT (ce que la vue va afficher) ---
  // je garde une liste de toutes les recettes à afficher
  List<Recette> _listeRecettes = [];

  // je garde un booléen pour savoir si je suis en train de charger
  bool _isLoading = false;

  // --- GETTERS (pour la vue) ---
  List<Recette> get listeRecettes => _listeRecettes;

  bool get isLoading => _isLoading;

  // --- CONSTRUCTEUR ---
  // on doit me donner le repository à la création
  RecetteController(this._repository) {
    // je charge les recettes dès que le contrôleur est créé
    chargerRecettes();
  }

  // --- MÉTHODES (appelées par la Vue) ---

  // --------------------------------------------------------------------------
  // === MÉTHODES GÉNÉRALES SUR LES RECETTES ===
  // --------------------------------------------------------------------------

  /// méthode pour charger toutes les recettes depuis la BDD

  Future<void> chargerRecettes() async {
    _isLoading = true;
    notifyListeners(); // je dis à la vue d'afficher un chargement

    try {
      // j'appelle le repository pour avoir les vraies données
      _listeRecettes = await _repository.getRecettes();
    } catch (e) {
      print("ERREUR lors du chargement des recettes: $e");
      // ici on pourrait gérer l'erreur (ex: afficher un message)
    }

    _isLoading = false;
    notifyListeners(); // je dis à la vue que les données sont prêtes
  }

  /// méthode appelée quand l'utilisateur clique sur le cœur
  Future<void> toggleFavori(Recette recette) async {
    // j'appelle le repository pour sauvegarder en BDD
    await _repository.toggleFavori(recette);

    // OPTIONNEL : je pourrais recharger la liste pour être sûr
    // que l'UI est à jour, mais pour un favori ce n'est pas toujours nécessaire
    // si on gère l'état localement. Pour l'instant, on recharge.
    // await chargerRecettes();

    notifyListeners(); // je dis à la vue de se rafraîchir
  }

  /// méthode appelée quand l'utilisateur note une recette
  Future<void> noterRecette(Recette recette, int note) async {
    await _repository.noterRecette(recette, note);
    notifyListeners();
  }

  /// méthode pour créer une nouvelle recette
  Future<void> creerRecette(Recette nouvelleRecette) async {
    _isLoading = true;
    notifyListeners();

    await _repository.creerRecetteUtilisateur(nouvelleRecette);

    // une fois créée, je recharge la liste pour voir la nouvelle recette
    await chargerRecettes();

    _isLoading = false;
    notifyListeners();
  }


  // --------------------------------------------------------------------------
  // === NOUVELLES MÉTHODES LIÉES À RecetteAliment ===
  // --------------------------------------------------------------------------

  ///méthode pour recuper la liste des ingrédients pour une recette
  Future<List<Map<String, dynamic>>> getIngredientsByRecette(int idRecette) async {
    try {
      final ingredients = await _repository.getIngredientsByRecette(idRecette);
      print("CTRL: ${ingredients.length} ingrédients récupérés pour la recette $idRecette");
      return ingredients;
    } catch (e) {
      print("ERREUR: impossible de charger les ingrédients → $e");
      return [];
    }
  }

  ///méthode qui ajoute des ingrédients à une reccette crée
  Future<void> addIngredientToRecette(RecetteAliment recetteAliment) async {
    try {
      await _repository.addIngredientToRecette(recetteAliment);
      print("CTRL: ingrédient ajouté pour la recette ${recetteAliment.idRecette}");
      notifyListeners();
    } catch (e) {
      print("ERREUR: impossible d’ajouter l’ingrédient → $e");
    }
  }


  ///méthode de suppression
  Future<void> deleteIngredientsByRecette(int idRecette) async {
    try {
      await _repository.deleteIngredientsByRecette(idRecette);
      print("CTRL: ingrédients supprimés pour la recette $idRecette");
      notifyListeners();
    } catch (e) {
      print("ERREUR: impossible de supprimer les ingrédients → $e");
    }
  }

}














































/*  ANCIEN CODE FAUX

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
*/

