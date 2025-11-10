

import 'package:flutter/material.dart';
import '../models/aliment_model.dart';
import '../repositories/aliment_repository.dart';

class AlimentController extends ChangeNotifier {
  // A besoin du Repository pour accéder aux données
  final AlimentRepository _repository;

  // --- ÉTAT (ce que la vue va afficher) ---
  List<Aliment> _catalogueAliments = [];
  bool _isLoading = false;

  // --- GETTERS (pour la vue) ---
  List<Aliment> get catalogueAliments => _catalogueAliments;
  bool get isLoading => _isLoading;

  // --- CONSTRUCTEUR ---
  AlimentController(this._repository) {
    // On charge le catalogue dès que le contrôleur est créé
    chargerCatalogue();
  }

  // --- MÉTHODES (appelées par la Vue) ---

  /// Charge tous les aliments depuis la BDD via le repository.
  Future<void> chargerCatalogue() async {
    _isLoading = true;
    notifyListeners(); // Dit à la vue d'afficher un loader

    try {
      // Appel au repository pour les vraies données
      _catalogueAliments = await _repository.getAliments();
    } catch (e) {
      print("ERREUR lors du chargement du catalogue: $e");
    }

    _isLoading = false;
    notifyListeners(); // Dit à la vue que les données sont prêtes
  }
}