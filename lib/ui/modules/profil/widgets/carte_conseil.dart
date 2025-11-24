import 'package:flutter/material.dart';

class CarteConseil extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String sousTitre;
  final Color couleurIcone;

  const CarteConseil({
    super.key,
    required this.icon,
    required this.titre,
    required this.sousTitre,
    this.couleurIcone = const Color(0xFF9C27B0), // Violet par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Espace entre chaque carte
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0FF), // Fond très clair (lilas pâle)
        borderRadius: BorderRadius.circular(16), // Coins arrondis
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. L'Icône à gauche
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: couleurIcone, size: 24),
          ),
          
          const SizedBox(width: 16),

          // 2. Les textes à droite
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sousTitre,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4, // Espacement des lignes pour la lecture
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









































// import 'package:flutter/material.dart';

// class CarteConseil extends StatelessWidget {
//   final IconData icon;
//   final String titre;
//   final String sousTitre;
//   final Color couleurIcone;

//   const CarteConseil({
//     super.key,
//     required this.icon,
//     required this.titre,
//     required this.sousTitre,
//     this.couleurIcone = const Color(0xFF9C27B0), // Violet par défaut
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8F0FF), // Fond très clair (lilas pâle)
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: couleurIcone, size: 28),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   titre,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   sousTitre,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[700],
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }