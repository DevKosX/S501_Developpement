import 'package:flutter/material.dart';

// Imports des écrans (Même s'ils sont vides pour l'instant)
import '../modules/accueil/ecran_accueil.dart';
import '../modules/frigo/ecran_frigo.dart';
import '../modules/recettes/ecran_recettes.dart';
import '../modules/favoris/ecran_favoris.dart';
import '../modules/historique/ecran_historique.dart';
import '../modules/profil/ecran_profil.dart';

class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key});

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  // --- CONFIGURATION DE L'ACCUEIL ---
  // 0 = Accueil, 1 = Frigo, 2 = Recettes...
  // Tu veux que Frigo soit l'ouverture, donc on met 1.
  int _indexSelectionne = 1;

  // La liste de tes 6 pages
  final List<Widget> _ecrans = [
    const EcranAccueil(),                                         // 0
    const EcranFrigo(),                                           // 1 (Défaut)
    const EcranRecettes(),                                        // 2
    const Scaffold(body: Center(child: Text("Page Favoris"))),    // 3
    const EcranHistorique(),                                      // 4
    const EcranProfil(), // 5    // Note: J'ai mis des Scaffold temporaires pour ceux que tu n'as pas encore codés
    // Tu pourras remplacer par "const EcranRecettes()" quand le fichier sera prêt.
  ];

  void _onItemTapped(int index) {
    setState(() {
      _indexSelectionne = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ecrans[_indexSelectionne],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indexSelectionne,
        onTap: _onItemTapped,

        // --- STYLE VISUEL (Comme ta capture) ---
        type: BottomNavigationBarType.fixed, // OBLIGATOIRE quand il y a + de 3 onglets
        selectedItemColor: Colors.orange,    // Couleur de l'icône active (Frigo)
        unselectedItemColor: Colors.grey,    // Couleur des autres
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        items: const [
          // 1. Accueil
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          // 2. Frigo (Celui qui sera orange au début)
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined), // Ou Icons.inventory_2_outlined
            activeIcon: Icon(Icons.kitchen),
            label: 'Frigo',
          ),
          // 3. Recettes
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recettes',
          ),
          // 4. Favoris
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favoris',
          ),
          // 5. Historique
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          // 6. Profil
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}