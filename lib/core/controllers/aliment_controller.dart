import 'package:flutter/material.dart';
import '../models/aliment_model.dart';
import '../repositories/aliment_repository.dart';

class AlimentController extends ChangeNotifier {
  final AlimentRepository _repository;

  List<Aliment> _catalogueAliments = [];
  bool _isLoading = false;
  List<String> _categories = [];

  List<Aliment> get catalogueAliments => _catalogueAliments;
  bool get isLoading => _isLoading;
  List<String> get categories => _categories;

  AlimentController(this._repository) {
    chargerCatalogue();
  }

  Future<void> chargerCatalogue() async {
    _isLoading = true;
    notifyListeners();

    try {
      _catalogueAliments = await _repository.getAliments();
      final uniqueCategories = await _repository.getUniqueCategories();

      final List<String> filtreCategories = ['Tout'];
      filtreCategories.addAll(uniqueCategories);

      if (!filtreCategories.contains('Autre')) {
        filtreCategories.add('Autre');
      }
      _categories = filtreCategories;

    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<String> getUnitesPourAliment(Aliment aliment) {
    return _repository.getUnitesPourAliment(aliment);
  }
}