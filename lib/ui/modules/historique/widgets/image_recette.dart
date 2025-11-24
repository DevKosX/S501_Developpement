import 'package:flutter/material.dart';

class ImageRecette extends StatelessWidget {
  final String imagePath;

  const ImageRecette({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Si aucune image n'est fournie → affichage par défaut
    if (imagePath.isEmpty) {
      return _fallback();
    }

    return Image.asset(
      "assets/images/$imagePath",
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,

      // Si l'image n'existe pas dans les assets → fallback
      errorBuilder: (context, error, stackTrace) {
        return _fallback();
      },
    );
  }

  // Widget fallback propre et épuré
  Widget _fallback() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood, size: 70, color: Colors.grey),
    );
  }
}
