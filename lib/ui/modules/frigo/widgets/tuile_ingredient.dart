import 'package:flutter/material.dart';
import '../../../../core/models/aliment_model.dart';

class TuileIngredient extends StatelessWidget {
  final Aliment aliment;
  final double quantiteAuFrigo;
  final String unite;
  final VoidCallback? onTap;

  const TuileIngredient({
    super.key,
    required this.aliment,
    this.quantiteAuFrigo = 0,
    this.unite = "pcs",
    this.onTap,
  });

  bool get _estDansFrigo => quantiteAuFrigo > 0;

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _estDansFrigo
              ? const Color(0xFFE040FB).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _estDansFrigo
                ? const Color(0xFFE040FB).withOpacity(0.5)
                : Colors.grey.shade200,
            width: _estDansFrigo ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _estDansFrigo
                  ? const Color(0xFFE040FB).withOpacity(0.15)
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
                      "assets/images/${aliment.image}",
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
                    child: Text(
                      aliment.nom,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: _estDansFrigo ? FontWeight.bold : FontWeight.w500,
                        color: _estDansFrigo
                            ? const Color(0xFFAA00FF)
                            : const Color(0xFF2D3436),
                      ),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE040FB), Color(0xFFAA00FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE040FB).withOpacity(0.4),
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