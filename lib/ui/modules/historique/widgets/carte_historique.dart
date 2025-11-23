import 'package:flutter/material.dart';
import '../../../../core/models/historique_model.dart';
import '../../../../core/models/recette_model.dart';
import 'image_recette.dart';

class CarteHistorique extends StatelessWidget {
  final Historique historique;
  final Recette? recette;

  const CarteHistorique({
    super.key,
    required this.historique,
    required this.recette,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: ImageRecette(imagePath: recette?.image ?? ""),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITRE + POUBELLE
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recette?.titre ?? "Recette inconnue",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.delete,
                          color: Colors.red.shade300, size: 20),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                Text("Réalisé le ${_formatDate(historique.dateaction)}",
                    style: TextStyle(color: Colors.grey.shade600)),

                const SizedBox(height: 10),

                // ETOILES + NOTE
                Row(
                  children: [
                    ...List.generate(
                        recette?.score.toInt() ?? 0,
                        (i) => const Icon(Icons.star,
                            size: 18, color: Colors.amber)),
                    ...List.generate(
                        5 - (recette?.score.toInt() ?? 0),
                        (i) => const Icon(Icons.star_border,
                            size: 18, color: Colors.amber)),
                    const SizedBox(width: 6),
                    Text("${recette?.score ?? 0}/5"),
                  ],
                ),

                const SizedBox(height: 14),

                // COMMENTAIRE (placeholder)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "\"Commentaire non implémenté\"",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const SizedBox(height: 14),

                // DUREE + DIFFICULTE
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text("${historique.dureetotalemin} min"),

                    const SizedBox(width: 20),

                    Icon(Icons.bar_chart,
                        size: 18, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(recette?.difficulte ?? "—"),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
