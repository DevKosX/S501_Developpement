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

  // Méthode du diagramme : ajouterAliment
  void ajouterAliment(Aliment aliment, double quantite, DateTime datePeremption) {
   
    print("Aliment ajouté (logique à définir)");
  }

  // Méthode du diagramme : getContenuFrigo
  List<Frigo> getContenuFrigo() {
    
    return [];
  }

  // Méthode du diagramme : modifierDatePeremption
  void modifierDatePeremption(DateTime nouvelleDate) {
    this.date_peremption = nouvelleDate;
  }
}