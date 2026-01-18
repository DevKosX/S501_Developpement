import 'package:flutter/material.dart';
// Imports de tes widgets
import 'widgets/formulaire_imc.dart';
import 'package:s501_developpement/ui/modules/profil/widgets/carte_conseil.dart';
import 'package:s501_developpement/ui/modules/profil/widgets/conseils_rotatifs.dart';

// Imports de la logique (Core)
import '../../../core/controllers/profil_controller.dart';
import '../../../core/repositories/profil_repository.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/recette_controller.dart';


class EcranProfil extends StatefulWidget {
  const EcranProfil({super.key});

  @override
  State<EcranProfil> createState() => _EcranProfilState();
}

class _EcranProfilState extends State<EcranProfil> {
  // On initialise le contrôleur avec le Repository (Implémentation SQL ou Mock)
  final ProfilController _controller = ProfilController(ProfilRepositoryImpl());

  // Variables pour l'affichage
  double? _imcResultat;
  String _conseilResultat = "";

  void _gererCalcul(double poids, double taille, String objectif) async {
    // 1. On demande au contrôleur de faire le travail (sauvegarde + calcul)
    await _controller.mettreAJourProfil(poids, taille, objectif);
    if (mounted) {
      await context.read<RecetteController>().getRecettesTrieesParFrigo();
    }
    // 2. On met à jour l'écran avec les nouvelles valeurs du contrôleur
    setState(() {
      _imcResultat = _controller.imc;
      _conseilResultat = _controller.messageConseil;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              const Text("Mon Profil", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text("Suivez votre santé", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // --- FORMULAIRE ---
              FormulaireIMC(onCalculer: _gererCalcul),

              // --- RÉSULTAT (S'affiche seulement si un calcul a été fait) ---
              if (_imcResultat != null && _imcResultat! > 0) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE1BEE7), Color(0xFFF3E5F5)], // Violet clair
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text("VOTRE RÉSULTAT", style: TextStyle(letterSpacing: 1.5, fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple)),
                      const SizedBox(height: 10),
                      Text(
                        _imcResultat!.toStringAsFixed(1), // Affiche l'IMC (ex: 24.5)
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _conseilResultat, // Affiche ton conseil personnalisé !
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
              
              // --- LISTE DES CONSEILS GÉNÉRAUX ---
              const ConseilsRotatifs(),
              // const SizedBox(height: 15),
              
              // const CarteConseil(
              //   icon: Icons.directions_run, 
              //   titre: "Activité", 
              //   sousTitre: "Bougez 30min par jour",
              // ),

              // const CarteConseil(
              //   icon: Icons.water_drop, // Ou Icons.local_drink
              //   titre: "Hydratation", 
              //   sousTitre: "Buvez 1,5L d'eau par jour",
              // ),
              
              // const CarteConseil(
              //   icon: Icons.bed, // Ou Icons.nightlight_round
              //   titre: "Sommeil", 
              //   sousTitre: "Visez 7 à 8h de repos",
              // ),

              // const CarteConseil(
              //   icon: Icons.restaurant_menu, // Ou Icons.eco pour le côté "naturel"
              //   titre: "Nutrition", 
              //   sousTitre: "Mangez 5 fruits et légumes",
              // ),

              // const CarteConseil(
              //   icon: Icons.self_improvement, // Ou Icons.spa
              //   titre: "Mental", 
              //   sousTitre: "5 min de méditation ou calme",
              // ),

              // const CarteConseil(
              //   icon: Icons.visibility, 
              //   titre: "Yeux", 
              //   sousTitre: "Pause écrans toutes les 20min",
              //),
            ],
          ),
        ),
      ),
    );
  }
}





















































// import 'package:flutter/material.dart';
// import 'package:s501_developpement/ui/modules/profil/widgets/carte_conseil.dart';
// import 'package:s501_developpement/ui/modules/profil/widgets/formulaire_imc.dart';

// import '../../../core/controllers/profil_controller.dart';
// import '../../../core/repositories/profil_repository.dart';
// class EcranProfil extends StatefulWidget {
//   const EcranProfil({super.key});

//   @override
//   State<EcranProfil> createState() => _EcranProfilState();
// }

// class _EcranProfilState extends State<EcranProfil> {
//   double? _imcResultat;
//   String _messageSante = "";

//   void _calculerIMC(double poids, double taille) {
//     if (poids <= 0 || taille <= 0) return;

//     // La maquette demande la taille en cm (Ex: 175), mais la formule IMC utilise des mètres.
//     // Si l'utilisateur tape > 3 (ex: 175), on suppose que c'est des cm et on convertit.
//     double tailleEnMetres = taille > 3.0 ? taille / 100 : taille;

//     setState(() {
//       _imcResultat = poids / (tailleEnMetres * tailleEnMetres);
      
//       // Logique simple d'affichage (similaire à ton Controller)
//       if (_imcResultat! < 18.5) {
//         _messageSante = "Insuffisance pondérale";
//       } else if (_imcResultat! < 25) {
//         _messageSante = "Poids normal. Bravo !";
//       } else {
//         _messageSante = "Surpoids";
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Fond blanc global
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // --- EN-TÊTE ---
//               Row(
//                 children: [
//                   Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFE040FB), Color(0xFF7B1FA2)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Icon(Icons.person, color: Colors.white, size: 32),
//                   ),
//                   const SizedBox(width: 15),
//                   const Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Mon Profil",
//                         style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         "Calculez votre IMC et suivez votre santé",
//                         style: TextStyle(color: Colors.grey, fontSize: 12),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 30),

//               // --- CALCULATEUR IMC ---
//               FormulaireIMC(onCalculer: _calculerIMC),

//               // Résultat (affiché seulement si calculé)
//               if (_imcResultat != null) ...[
//                 const SizedBox(height: 20),
//                 Container(
//                   padding: const EdgeInsets.all(15),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF3E5F5), // Violet très clair
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.purple.shade100),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "Votre IMC : ${_imcResultat!.toStringAsFixed(1)}",
//                         style: const TextStyle(
//                           fontSize: 22, 
//                           fontWeight: FontWeight.bold, 
//                           color: Colors.purple
//                         ),
//                       ),
//                       Text(
//                         _messageSante,
//                         style: TextStyle(color: Colors.purple.shade700),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],

//               const SizedBox(height: 30),

//               // --- CONSEILS SANTÉ ---
//               const Row(
//                 children: [
//                   Icon(Icons.lightbulb_outline, color: Colors.purple),
//                   SizedBox(width: 8),
//                   Text(
//                     "Conseils Santé",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//                 // Liste des cartes
//                 CarteConseil(
//                     icon: Icons.apple_outlined,
//                     titre: "Alimentation équilibrée",
//                     sousTitre: "Privilégiez les fruits, légumes et protéines maigres",
//                 ),
//                 CarteConseil(
//                     icon: Icons.directions_run,
//                     titre: "Activité physique",
//                     sousTitre: "30 minutes d'exercice par jour minimum",
//                 ),
//                 CarteConseil(
//                     icon: Icons.water_drop_outlined,
//                     titre: "Hydratation",
//                     sousTitre: "Buvez au moins 1.5L d'eau par jour",
//                 ),
//                 CarteConseil(
//                     icon: Icons.bedtime_outlined,
//                     titre: "Sommeil",
//                     sousTitre: "7-8 heures de sommeil par nuit",
//                 ),
              
//               // Espace en bas pour la barre de navigation
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }