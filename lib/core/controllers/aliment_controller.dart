import 'package:flutter/material.dart';
import '../models/aliment_model.dart';
import '../repositories/aliment_repository.dart';

class AlimentController extends ChangeNotifier {
  final AlimentRepository _repository;

  List<Aliment> _catalogueAliments = [];
  List<String> _categories = [];
  bool _isLoading = false;

  List<Aliment> get catalogueAliments => _catalogueAliments;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  AlimentController(this._repository) {
    chargerDonnees();
  }

  /// Charge le catalogue et les catégories
  Future<void> chargerDonnees() async {
    _isLoading = true;
    notifyListeners();

    try {
      _catalogueAliments = await _repository.getAliments();
      _categories = await _repository.getCategories();
    } catch (e) {
      print("ERREUR lors du chargement des données: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge uniquement le catalogue (ancienne méthode conservée)
  Future<void> chargerCatalogue() async {
    _isLoading = true;
    notifyListeners();

    try {
      _catalogueAliments = await _repository.getAliments();
    } catch (e) {
      print("ERREUR lors du chargement du catalogue: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}