import 'package:flutter/material.dart';
import '../../../core/models/recette_model.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/recette_controller.dart';
import '../../../core/models/ingredient_recette_model.dart';





/// Fichier: core/ui/module/recettes/ecran_detail_recettes.dart
/// Author: Mohamed KOSBAR, Yassine BEN ABA
/// Implémentation du 26 novembre 2025
///



class EcranDetailRecette extends StatefulWidget  {
  final Recette recette;

  const EcranDetailRecette({super.key, required this.recette});

  @override
  State<EcranDetailRecette> createState() => _EcranDetailRecetteState();
}

class _EcranDetailRecetteState extends State<EcranDetailRecette> {
  @override
  void initState() {
    super.initState();
    context.read<RecetteController>().loadIngredients(widget.recette.id_recette);
  }
  
  @override
  Widget build(BuildContext context) {
    final ingredients = context.watch<RecetteController>().ingredients;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- 1. GRANDE IMAGE EN HAUT ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.recette.titre,
                  style: const TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                  )
              ),
              background: widget.recette.image.isNotEmpty
                  ? Image.network(
                widget.recette.image,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoBadge(icon: Icons.timer, text: "${widget.recette.tempsPreparation} min"),
                      _InfoBadge(icon: Icons.speed, text: widget.recette.difficulte),
                      _InfoBadge(icon: Icons.star, text: "${widget.recette.score}/5"),
                    ],
                  ),
                  const Divider(height: 30),

                  const Text(
                    "Ingrédients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  for (final ing in ingredients)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "- ${ing.quantite} ${ing.unite} ${ing.nom}"
                        "${ing.remarque != null && ing.remarque!.isNotEmpty ? " (${ing.remarque})" : ""}",
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),

                  SizedBox(height: 25),


                  const Text(
                    "Préparation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    widget.recette.instructions,
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

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBadge({
    required this.icon,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.orange, size: 28),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

