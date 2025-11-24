import 'package:flutter/material.dart';

// --- IMPORTS NÉCESSAIRES ---
// Assurez-vous que les chemins correspondent à votre structure de projet
import '../../../core/models/recette_model.dart';
import '../../../core/repositories/recette_repository.dart';


/// Fichier: lib/ui/modules/accueil/ecran_accueil.dart
/// Author: Rafi Bettaieb
/// Implémentation du 23 novembre 2025
///
/// Cet écran d'accueil présente une grande image, un paragraphe de présentation,
/// une section "Top 5 des recettes" et une section de contact.
/// Il est conçu pour être responsive et s'adapte aux différentes tailles d'écran.
/// Il utilise le repository pour charger les recettes depuis la base de données.
/// Il affiche les 5 recettes les mieux notées .

class EcranAccueil extends StatefulWidget {
  const EcranAccueil({super.key});

  @override
  State<EcranAccueil> createState() => _EcranAccueilState();
}

class _EcranAccueilState extends State<EcranAccueil> {
  // Instance du repository
  final RecetteRepository _recetteRepo = RecetteRepositoryImpl();
  
  // Future pour stocker les recettes chargées
  late Future<List<Recette>> _topRecettesFuture;

  @override
  void initState() {
    super.initState();
    // Au démarrage, on lance le chargement
    _topRecettesFuture = _getTop5Recettes();
  }

  // Fonction pour récupérer et trier les recettes
  Future<List<Recette>> _getTop5Recettes() async {
    List<Recette> toutes = await _recetteRepo.getRecettes();
    // Tri par score décroissant
    toutes.sort((a, b) => b.score.compareTo(a.score));
    // On garde les 5 premières
    return toutes.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Calculs pour le responsive
    final Size screenSize = MediaQuery.of(context).size;
    final double paddingGlobal = screenSize.width * 0.05; // 5% de marge

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // ============================================================
            // 1. HERO SECTION (Grande image)
            // ============================================================
            SizedBox(
              height: screenSize.height * 0.40, // 40% de la hauteur écran
              child: Stack(
                children: [
                  // Image de fond
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Dégradé sombre pour lisibilité texte
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Textes "Bienvenue"
                  Positioned(
                    bottom: 30,
                    left: paddingGlobal,
                    right: paddingGlobal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bienvenue,\nChef !",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenSize.width * 0.09,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "L'inspiration culinaire commence ici.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: screenSize.width * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenSize.height * 0.03),

            // ============================================================
            // 2. PARAGRAPHE DE PRÉSENTATION
            // ============================================================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingGlobal),
              child: Column(
                children: [
                  Text(
                    "Cuisinez malin, mangez sain.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "RecetteFacile transforme votre frigo en restaurant gastronomique. Indiquez vos ingrédients, nous trouvons la recette parfaite. Fini le gaspillage et le manque d'inspiration !",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenSize.width * 0.035,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Trait décoratif
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenSize.height * 0.04),

            // ============================================================
            // 3. SECTION TOP 5 (GRILLE 2 COLONNES)
            // ============================================================
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingGlobal),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    "Le Top 5 des Chefs 🏆",
                    style: TextStyle(
                      fontSize: screenSize.width * 0.05, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF0F172A)
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),

            // GRILLE DES RECETTES
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingGlobal),
              child: FutureBuilder<List<Recette>>(
                future: _topRecettesFuture,
                builder: (context, snapshot) {
                  // Cas Chargement
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.orange));
                  } 
                  // Cas Erreur
                  else if (snapshot.hasError) {
                    return Center(child: Text("Erreur de chargement", style: TextStyle(color: Colors.grey[400])));
                  } 
                  // Cas Vide
                  else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucune recette trouvée"));
                  }

                  // Cas OK
                  final recettes = snapshot.data!;

                  return GridView.builder(
                    // Important pour scroller avec la page principale
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    
                    itemCount: recettes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,       // 2 recettes par ligne
                      crossAxisSpacing: 15,    // Espace horizontal
                      mainAxisSpacing: 15,     // Espace vertical
                      childAspectRatio: 0.65,  // <-- CORRECTION OVERFLOW (Plus haut que large)
                    ),
                    itemBuilder: (context, index) {
                      final recette = recettes[index];
                      return _buildRecetteGridCard(recette, screenSize);
                    },
                  );
                },
              ),
            ),

            SizedBox(height: screenSize.height * 0.04),

            // ============================================================
            // 4. SECTION CONTACT
            // ============================================================
            Container(
              margin: EdgeInsets.symmetric(horizontal: paddingGlobal, vertical: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                ]
              ),
              child: Column(
                children: [
                  const Icon(Icons.mail_outline, color: Colors.orange, size: 35),
                  const SizedBox(height: 15),
                  Text(
                    "Une question ou une idée ?",
                    style: TextStyle(color: Colors.white, fontSize: screenSize.width * 0.045, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Notre équipe est là pour vous aider à cuisiner mieux.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text("Nous contacter"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- WIDGET LOCAL : CARTE RECETTE (Optimisé pour Grille) ---
  Widget _buildRecetteGridCard(Recette recette, Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IMAGE (Prend le haut de la carte)
          Expanded(
            flex: 3, 
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.asset(
                  "assets/images/${recette.image}", // Assurez-vous d'avoir les images dans assets
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.restaurant, color: Colors.grey));
                  },
                ),
              ),
            ),
          ),
          
          // 2. INFOS (Prend le bas de la carte)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Padding ajusté
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre
                  Text(
                    recette.titre,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: screenSize.width * 0.035, // Police adaptative
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Ligne Score + Difficulté
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        recette.score.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 12,
                          color: Colors.grey
                        ),
                      ),
                      const Spacer(),
                      // Badge Difficulté
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recette.difficulte,
                          style: TextStyle(fontSize: 10, color: Colors.orange[800]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}