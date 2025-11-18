import 'package:flutter/material.dart';
import '/../../core/models/aliment_model.dart';

class TuileIngredient extends StatelessWidget {
  final Aliment aliment;
  final VoidCallback onTap;
  final double quantiteAuFrigo; // NOUVEAU : On reçoit la quantité

  const TuileIngredient({
    super.key,
    required this.aliment,
    required this.onTap,
    this.quantiteAuFrigo = 0, // Par défaut 0
  });

  @override
  Widget build(BuildContext context) {
    // Est-ce que cet item est déjà dans le frigo ?
    final bool estDansLeFrigo = quantiteAuFrigo > 0;

    return Stack(
      children: [
        // LA CARTE CLASSIQUE
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            // Bordure verte si présent
            side: estDansLeFrigo ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
          ),
          color: estDansLeFrigo ? Colors.green.shade50 : Colors.grey.shade100,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.network(
                      aliment.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.food_bank, size: 30, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aliment.nom,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: estDansLeFrigo ? Colors.green.shade900 : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),

        // LE BADGE DE QUANTITÉ (Si > 0)
        if (estDansLeFrigo)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "x${quantiteAuFrigo.toInt()}", // Affiche "x1", "x5"...
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}