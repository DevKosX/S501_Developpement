import '../models/feedback_recette_model.dart';

class FeedbackRecetteController {
  FeedbackRecette feedbackRecette;

  FeedbackRecetteController({required this.feedbackRecette});

  // Appelle le getter id_recette
  int getIdRecette() {
    return feedbackRecette.getIdRecette();
  }

  // Appelle le getter favori
  int getFavori() {
    return feedbackRecette.getFavori();
  }

  // Appelle le getter note
  int getNote() {
    return feedbackRecette.getNote();
  }

  // Méthode pour noter une recette
  void noterRecette(int note) {
    feedbackRecette.noterRecette(note);
  }

  // Méthode pour changer l'état favori
  void toggleFavori() {
    feedbackRecette.toggleFavori();
  }
}
