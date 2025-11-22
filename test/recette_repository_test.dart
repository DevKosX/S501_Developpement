import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

// Adaptez les imports selon votre projet
import 'package:s501_developpement/core/repositories/recette_repository.dart';
import 'package:s501_developpement/core/services/database_service.dart';

void main() {
  // Initialisation de SQLite pour l'environnement de test (Windows/Linux/Mac)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('Le repository utilise le Singleton et trie correctement (Favori + Frigo)', () async {
    // --- 1. NETTOYAGE DE LA BDD ---
    // On récupère l'instance réelle (comme dans l'app)
    final db = await DatabaseService.instance.database;
    
    // On vide les tables pour ne pas être gêné par les données du CSV
    await db.delete('RecetteAliment');
    await db.delete('Recettes');
    await db.delete('Frigo');
    await db.delete('FeedbackRecette');
    await db.delete('Aliments');

    // --- 2. INJECTION DES DONNÉES DE TEST ---

    // A. Création de 2 Recettes
    // Recette 1 : Standard (Score faible)
    await db.insert('Recettes', {
      'id_recette': 1, 'titre': 'Pâtes au Beurre', 'note_base': 3, 'score': 0
    });
    // Recette 2 : La "Gagnante" (Score élevé prévu)
    await db.insert('Recettes', {
      'id_recette': 2, 'titre': 'Omelette Lardons', 'note_base': 4, 'score': 0
    });

    // B. Création de l'aliment "Lardons" (id 23)
    await db.insert('Aliments', {
      'id_aliment': 23, 'nom': 'Lardons', 'categorie': 'Viande', 'nutriscore': 'D'
    });

    // C. Liaison : La recette 2 contient des Lardons
    await db.insert('RecetteAliment', {
      'id_recette': 2, 'id_aliment': 23, 'quantite': 200, 'unite': 'g'
    });

    // D. FRIGO : On met des Lardons qui périment DEMAIN (Bonus Urgence +15 pts)
    // + Bonus Présence (+10 pts)
    final dateDemain = DateTime.now().add(const Duration(days: 1)).toIso8601String();
    await db.insert('Frigo', {
      'id_aliment': 23, 'quantite': 200, 'date_ajout': DateTime.now().toString(), 'date_peremption': dateDemain
    });

    // E. FEEDBACK : L'utilisateur a mis la recette 2 en Favori (+20 pts)
    await db.insert('FeedbackRecette', {
      'id_recette': 2, 'favori': 1, 'note': 0
    });

    // --- 3. TEST DU REPOSITORY ---
    
    // On instancie le repo normalement (il va utiliser DatabaseService.instance tout seul)
    final repository = RecetteRepositoryImpl();
    
    print("Appel de getRecettesRecommandees()...");
    final resultats = await repository.getRecettesRecommandees();

    // --- 4. VÉRIFICATIONS ---

    expect(resultats.length, 2, reason: "On doit récupérer nos 2 recettes insérées");

    final premiere = resultats[0];
    
    print("Gagnant du tri : ${premiere.titre}");

    // La recette 2 DOIT être première car :
    // Base (4) + Favori (20) + Frigo (10) + Urgence (15) = 49 points
    // Contre Recette 1 : Base (3) = 3 points
    expect(premiere.id_recette, 2); 
    expect(premiere.titre, 'Omelette Lardons');
  });
}