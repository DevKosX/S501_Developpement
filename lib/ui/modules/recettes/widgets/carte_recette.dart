import 'package:flutter/material.dart';
import '../../../../core/models/recette_model.dart';
import '../ecran_detail_recette.dart'; // Pour la navigation vers le détail

class CarteRecette extends StatelessWidget {
  final Recette recette;
  final bool estFaisable;

  const CarteRecette({
    super.key,
    required this.recette,
    required this.estFaisable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D1D35).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- IMAGE ---
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.asset(
                    "assets/images/${recette.image}",
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey[100],
                      child: const Center(child: Icon(Icons.restaurant, color: Colors.grey)),
                    ),
                  ),
                ),
              ),
              // Badge Type
              Positioned(
                top: 16,
                left: 16,
                child: _GlassBadge(text: recette.typeRecette.toUpperCase()),
              ),
              // Badge Manquant (Rouge) si nécessaire
              if (!estFaisable)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text(
                          "Manque ${recette.nombreManquants}",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // --- CONTENU ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  recette.titre,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Infos
                Row(
                  children: [
                    _InfoPill(icon: Icons.timer_outlined, text: "${recette.tempsPreparation} min"),
                    const SizedBox(width: 12),
                    _InfoPill(icon: Icons.bar_chart_rounded, text: recette.difficulte),
                    const Spacer(),
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "${recette.score}",
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bouton Large
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EcranDetailRecette(recette: recette),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE040FB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Voir la recette", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- PETITS WIDGETS PRIVÉS (Utilisés seulement par la carte) ---

class _GlassBadge extends StatelessWidget {
  final String text;
  const _GlassBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFAA00FF),
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}