import 'package:flutter/material.dart';
import '../../../../core/models/recette_model.dart';
import 'carte_recette.dart'; // on importe la carte qu'on vient de créer

/// Fichier: core/ui/module/recettes/liste_recettes.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 23 novembre 2025
///


class ListeRecettes extends StatelessWidget {
  final List<Recette> recettes;
  final bool estFaisable;

  const ListeRecettes({
    super.key,
    required this.recettes,
    required this.estFaisable,
  });

  @override
  Widget build(BuildContext context) {
    // 1. ici c le cas si c vide
    if (recettes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
              ),
              child: Icon(
                  estFaisable ? Icons.soup_kitchen : Icons.edit_note,
                  size: 60,
                  color: Colors.grey[300]
              ),
            ),
            const SizedBox(height: 20),
            Text(
              estFaisable
                  ? "Rien n'est prêt !\nAjoutez des ingrédients au frigo."
                  : "Aucune recette ici.\nTout est peut-être déjà cuisinable ?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 2. CAS AVEC DONNÉES
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: recettes.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        // c ici j'appelle le widget de la carte
        return CarteRecette(
            recette: recettes[index],
            estFaisable: estFaisable
        );
      },
    );
  }
}