class FeedbackRecette {
  int idrecette;
  int favori;
  int note;
  String? commentaire;

  FeedbackRecette({
    required this.idrecette,
    required this.favori,
    required this.note,
    this.commentaire,
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
      idrecette: map['idrecette'],
      favori: map['favori'] ?? 0,
      note: map['note'] ?? 0,
      commentaire: map['commentaire'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idrecette': idrecette,
      'favori': favori,
      'note': note,
      'commentaire': commentaire,
    };
  }
}