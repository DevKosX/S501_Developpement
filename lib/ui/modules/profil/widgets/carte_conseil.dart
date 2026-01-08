import 'package:flutter/material.dart';

class CarteConseil extends StatelessWidget {
  final IconData icon;
  final String titre;
  final String sousTitre;

  const CarteConseil({
    super.key,
    required this.icon,
    required this.titre,
    required this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.purple),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sousTitre, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}