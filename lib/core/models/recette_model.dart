/// Fichier: core/models/recette_model.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 5/6 novembre 2025

class Recette {
  // --- ATTRIBUTS ---
  /// J'ai défini tous les attributs en public
  int id_recette;
  String titre;
  String instructions;
  int tempsPreparation;
  String typeRecette;
  double score;
  int noteBase;
  String image;
  String difficulte;
  int calories;
  // Champ non stocké en BDD, juste pour l'affichage UI
  int nombreManquants;
  


  // --- CONSTRUCTEUR ---
  /// Puisque tous mes attributs sont non-nullables j'ai rendu tous les paramètres du constructeur 'required' pour avoir une recette bien complette
  Recette({
    required this.id_recette,
    required this.titre,
    required this.instructions,
    required this.tempsPreparation,
    required this.typeRecette,
    required this.score,
    required this.noteBase,
    required this.image,
    required this.difficulte,
    this.calories = 0,
    this.nombreManquants = 0,
  });

  // --- GETTERS ---
  ///je dois faire les getters de score titre type recette image difficulte
  int getIdRecette() {
    return id_recette;
  }

  String getTitre() {
    return titre;
  }

  String getInstructions() {
    return instructions;
  }

  String getTypeRecette() {
    return typeRecette;
  }

  double getScore() {
    return score;
  }

  int getNoteBase() {
    return noteBase;
  }

  String getImage(){
    return image;
  }

  String getDifficulte() {
    return difficulte;
  }
  
  int getCalories() {
    return calories;
  }


  // --- HELPERS BDD (le mapping ici) ---

  /// Convertit un Map (venant de SQLite) en objet Recette
  factory Recette.fromMap(Map<String, dynamic> map) {
    return Recette(
      id_recette: map['id_recette'],
      titre: map['titre'],
      instructions: map['instructions'] ?? "", // Gestion des valeurs nulles
      tempsPreparation: map['temps_preparation'] ?? 0,
      typeRecette: map['type_recette'] ?? "Inconnu",
      score: (map['score'] is int)
          ? (map['score'] as int).toDouble()
          : (map['score'] ?? 0.0), // Conversion sûre pour le double
      noteBase: map['note_base'] ?? 0,
      image: map['image'] ?? "",
      difficulte: map['difficulte'] ?? "Moyenne",
      calories: map['calories'] ?? 0,
    );


  }

  /// Convertit cet objet Recette en Map (pour l'envoyer à SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id_recette': id_recette,
      'titre': titre,
      'instructions': instructions,
      'temps_preparation': tempsPreparation, // On remet l'underscore pour le SQL
      'type_recette': typeRecette,
      'score': score,
      'note_base': noteBase,
      'image': image,
      'difficulte': difficulte,
      'calories': calories,
    };
  }
}

  // --SQUELLETTE DES METHODES QUI SERONT IMPLEMNETER PLUS TARD --

  //static void creerRecetteUtilisateur(String titre, String instructions, List<String> ingredients,) {
    //contenu que je dois ajouter
  //}

  //void toggleFavori(){
    //contenu que je dois ajouter
  //}

  //void noterRecette(int note) {
    //contenu que je dois ajouter
  //}

