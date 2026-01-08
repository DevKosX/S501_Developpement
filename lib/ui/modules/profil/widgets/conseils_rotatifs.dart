import 'dart:async';
import 'package:flutter/material.dart';

// IMPORT ESSENTIEL : Pour que ce fichier connaisse "CarteConseil"
import 'carte_conseil.dart'; 

class ConseilsRotatifs extends StatefulWidget {
  const ConseilsRotatifs({super.key});

  @override
  State<ConseilsRotatifs> createState() => _ConseilsRotatifsState();
}

class _ConseilsRotatifsState extends State<ConseilsRotatifs> {
  final List<Map<String, dynamic>> _listeConseils = [
    {
      "icon": Icons.directions_run,
      "titre": "Activité",
      "sousTitre": "Bougez 30min par jour"
    },
    {
      "icon": Icons.water_drop, // Ou Icons.local_drink si water_drop indisponible
      "titre": "Hydratation",
      "sousTitre": "Buvez 1,5L d'eau par jour"
    },
    {
      "icon": Icons.bed, // Ou Icons.nightlight_round
      "titre": "Sommeil",
      "sousTitre": "Visez 7 à 8h de repos"
    },
    {
      "icon": Icons.restaurant,
      "titre": "Nutrition",
      "sousTitre": "Mangez 5 fruits et légumes"
    },
    {
      "icon": Icons.visibility,
      "titre": "Yeux",
      "sousTitre": "Lâchez l'écran 5min / heure"
    },
    {
      "icon": Icons.self_improvement, // Ou Icons.spa
      "titre": "Détente",
      "sousTitre": "Respirez profondément"
    },
    {
      "icon": Icons.wb_sunny,
      "titre": "Lumière",
      "sousTitre": "Sortez prendre l'air frais"
    },

    {
      "icon": Icons.no_food, // Pour symboliser "éviter la malbouffe"
      "titre": "Sucre",
      "sousTitre": "Limitez les boissons sucrées"
    },
  ];

  int _indexActuel = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _indexActuel = (_indexActuel + 1) % _listeConseils.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conseil = _listeConseils[_indexActuel];
    return Column(
      children: [
        const Text("Conseils Santé", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
             return FadeTransition(opacity: animation, child: child);
          },
          // Il utilise la classe importée depuis l'autre fichier
          child: CarteConseil(
            key: ValueKey<int>(_indexActuel),
            icon: conseil['icon'],
            titre: conseil['titre'],
            sousTitre: conseil['sousTitre'],
          ),
        ),
      ],
    );
  }
}