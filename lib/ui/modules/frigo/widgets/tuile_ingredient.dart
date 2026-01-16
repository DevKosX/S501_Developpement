import 'package:flutter/material.dart';
import '../../../../core/models/aliment_model.dart';
import '../../../../core/models/frigo_item_model.dart'; // [NOUVEAU] Import nécessaire pour l'Enum

class TuileIngredient extends StatelessWidget {
  final Aliment aliment;
  final double quantiteAuFrigo;
  final String unite;
  // [NOUVEAU] Paramètres pour la gestion de la péremption
  final StatutPeremption? statut;
  final DateTime? datePeremption;
  final VoidCallback? onTap;

  const TuileIngredient({
    super.key,
    required this.aliment,
    this.quantiteAuFrigo = 0,
    this.unite = "pcs",
    this.statut,         // [NOUVEAU]
    this.datePeremption, // [NOUVEAU]
    this.onTap,
  });

  bool get _estDansFrigo => quantiteAuFrigo > 0;

  // [NOUVEAU] Détermine la couleur en fonction du statut reçu du backend
  Color _getCouleurStatut() {
    switch (statut) {
      case StatutPeremption.perime:
      case StatutPeremption.critique:
        return Colors.red;
      case StatutPeremption.bientot:
        return Colors.orange;
      case StatutPeremption.frais:
        return Colors.green;
      default:
        return const Color(0xFFE040FB); // Couleur par défaut (Violet)
    }
  }

  // [NOUVEAU] Helper pour formater la date (ex: 12/05)
  String _formaterDate(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}";
  }

  /// Formate l'affichage de la quantité selon l'unité
  String _formaterQuantite() {
    final qte = quantiteAuFrigo.toInt();
    final uniteLC = unite.toLowerCase();

    // Unités de comptage → "x3"
    if (uniteLC == "pcs" || uniteLC == "pièce" || uniteLC == "pièces" ||
        uniteLC == "unité" || uniteLC == "unités") {
      return "x$qte";
    }

    // Unités de mesure → "110g", "500ml"
    return "$qte$unite";
  }

  @override
  Widget build(BuildContext context) {
    // [NOUVEAU] On récupère la couleur calculée
    final couleurStatut = _estDansFrigo ? _getCouleurStatut() : Colors.grey.shade200;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _estDansFrigo
              ? couleurStatut.withOpacity(0.05) // [MODIF] Fond teinté selon statut
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _estDansFrigo
                ? couleurStatut // [MODIF] Bordure colorée selon statut
                : Colors.grey.shade200,
            width: _estDansFrigo ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _estDansFrigo
                  ? couleurStatut.withOpacity(0.15) // [MODIF] Ombre colorée
                  : Colors.black.withOpacity(0.05),
              blurRadius: _estDansFrigo ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenu principal
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/images/aliments/${aliment.image}",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey[400],
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column( // [MODIF] Column au lieu de juste Text pour ajouter la date
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          aliment.nom,
                          textAlign: TextAlign.center,
                          maxLines: 1, // [MODIF] Max 1 ligne pour laisser place à la date
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: _estDansFrigo ? FontWeight.bold : FontWeight.w500,
                            color: _estDansFrigo
                                ? const Color(0xFFAA00FF)
                                : const Color(0xFF2D3436),
                          ),
                        ),
                        // [NOUVEAU] Affichage de la date sous le nom
                        if (_estDansFrigo && datePeremption != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Exp: ${_formaterDate(datePeremption!)}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: couleurStatut, // Texte de la couleur du statut
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Badge quantité
            if (_estDansFrigo)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // [MODIF] Utilise la couleur du statut
                    color: couleurStatut == const Color(0xFFE040FB) 
                        ? null // Si couleur par défaut, on laisse le gradient
                        : couleurStatut, 
                    gradient: couleurStatut == const Color(0xFFE040FB)
                        ? const LinearGradient(
                            colors: [Color(0xFFE040FB), Color(0xFFAA00FF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: couleurStatut.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _formaterQuantite(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}