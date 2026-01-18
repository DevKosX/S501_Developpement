import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/historique_controller.dart';
import '../../../core/controllers/recette_controller.dart';
import '../../../core/models/historique_model.dart';
import '../../../core/models/recette_model.dart';

import 'widgets/carte_historique.dart';
import 'widgets/etat_vide_historique.dart';

class EcranHistorique extends StatefulWidget {
  const EcranHistorique({super.key});

  @override
  State<EcranHistorique> createState() => _EcranHistoriqueState();
}

class _EcranHistoriqueState extends State<EcranHistorique> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HistoriqueController>().chargerHistorique();
        context.read<RecetteController>().chargerRecettes();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HistoriqueController, RecetteController>(
      builder: (context, histCtrl, recCtrl, _) {
        // --- RÉCUPÉRATION ---
        final items = [...histCtrl.historiqueList];

        // --- TRI DU PLUS RÉCENT AU PLUS ANCIEN ---
        items.sort((a, b) => b.dateaction.compareTo(a.dateaction));

        final recettes = recCtrl.listeRecettes;

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ENTÊTE ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFFE040FB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.history,
                            color: Color(0xFFE040FB)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Historique",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Vos recettes réalisées",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    ],
                  ),
                ),

                const Divider(height: 8),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "${items.length} recette${items.length > 1 ? 's' : ''} réalisée${items.length > 1 ? 's' : ''}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),

                // --- LISTE ---
                Expanded(
                  child: items.isEmpty
                      ? const EtatVideHistorique()
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                              top: 0, bottom: 24, left: 12, right: 12),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final h = items[index];

                            Recette? recette;
                            try {
                              recette = recettes.firstWhere(
                                  (r) => r.id_recette == h.idrecette);
                            } catch (_) {
                              recette = null;
                            }

                            return CarteHistorique(
                              historique: h,
                              recette: recette,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
