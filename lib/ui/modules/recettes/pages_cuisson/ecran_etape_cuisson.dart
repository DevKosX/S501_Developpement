import 'package:flutter/material.dart';
import 'package:s501_developpement/core/models/recette_model.dart';
import 'package:s501_developpement/ui/modules/recettes/pages_cuisson/dialog_feedback.dart';

class EcranEtapeCuisson extends StatefulWidget {
  final String titre;
  final List<String> etapes; // = étapes déjà découpées
  final int indexDepart; // permet de commencer à l’étape 0
  final Recette recette;

  const EcranEtapeCuisson({
    super.key,
    required this.titre,
    required this.etapes,
    this.indexDepart = 0,
    required this.recette, 
  });

  @override
  State<EcranEtapeCuisson> createState() => _EcranEtapeCuissonState();
}

class _EcranEtapeCuissonState extends State<EcranEtapeCuisson> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.indexDepart;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.etapes.length;
    final numero = index + 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(widget.titre),
            Text(
              "Étape $numero sur $total",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // --- Barre de progression ---
            LinearProgressIndicator(
              value: numero / total,
              color: Colors.orange,
              backgroundColor: Colors.grey[300],
            ),

            const SizedBox(height: 20),

            // --- Carte étape ---
            _buildCardEtape(widget.etapes[index], numero),

            const Spacer(),

            // --- Boutons navigation ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: index == 0 ? null : () {
                      setState(() => index--);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.grey[800],
                    ),
                    child: const Text("← Précédent"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (index == total - 1) {
                        // DERNIÈRE ÉTAPE → ouvrir le feedback
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => DialogFeedback(recette: widget.recette),
                        );
                      } else {
                        setState(() => index++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      index == total - 1 ? "Terminer ✓" : "Suivant →",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardEtape(String texte, int numero) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "$numero",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Étape $numero",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),

          const SizedBox(height: 20),

          Text(
            texte,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5,
            ),
          )
        ],
      ),
    );
  }
}
