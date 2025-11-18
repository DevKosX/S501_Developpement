import 'package:flutter/material.dart';
import '/../../core/models/aliment_model.dart';

class TuileIngredient extends StatelessWidget {
  final Aliment aliment;
  final VoidCallback onTap;
  final double quantiteAuFrigo;

  const TuileIngredient({
    super.key,
    required this.aliment,
    required this.onTap,
    this.quantiteAuFrigo = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bool estDansLeFrigo = quantiteAuFrigo > 0;

    return Stack(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
                    // MODIFICATION POUR LES IMAGES DU CSV
                    // On essaie de charger l'image depuis les assets.
                    // Si 'aliment.image' vaut 'oeuf.jpg', on cherche 'assets/images/oeuf.jpg'
                    child: Image.asset(
                      "assets/images/${aliment.image}",
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Si l'image n'existe pas en local, on essaie Internet (au cas où)
                        return Image.network(
                          aliment.image,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.food_bank, size: 30, color: Colors.grey),
                        );
                      },
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
                "x${quantiteAuFrigo.toInt()}",
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }
}