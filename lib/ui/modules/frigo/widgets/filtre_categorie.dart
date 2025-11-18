import 'package:flutter/material.dart';

class FiltreCategorie extends StatelessWidget {
  const FiltreCategorie({super.key});

  @override
  Widget build(BuildContext context) {
    // Tu pourras rendre cette liste dynamique plus tard si besoin
    final filters = ['Légumineuses', 'Épices', 'Herbes', 'Condiments', 'Boissons', 'Autres'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((label) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Chip(
            label: Text(label),
            backgroundColor: Colors.grey.shade200,
            side: BorderSide.none,
          ),
        )).toList(),
      ),
    );
  }
}