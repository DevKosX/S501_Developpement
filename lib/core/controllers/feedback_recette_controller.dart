import 'package:flutter/material.dart';
import '../models/feedback_recette_model.dart';
import '../repositories/feedback_recette_repository.dart';

class FeedbackRecetteController extends ChangeNotifier {
  final FeedbackRecetteRepository _repository;

  List<FeedbackRecette> _feedbacks = [];
  bool _isLoading = false;

  List<FeedbackRecette> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;

  FeedbackRecetteController(this._repository) {
    chargerFeedbacks();
  }

  Future<void> chargerFeedbacks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _feedbacks = await _repository.getFeedbacks();
    } catch (e) {
      print("Erreur chargement feedbacks : $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> enregistrerFeedback({
    required int idRecette,
    required int note,
    required String commentaire,
  }) async {
    await _repository.enregistrerFeedback(
      idRecette: idRecette,
      note: note,
      commentaire: commentaire,
    );

    await chargerFeedbacks();
  }

  Future<FeedbackRecette?> getFeedbackPourRecette(int idRecette) async {
    try {
      return await _repository.getFeedbackByRecette(idRecette);
    } catch (e) {
      print("Erreur getFeedbackPourRecette : $e");
      return null;
    }
  }

  Future<void> noterRecette(FeedbackRecette feedback, int note) async {
    await _repository.noterRecette(feedback, note);
    await chargerFeedbacks();
  }

  Future<void> toggleFavori(FeedbackRecette feedback) async {
    await _repository.toggleFavori(feedback);
    await chargerFeedbacks();
  }

  Future<List<Map<String, dynamic>>> getFavorisAvecDetails() async {
    return await _repository.getFavorisAvecDetails();
  }
}
