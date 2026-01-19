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

// MODIFICATION : Transformation de la liste en Map pour associer des icônes
final Map<String, IconData> categoriesRecettesMap = {
  'Toutes': Icons.grid_view_rounded,
  'Entrée': Icons.soup_kitchen_rounded,
  'Plat': Icons.restaurant_menu_rounded,
  'Dessert': Icons.icecream_rounded,
  'Boisson': Icons.local_bar_rounded,
//  'Petit-déjeuner': Icons.free_breakfast_rounded,
  'Sauce': Icons.water_drop_rounded,
  'Accompagnement': Icons.rice_bowl_rounded,
};

class _EcranRecettesState extends State<EcranRecettes> {

// 2. Le contrôleur de recherche
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecetteController>().getRecettesTrieesParFrigo();
    });
    
    // MODIFICATION : On retire le listener ici pour ne pas déclencher la recherche à chaque caractère.
    // _searchController.addListener(() {
    //   context.read<RecetteController>().setRecherche(_searchController.text);
    // });
  }

  // AJOUT 3 : On n'oublie pas de nettoyer le contrôleur quand on quitte la page
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RecetteController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF9FAFB),
        // MODIFICATION : Column remplacée par NestedScrollView pour le scroll sticky
        body: NestedScrollView(
          floatHeaderSlivers: true, 
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // --- BLOC 1 : EN-TÊTE QUI SCROLLE (Titre + Recherche + Filtres) ---
              SliverAppBar(
                backgroundColor: const Color(0xFFF9FAFB),
                surfaceTintColor: Colors.transparent,
                floating: true,
                snap: true,
                pinned: false,
                automaticallyImplyLeading: false,
                toolbarHeight: 360, // Hauteur suffisante pour contenir vos widgets
                titleSpacing: 0,
                title: Column(
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

                    // --- BARRE DE RECHERCHE ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _searchController,
                        // MODIFICATION : Configure le bouton du clavier pour afficher "Rechercher"
                        textInputAction: TextInputAction.search,
                        // MODIFICATION : Déclenche la recherche uniquement quand l'utilisateur valide (Enter)
                        onSubmitted: (value) {
                          context.read<RecetteController>().setRecherche(value);
                        },
                        // AJOUT : Réinitialise la liste si le champ est vidé
                        onChanged: (text) {
                          if (text.isEmpty) {
                            context.read<RecetteController>().setRecherche("");
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Rechercher une recette...",
                          
                          // MODIFICATION : La loupe redevient une simple icône décorative à gauche
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          
                          // NOUVEAU : Bouton d'action explicite à droite
                          suffixIcon: Padding(
                            padding: const EdgeInsets.all(4.0), 
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFE040FB), // Couleur du thème
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                                tooltip: "Lancer la recherche",
                                onPressed: () {
                                  // Action du bouton : Lance la recherche et ferme le clavier
                                  context.read<RecetteController>().setRecherche(_searchController.text);
                                  FocusScope.of(context).unfocus(); 
                                },
                              ),
                            ),
                          ),
                          
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // --- FILTRES PAR CATÉGORIE (NOUVEAU : WRAP RESPONSIVE) ---
                    // Utilisation de Wrap au lieu de ListView pour afficher tout le contenu
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: 10.0, // Espace horizontal entre les items
                          runSpacing: 10.0, // Espace vertical entre les lignes
                          alignment: WrapAlignment.start,
                          children: categoriesRecettesMap.entries.map((entry) {
                            final String cat = entry.key;
                            final IconData icon = entry.value;
                            
                            // On vérifie si cette catégorie est celle sélectionnée dans le contrôleur
                            final estSelectionnee = controller.categorieSelectionnee == cat;

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // On met à jour la catégorie dans le contrôleur
                                  controller.setCategorie(cat);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: estSelectionnee ? const Color(0xFFE040FB) : Colors.white,
                                    borderRadius: BorderRadius.circular(25), 
                                    border: Border.all(
                                      color: estSelectionnee
                                          ? const Color(0xFFE040FB)
                                          : Colors.grey.withOpacity(0.25),
                                      width: 1.2,
                                    ),
                                    boxShadow: estSelectionnee
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFFE040FB).withOpacity(0.25),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        icon,
                                        size: 18,
                                        color: estSelectionnee ? Colors.white : Colors.grey[600],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        cat,
                                        style: TextStyle(
                                          color: estSelectionnee ? Colors.white : Colors.grey[800],
                                          fontWeight: estSelectionnee ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),

              // --- BLOC 2 : ONGLETS FIXES (Pinned) ---
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(
                  child: Container(
                    color: const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                ),
              ),
            ];
          },

          // --- BLOC 3 : LE CONTENU (LISTE) ---
          body: controller.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE040FB)))
            : Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: TabBarView(
                  children: [
                    ListeRecettes(
                      recettes: controller.recettesFaisablesFiltrees,
                      estFaisable: true,
                    ),
                    ListeRecettes(
                      recettes: controller.recettesManquantesFiltrees,
                      estFaisable: false,
                    ),
                  ],
                ),
              ),

        ),
      ),
    );
  }
}

// AJOUT OBLIGATOIRE : Classe utilitaire pour les onglets collants
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyTabBarDelegate({required this.child});
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override
  double get maxExtent => 70.0;
  @override
  double get minExtent => 70.0;
  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => oldDelegate.child != child;
}