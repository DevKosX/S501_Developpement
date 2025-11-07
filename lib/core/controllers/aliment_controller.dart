

import 'package:flutter/material.dart';
import 'aliment-model.dart'; // Importer le modèle Aliment

class AlimentController extends ChangeNotifier {

  // --- 1. L'ETAT (STATE) ---
  //
  // C'est la liste de TOUS les aliments "connus" de l'application.
  // C'est notre catalogue ou notre "base de données" d'aliments.
  List<Aliment> _catalogueAliments = [];

  // --- 2. L'ACCESSEUR (GETTER) ---
  //
  // La vue (View) viendra lire ce catalogue pour, par exemple,
  // afficher une liste d'aliments à ajouter au frigo.
  List<Aliment> get catalogueAliments => _catalogueAliments;

  // --- 3. LA LOGIQUE METIER (BUSINESS LOGIC) ---

  /// Charge le catalogue initial d'aliments (simulation).
  /// Dans le futur, viendra d'une API ou d'une base de données.
  void chargerAliments() {
    _catalogueAliments = [
      Aliment(
        id_aliment: 101,
        nom: "Pomme",
        categorie: "Fruit",
        nutriscore: "A",
        image: "assets/images/pomme.png" // Chemin d'exemple
      ),
      Aliment(
        id_aliment: 102,
        nom: "Poulet (filet)",
        categorie: "Viande",
        nutriscore: "A",
        image: "assets/images/poulet.png"
      ),
      Aliment(
        id_aliment: 103,
        nom: "Lait",
        categorie: "Produit laitier",
        nutriscore: "B",
        image: "assets/images/lait.png"
      ),
    ];

    // --- CONNEXION VUE  ---
    // On prévient la vue que le catalogue est chargé.
    //
    // notifyListeners();
  }

  /// Crée un nouvel aliment et l'ajoute au catalogue.
  /// (Cette méthode était sur ton modèle UML, sa vraie place est ici)
  void creerNouvelAliment({
    required String nom,
    required String categorie,
    required String nutriscore,
    required String image,
  }) {
    // Logique pour trouver un nouvel ID
    int newId = _catalogueAliments.isEmpty
        ? 101 // On commence à 101 par exemple
        : _catalogueAliments.map((a) => a.id_aliment).reduce((a, b) => a > b ? a : b) + 1;

    final nouvelAliment = Aliment(
      id_aliment: newId,
      nom: nom,
      categorie: categorie,
      nutriscore: nutriscore,
      image: image,
    );

    _catalogueAliments.add(nouvelAliment);

    // --- CONNEXION VUE  ---
    // On prévient la vue qu'un aliment a été ajouté.
    //
    // notifyListeners();
  }

  /// Récupère un aliment spécifique par son ID.
  /// Utile pour le contrôleur du frigo.
  Aliment? getAlimentById(int id) {
    try {
      // Trouve le premier aliment qui correspond à l'ID
      return _catalogueAliments.firstWhere((aliment) => aliment.id_aliment == id);
    } catch (e) {
      // Gère l'erreur si aucun aliment n'est trouvé
      print("Erreur: Aliment $id non trouvé dans le catalogue.");
      return null;
    }
  }

  /// Supprime un aliment
  void supprimerAliment(int id) {
    
    _catalogueAliments.removeWhere((aliment) => aliment.id_aliment == id);

    // --- CONNEXION VUE  ---
    // On prévient la vue qu'un aliment a été supprimé.
    //
    // notifyListeners();
  }
}