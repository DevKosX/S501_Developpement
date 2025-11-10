
import 'aliment-model.dart'; 

class Frigo {
 
  int id_frigo;
  double quantite; 
  DateTime date_ajout;
  DateTime date_peremption;

  
  Frigo({
    required this.id_frigo,
    required this.quantite,
    required this.date_ajout,
    required this.date_peremption,
  });

  
  int getIdFrigo() {
    return id_frigo;
  }

  double getQuantite() {
    return quantite;
  }

  DateTime getDateAjout() {
    return date_ajout;
  }

  DateTime getDatePeremption() {
    return date_peremption;
  }



  /// Modifie la quantité de l'item
  void setQuantite(double nouvelleQuantite) {
    if (nouvelleQuantite >= 0) {
      this.quantite = nouvelleQuantite;
    }
  }

  
  void modifierDatePeremption(DateTime nouvelleDate) {
    this.date_peremption = nouvelleDate;
  }

  // --- Méthodes (inchangées) ---

  void ajouterAliment(Aliment aliment, double quantite, DateTime datePeremption) {
    // TODO: Logique à implémenter.
    print("Aliment ajouté (logique à définir)");
  }

  List<Frigo> getContenuFrigo() {
    // TODO: Logique à implémenter.
    return [];
  }
}