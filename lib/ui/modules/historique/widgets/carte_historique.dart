import 'package:flutter/material.dart';
import '../../../../core/models/historique_model.dart';
import '../../../../core/models/recette_model.dart';
import 'image_recette.dart';
import 'package:provider/provider.dart';
import '../../../../core/controllers/historique_controller.dart';

import '../../../../core/controllers/feedback_recette_controller.dart';


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
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final historiqueCtrl = context.read<HistoriqueController>();

                        await historiqueCtrl.supprimerHistorique(historique.idhistorique!);
                      },
                    ),

                  ],
                ),

                const SizedBox(height: 8),

                Text("Réalisé le ${_formatDate(historique.dateaction)}",
                    style: TextStyle(color: Colors.grey.shade600)),

                const SizedBox(height: 10),

                // NOTE
                Row(
                  children: [
                    if (historique.note == null)
                      const Text("Aucune note")
                    else ...[
                      ...List.generate(
                        historique.note!,
                        (i) => const Icon(Icons.star, size: 18, color: Colors.amber),
                      ),
                      ...List.generate(
                        5 - historique.note!,
                        (i) => const Icon(Icons.star_border, size: 18, color: Colors.amber),
                      ),
                      const SizedBox(width: 6),
                      Text("${historique.note}/5"),
                    ]
                  ],
                ),



                const SizedBox(height: 14),

                _commentBox(
                  (historique.commentaire != null && historique.commentaire!.isNotEmpty)
                      ? '"${historique.commentaire!}"'
                      : "Aucun commentaire",
                ),
                const SizedBox(height: 14),

                // DUREE + DIFFICULTE
                Row(
                  children: [
                    Icon(Icons.schedule, size: 18, color: Color(0xFFE040FB)),
                    const SizedBox(width: 6),
                    Text("${historique.dureetotalemin} min"),

                    const SizedBox(width: 20),

                    Icon(Icons.bar_chart,
                        size: 18, color: Color(0xFFE040FB)),
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

  Widget _commentBox(String txt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        txt,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
