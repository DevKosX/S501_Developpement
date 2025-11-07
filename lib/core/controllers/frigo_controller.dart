
import 'package:flutter/material.dart';

// On importe les modèles pour savoir à quoi ressemblent
// les données que l'on manipule.
import 'aliment-model.dart';
import 'frigo_item_model.dart'; // Ce fichier contient ta classe 'Frigo'

class FrigoController extends ChangeNotifier {

  // --- 1. L'ETAT (STATE) ---
  //
  // C'est la liste des items du frigo que le controller gère.
  // Elle est privée (avec le "_") pour que la vue ne puisse
  // pas la modifier directement.
  List<Frigo> _contenuFrigo = [];


  // --- 2. L'ACCESSEUR (GETTER) ---
  //
  // C'est par ici que la VUE (View) viendra lire le
  // contenu du frigo pour l'afficher.
  List<Frigo> get contenuFrigo => _contenuFrigo;


  // --- 3. LA LOGIQUE METIER  ---
  //
  // Ce sont les méthodes que la vue appellera pour
  // interagir avec les données.

  /// Charge le contenu initial du frigo (simulation).
  /// Dans le futur, cette méthode appellera une base de données.
  void chargerContenuFrigo() {
    // On simule avec des données de test
    _contenuFrigo = [
      Frigo(
        id_frigo: 1, 
        quantite: 2.0, // ex: 2 pièces
        date_ajout: DateTime.now().subtract(Duration(days: 1)), // Ajouté hier
        date_peremption: DateTime.now().add(Duration(days: 5)) // Périme dans 5j
      ),
      Frigo(
        id_frigo: 2, 
        quantite: 500.0, // ex: 500g
        date_ajout: DateTime.now().subtract(Duration(days: 3)), // Ajouté il y a 3j
        date_peremption: DateTime.now().add(Duration(days: 2)) // Périme dans 2j
      ),
    ];

    // --- CONNEXION VUE  ---
    //
    // Quand les données sont prêtes, on prévient la vue.
    // notifyListeners();
  }

  /// Ajoute un nouvel aliment au frigo.
 
  void ajouterAliment(Aliment aliment, double quantite, DateTime datePeremption) {
    
    // Logique pour trouver un nouvel ID unique (exemple simple)
    int newId = _contenuFrigo.isEmpty 
        ? 1 
        : _contenuFrigo.map((item) => item.id_frigo).reduce((a, b) => a > b ? a : b) + 1;
        
    final newItem = Frigo(
      id_frigo: newId, 
      quantite: quantite, 
      date_ajout: DateTime.now(), // La date d'ajout est toujours "maintenant"
      date_peremption: datePeremption
    );

    // On ajoute le nouvel item à notre liste en mémoire
    _contenuFrigo.add(newItem);

    // --- CONNEXION VUE  ---
    // On prévient la vue qu'un item a été ajouté.
    //
    // notifyListeners();
  }

  /// Modifie la date de péremption d'un item existant.
  void modifierDatePeremption(int id_frigo, DateTime nouvelleDate) {
    try {
      // 1. On trouve l'item dans la liste...
      final item = _contenuFrigo.firstWhere((item) => item.id_frigo == id_frigo);
      
      // 2. On utilise la méthode du modèle pour le modifier
      item.modifierDatePeremption(nouvelleDate);

      // --- CONNEXION VUE  ---
      // On prévient la vue que cet item a changé.
      //
      // notifyListeners();

    } catch (e) {
      // Gérer le cas où l'item n'est pas trouvé
      print("Erreur: Item $id_frigo non trouvé dans le frigo.");
    }
  }

  /// Supprime un item du frigo.
  void supprimerAliment(int id_frigo) {
    
    // On retire l'item de la liste basé sur son ID
    _contenuFrigo.removeWhere((item) => item.id_frigo == id_frigo);

    // --- CONNEXION VUE  ---
    // On prévient la vue qu'un item a été supprimé.
    //
    // notifyListeners();
  }
}