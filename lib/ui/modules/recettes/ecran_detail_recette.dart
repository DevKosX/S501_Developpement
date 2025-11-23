import 'package:flutter/material.dart';
import '../../../core/models/recette_model.dart';






/// Fichier: core/ui/module/recettes/ecran_detail_recettes.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 22 novembre 2025
///



class EcranDetailRecette extends StatelessWidget {
  final Recette recette;

  const EcranDetailRecette({super.key, required this.recette});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. GRANDE IMAGE EN HAUT ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(recette.titre,
                  style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                  )
              ),
              background: recette.image.isNotEmpty
                  ? Image.network(
                recette.image,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: Colors.orange.shade200),
              )
                  : Container(color: Colors.orange),
            ),
          ),

          // --- 2. CONTENU ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Infos rapides
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoBadge(icon: Icons.timer, text: "${recette.tempsPreparation} min"),
                      _InfoBadge(icon: Icons.speed, text: recette.difficulte),
                      _InfoBadge(icon: Icons.star, text: "${recette.score}/5"),
                    ],
                  ),
                  const Divider(height: 30),

                  // Titre Instructions
                  const Text(
                    "Préparation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Texte des instructions
                  Text(
                    recette.instructions, // Assurez-vous que c'est le bon nom dans votre modèle
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// petit widget ic pour afficher les icônes (durée, difficulté...)
class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}