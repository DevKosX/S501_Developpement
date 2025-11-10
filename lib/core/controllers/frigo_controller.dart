

import '../models/frigo_item_model.dart';
import '../models/aliment-model.dart';

class FrigoController {
  
  // Le contrôleur possède UNE instance du modèle
  Frigo frigoItem;

  
  /// Le constructeur reçoit l'instance du modèle qu'il doit contrôler
  FrigoController({required this.frigoItem});


  /// Méthode : getIdFrigo
  /// Retourne l'ID de l'item du frigo.
  int getIdFrigo() {
    return frigoItem.getIdFrigo();
  }

  /// Méthode : getQuantite
  /// Retourne la quantité de l'item.
  double getQuantite() {
    return frigoItem.getQuantite();
  }

  /// Méthode : getDateAjout
  /// Retourne la date d'ajout de l'item.
  DateTime getDateAjout() {
    return frigoItem.getDateAjout();
  }

  /// Méthode : getDatePeremption
  /// Retourne la date de péremption de l'item.
  DateTime getDatePeremption() {
    return frigoItem.getDatePeremption();
  }


  /// Méthode : ajouterAliment
  /// Appelle la méthode du modèle.
  void ajouterAliment(Aliment aliment, double quantite, DateTime datePeremption) {
    /// Appel simple au modèle
    frigoItem.ajouterAliment(aliment, quantite, datePeremption);
    /// TODO: Transmettre un résultat à la vue si besoin
  }

  /// Méthode : getContenuFrigo
  /// Appelle la méthode du modèle.
  List<Frigo> getContenuFrigo() {
    /// Appel simple au modèle
    var contenu = frigoItem.getContenuFrigo();
    /// On transmet la liste à la vue
    return contenu;
  }

  /// Méthode : modifierDatePeremption
  
  void modifierDatePeremption(DateTime nouvelleDate) {
    /// Appel simple au modèle
    frigoItem.modifierDatePeremption(nouvelleDate);
    /// TODO: Prévenir la vue du changement
  }
}