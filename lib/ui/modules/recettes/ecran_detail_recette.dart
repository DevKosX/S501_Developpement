import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:s501_developpement/core/controllers/aliment_controller.dart';
import 'package:s501_developpement/core/controllers/frigo_controller.dart';
import '../../../core/models/recette_model.dart';
import '../../../core/models/feedback_recette_model.dart';
import '../../../core/controllers/recette_controller.dart';
import '../../../core/controllers/feedback_recette_controller.dart';
import '../recettes/pages_cuisson/ecran_etape_cuisson.dart';

// Imports nécessaires pour la logique de comparaison
import '../../../core/models/ingredient_recette_model.dart';
import '../../../core/models/aliment_model.dart';
import '../../../core/services/unit_conversion_service.dart';

/// Fichier: core/ui/module/recettes/ecran_detail_recette.dart
/// Author: Mohamed KOSBAR, Yassine BEN ABA
/// Implémentation du 26 novembre 2025

// Enum pour définir les 3 états possibles d'un ingrédient
enum EtatIngredient { manquant, insuffisant, suffisant }

class EcranDetailRecette extends StatefulWidget {
  final Recette recette;

  const EcranDetailRecette({super.key, required this.recette});

  @override
  State<EcranDetailRecette> createState() => _EcranDetailRecetteState();
}

class _EcranDetailRecetteState extends State<EcranDetailRecette> {
  @override
  void initState() {
    super.initState();
    // Charge les ingrédients de la recette spécifique
    context.read<RecetteController>().loadIngredients(widget.recette.id_recette);
  }

  /// Calcule l'état précis (Manquant / Insuffisant / Suffisant)
  EtatIngredient _calculerEtatIngredient(
      IngredientRecette ingredient,
      FrigoController frigoCtrl,
      AlimentController alimentCtrl) {
    
    // 1. Trouver l'aliment correspondant dans le catalogue
    Aliment? aliment;
    try {
      aliment = alimentCtrl.catalogueAliments.firstWhere(
        (a) => a.nom.toLowerCase() == ingredient.nom.toLowerCase(),
      );
    } catch (_) {
      // Si l'aliment n'est pas reconnu, on le marque manquant
      return EtatIngredient.manquant;
    }

    // 2. Trouver l'item dans le frigo
    final itemFrigo = frigoCtrl.contenuFrigo.where(
      (item) => item.id_aliment == aliment!.id_aliment,
    );

    if (itemFrigo.isEmpty) {
      return EtatIngredient.manquant;
    }

    // 3. Calculer les totaux en grammes
    double totalGrammesFrigo = 0.0;
    for (var item in itemFrigo) {
      totalGrammesFrigo += UnitConversionService.toGrammes(
        quantite: item.quantite,
        unite: item.unite,
        poidsUnitaire: aliment!.poids_unitaire,
      );
    }

    double grammesRequis = UnitConversionService.toGrammes(
      quantite: ingredient.quantite,
      unite: ingredient.unite,
      poidsUnitaire: aliment!.poids_unitaire,
    );

    // Comparaison avec une marge d'erreur de 0.1g
    if (totalGrammesFrigo >= (grammesRequis - 0.1)) {
      return EtatIngredient.suffisant;
    }

    return EtatIngredient.insuffisant;
  }

  // Helper pour récupérer la couleur de l'icône selon l'état
  Color _getColorForEtat(EtatIngredient etat) {
    switch (etat) {
      case EtatIngredient.manquant:
        return Colors.red;
      case EtatIngredient.insuffisant:
        return Colors.orange.shade800;
      case EtatIngredient.suffisant:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des contrôleurs via Provider
    final ingredients = context.watch<RecetteController>().ingredients;
    final frigoCtrl = context.watch<FrigoController>();
    final alimentCtrl = context.watch<AlimentController>();

    return Scaffold(
      // --- BOUTON FAVORIS ---
      

      body: CustomScrollView(
        slivers: [
          // --- IMAGE ---
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor:  Color(0xFFE040FB),

            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Consumer<FeedbackRecetteController>(
                  builder: (context, controller, _) {
                    final estFavori = controller.feedbacks.any(
                      (f) =>
                          f.idrecette == widget.recette.id_recette &&
                          f.favori == 1,
                    );

                    return GestureDetector(
                      onTap: () async {
                        final feedback = FeedbackRecette(
                          idrecette: widget.recette.id_recette,
                          favori: estFavori ? 0 : 1,
                          note: 0,
                        );

                        await controller.toggleFavori(feedback);
                        await context
                            .read<RecetteController>()
                            .getRecettesTrieesParFrigo();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: estFavori
                              ? Colors.red
                              : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              estFavori
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: estFavori ? Colors.white : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              estFavori ? "En favoris" : "Ajouter",
                              style: TextStyle(
                                color:
                                    estFavori ? Colors.white : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],


            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.recette.titre, //
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black45)]
                ),
              ),
              background: widget.recette.image.isNotEmpty
                ? Image.asset(
                    "assets/images/recettes/${widget.recette.image}", //
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Color(0xFFE040FB),
                        child: const Center(
                          child: Icon(Icons.restaurant, size: 50, color: Colors.white54),
                        ),
                      );
                    },
                  )
                : Container(color: Color(0xFFE040FB)),
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
                      _InfoBadge(icon: Icons.timer, text: "${widget.recette.tempsPreparation} min"), //
                      _InfoBadge(icon: Icons.speed, text: widget.recette.difficulte), //
                      if (widget.recette.calories > 0)
                        _InfoBadge(icon: Icons.local_fire_department, text: "${widget.recette.calories} kcal"), //
                      _InfoBadge(icon: Icons.star, text: "${widget.recette.score}/5"), //
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
                      
                      final etat = _calculerEtatIngredient(ing, frigoCtrl, alimentCtrl);
                      final color = _getColorForEtat(etat);

                      // Icône selon l'état
                      IconData iconData;
                      switch (etat) {
                        case EtatIngredient.manquant:
                          iconData = Icons.cancel; // Croix rouge
                          break;
                        case EtatIngredient.insuffisant:
                          iconData = Icons.warning_amber_rounded; // Attention orange
                          break;
                        case EtatIngredient.suffisant:
                          iconData = Icons.check_circle; // Check vert
                          break;
                      }

                      return Container(
                        // Suppression du fond coloré et de la bordure
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Symbole coloré uniquement
                            Icon(iconData, size: 20, color: color),
                            
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Text(
                                "${ing.quantite} ${ing.unite} ${ing.nom}$remarque",
                                style: const TextStyle(
                                  fontSize: 16, 
                                  height: 1.3,
                                  color: Colors.black87, // Texte noir standard
                                  fontWeight: FontWeight.normal, // Poids standard
                                ),
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
                    children: _buildEtapes(widget.recette.instructions), //
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
                          
                          final success = await frigoCtrl.consommerIngredientsPourRecette( //
                            recetteCtrl.ingredients,
                            alimentCtrl.catalogueAliments,
                          );

                          if (!success) {
                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.warning, color: Colors.white),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Ingrédients insuffisants dans votre frigo",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          await recetteCtrl.getRecettesTrieesParFrigo(); //

                          final etapes = _decouperEtapes(widget.recette.instructions); //

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EcranEtapeCuisson( //
                                  recette: widget.recette,
                                  titre: widget.recette.titre,
                                  etapes: etapes,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE040FB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Commencer à cuisiner",
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
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFE040FB),
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
        Icon(icon, color: Color(0xFFE040FB), size: 28),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}