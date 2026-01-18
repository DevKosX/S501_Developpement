import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/controllers/feedback_recette_controller.dart';
import '../../../../core/models/recette_model.dart';
import '../../../../core/controllers/historique_controller.dart';
import '../../../../core/models/historique_model.dart';


class DialogFeedback extends StatefulWidget {
  final Recette recette;

  const DialogFeedback({super.key, required this.recette});

  @override
  State<DialogFeedback> createState() => _DialogFeedbackState();
}

class _DialogFeedbackState extends State<DialogFeedback> {
  int note = 0;
  final TextEditingController commentaireController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- ICONE GREEN CHECK ---
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),

            const SizedBox(height: 18),

            const Text(
              "Félicitations !",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Vous avez terminé cette recette",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            // ---- ÉTOILES ----
            const Text(
              "Notez cette recette",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final index = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => note = index),
                  child: Icon(
                    Icons.star,
                    size: 34,
                    color: index <= note ? Colors.amber : Colors.grey[300],
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // ----- COMMENTAIRE -----
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Notes (optionnel)",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 6),

            TextField(
              controller: commentaireController,
              maxLines: 4,
              inputFormatters: [
                LengthLimitingTextInputFormatter(500),
              ],
              decoration: InputDecoration(
                hintText: "Ajoutez vos commentaires...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- BOUTONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Annuler"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: note == 0 ? null : () async {
                      final feedbackCtrl = context.read<FeedbackRecetteController>();
                      final histoCtrl = context.read<HistoriqueController>();

                      // 1. Enregistrer le feedback
                      await feedbackCtrl.enregistrerFeedback(
                        idRecette: widget.recette.id_recette,
                        note: note,
                        commentaire: commentaireController.text.trim(),
                      );

                      // 2. Enregistrer l’historique
                      await histoCtrl.enregistrerAction(
                        Historique(
                          idhistorique: null,
                          idrecette: widget.recette.id_recette,
                          dateaction: DateTime.now(),
                          dureetotalemin: widget.recette.tempsPreparation,
                          note: note, 
                          commentaire: commentaireController.text.trim(),
                        ),
                      );

                      // Rafraîchir l'historique AVANT de quitter
                      await context.read<HistoriqueController>().chargerHistorique();

                      // 3. Navigation
                      Navigator.pop(context); // ferme DialogFeedback
                      Navigator.pop(context); // quitte écran cuisson
                      Navigator.pop(context); // retourne à l'écran des recettes
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: Colors.orange.withOpacity(0.4),
                      disabledForegroundColor: Colors.white.withOpacity(0.7),
                    ),

                    child: const Text(
                      "Enregistrer",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          ],
            ),
          ),
        ),
      ),
    );

  }
}
