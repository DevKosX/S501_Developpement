import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/recette_controller.dart';
import 'widgets/liste_recettes.dart';

/// Fichier: core/ui/module/recettes/ecran_recettes.dart
/// Author: Mohamed KOSBAR
/// Implémentation du 22 novembre 2025
///


class EcranRecettes extends StatefulWidget {
  const EcranRecettes({super.key});

  @override
  State<EcranRecettes> createState() => _EcranRecettesState();
}

class _EcranRecettesState extends State<EcranRecettes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecetteController>().getRecettesTrieesParFrigo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecetteController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // --- TITRE ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recettes",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D3436),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Qu'allons-nous manger aujourd'hui ?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- ONGLETS ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: const Color(0xFFE040FB),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 18),
                            SizedBox(width: 8),
                            Text("Cuisinable"),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_basket_outlined, size: 18),
                            SizedBox(width: 8),
                            Text("À compléter"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // --- CONTENU (Appelle le widget ListeRecettes) ---
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE040FB)))
                    : TabBarView(
                  children: [
                    // Onglet 1
                    ListeRecettes(
                      recettes: controller.recettesFaisables,
                      estFaisable: true,
                    ),
                    // Onglet 2
                    ListeRecettes(
                      recettes: controller.recettesManquantes,
                      estFaisable: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}