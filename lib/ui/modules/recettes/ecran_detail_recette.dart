import 'package:flutter/material.dart';
import 'package:s501_developpement/core/controllers/aliment_controller.dart';
import 'package:s501_developpement/core/controllers/frigo_controller.dart';
import '../../../core/models/recette_model.dart';
import '../../../core/models/feedback_recette_model.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/recette_controller.dart';
import '../../../core/controllers/feedback_recette_controller.dart';
import '../recettes/pages_cuisson/ecran_etape_cuisson.dart';


/// Fichier: core/ui/module/recettes/ecran_detail_recettes.dart
/// Author: Mohamed KOSBAR, Yassine BEN ABA
/// Implémentation du 26 novembre 2025

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
      // --- BOUTON FAVORIS AMÉLIORÉ - Plus visible et animé ---
      floatingActionButton: Consumer<FeedbackRecetteController>(
        builder: (context, controller, _) {
          final estFavori = controller.feedbacks
              .any((f) => f.idrecette == widget.recette.id_recette && f.favori == 1);
          
          return FloatingActionButton.extended(
            backgroundColor: estFavori ? Colors.red : Colors.white,
            elevation: 8,
            onPressed: () async {
              final feedback = FeedbackRecette(
                idrecette: widget.recette.id_recette,
                favori: estFavori ? 0 : 1,
                note: 0,
              );
              await controller.toggleFavori(feedback);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          estFavori ? Icons.heart_broken : Icons.favorite,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          estFavori 
                            ? 'Retiré des favoris' 
                            : 'Ajouté aux favoris !',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: estFavori ? Colors.grey[800] : Colors.pink,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            icon: Icon(
              estFavori ? Icons.favorite : Icons.favorite_border,
              color: estFavori ? Colors.white : Colors.red,
              size: 28,
            ),
            label: Text(
              estFavori ? 'En favoris' : 'Ajouter',
              style: TextStyle(
                color: estFavori ? Colors.white : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
      // -----------------------------------

      body: CustomScrollView(
        slivers: [
          // --- IMAGE ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.recette.titre,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                ),
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

          // --- CONTENU ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoBadge(icon: Icons.timer, text: "${widget.recette.tempsPreparation} min"),
                      _InfoBadge(icon: Icons.speed, text: widget.recette.difficulte),
                      _InfoBadge(icon: Icons.star, text: "${widget.recette.score}/5"),
                    ],
                  ),

                  const Divider(height: 30),

                  // INGREDIENTS
                  const Text(
                    "Ingrédients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: ingredients.map((ing) {
                      final remarque = (ing.remarque != null && ing.remarque!.isNotEmpty)
                          ? " (${ing.remarque})"
                          : "";

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.orange),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "${ing.quantite} ${ing.unite} ${ing.nom}$remarque",
                                style: const TextStyle(fontSize: 16, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 25),

                  // PREPARATION
                  const Text(
                    "Préparation",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Column(
                    children: _buildEtapes(widget.recette.instructions),
                  ),

                  const SizedBox(height: 30),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          final recetteCtrl = context.read<RecetteController>();
                          final frigoCtrl = context.read<FrigoController>();
                          final alimentCtrl = context.read<AlimentController>();
                          
                          await frigoCtrl.consommerIngredientsRecette(
                            recetteCtrl.ingredients,
                            alimentCtrl.catalogueAliments,
                          );

                          final etapes = _decouperEtapes(widget.recette.instructions);
                          
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EcranEtapeCuisson(
                                recette: widget.recette,
                                titre: widget.recette.titre,
                                etapes: etapes,
                              ),
                            ),
                          );

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "🍳 Commencer à cuisiner",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// -----------------------------------------------------------
  ///         CONSTRUCTION DES ÉTAPES (Style maquette)
  /// -----------------------------------------------------------
  List<Widget> _buildEtapes(String instructions) {
    final regex = RegExp(r'(\d+)\.\s');
    final matches = regex.allMatches(instructions);
    final etapesWidgets = <Widget>[];

    for (int i = 0; i < matches.length; i++) {
      final numero = matches.elementAt(i).group(1)!;

      final start = matches.elementAt(i).end;
      final end = (i + 1 < matches.length)
          ? matches.elementAt(i + 1).start
          : instructions.length;

      final texte = instructions.substring(start, end).trim();

      etapesWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pastille orange
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    numero,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Texte
              Expanded(
                child: Text(
                  texte,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return etapesWidgets;
  }

  List<String> _decouperEtapes(String instructions) {
    final regex = RegExp(r'(\d+)\.\s');
    final matches = regex.allMatches(instructions);
    List<String> result = [];

    for (int i = 0; i < matches.length; i++) {
      final start = matches.elementAt(i).end;
      final end = i + 1 < matches.length
          ? matches.elementAt(i + 1).start
          : instructions.length;

      result.add(instructions.substring(start, end).trim());
    }

    return result;
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
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
