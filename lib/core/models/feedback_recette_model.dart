class FeedbackRecette {
  int id_recette;
  int favori;
  int note;

  FeedbackRecette({
    required this.id_recette,
    required this.favori,
    required this.note,
  });

  // Getters
  int getIdRecette() => id_recette;
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
      id_recette: map['id_recette'],
      favori: map['favori'] ?? 0,
      note: map['note'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_recette': id_recette,
      'favori': favori,
      'note': note,
    };
  }
}