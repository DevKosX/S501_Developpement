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

  Future<void> noterRecette(FeedbackRecette feedback, int note) async {
    await _repository.noterRecette(feedback, note);
    await chargerFeedbacks();
  }

  Future<void> toggleFavori(FeedbackRecette feedback) async {
    await _repository.toggleFavori(feedback);
    await chargerFeedbacks();
  }
}
