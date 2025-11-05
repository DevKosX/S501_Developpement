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

  // Méthodes UML :
  void noterRecette(int nouvelleNote) {
    note = nouvelleNote;
  }

  void toggleFavori() {
    favori = favori == 0 ? 1 : 0;
  }
}
