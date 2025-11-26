class FeedbackRecette {
  int idrecette;
  int favori;
  int note;
  String? commentaire; // <-- devient optionnel

  FeedbackRecette({
    required this.idrecette,
    required this.favori,
    required this.note,
    this.commentaire,   // <-- optionnel mais pas obligatoire à passer
  });

  // Getters
  int getIdRecette() => idrecette;
  int getFavori() => favori;
  int getNote() => note;

  // Méthodes UML
  void noterRecette(int nouvelleNote) {
    note = nouvelleNote;
  }

  void toggleFavori() {
    favori = favori == 0 ? 1 : 0;
  }

  // Helpers BDD
  factory FeedbackRecette.fromMap(Map<String, dynamic> map) {
    return FeedbackRecette(
      idrecette: map['id_recette'] as int,
      favori: (map['favori'] ?? 0) as int,
      note: (map['note'] ?? 0) as int,
      commentaire: map['commentaire'] as String? ?? "",  // <-- SAFE
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_recette': idrecette,
      'favori': favori,
      'note': note,
      'commentaire': commentaire ?? "", // <-- SAFE aussi
    };
  }
}