import 'package:flutter/material.dart';
import 'feedback_recette_model.dart'; // Adaptera le chemin si besoin

class FeedbackRecetteController extends ChangeNotifier {
  // 1. L'État
  List<FeedbackRecette> _feedbacks = [];

  // 2. Getter
  List<FeedbackRecette> get feedbacks => _feedbacks;

  // 3. Logique métier

  /// Charger une liste simulée de feedbacks utilisateurs
  void chargerFeedbacks() {
    _feedbacks = [
      FeedbackRecette(id_recette: 1, favori: 0, note: 4),
      FeedbackRecette(id_recette: 2, favori: 1, note: 5),
      FeedbackRecette(id_recette: 3, favori: 0, note: 3),
    ];
    // notifyListeners();
  }

  /// Ajouter un feedback pour une recette
  void ajouterFeedback({
    required int idRecette,
    int favori = 0,
    int note = 0,
  }) {
    _feedbacks.add(
      FeedbackRecette(id_recette: idRecette, favori: favori, note: note),
    );
    // notifyListeners();
  }

  /// Modifier la note d'une recette
  void noterRecette(int idRecette, int nouvelleNote) {
    final f = _feedbacks.firstWhere((fb) => fb.id_recette == idRecette, orElse: () => FeedbackRecette(id_recette: idRecette, favori: 0, note: 0));
    f.note = nouvelleNote;
    // notifyListeners();
  }

  /// Toggle favori d'une recette
  void toggleFavori(int idRecette) {
    final f = _feedbacks.firstWhere((fb) => fb.id_recette == idRecette, orElse: () => FeedbackRecette(id_recette: idRecette, favori: 0, note: 0));
    f.favori = f.favori == 0 ? 1 : 0;
    // notifyListeners();
  }

  /// Supprimer un feedback
  void supprimerFeedback(int idRecette) {
    _feedbacks.removeWhere((fb) => fb.id_recette == idRecette);
    // notifyListeners();
  }
}
