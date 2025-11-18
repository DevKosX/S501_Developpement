import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/aliment_controller.dart';
import '../../../core/controllers/frigo_controller.dart';
import '../../../core/models/aliment_model.dart';
import 'package:s501_developpement/ui/modules/frigo/widgets/tuile_ingredient.dart';
class EcranFrigo extends StatefulWidget {
  const EcranFrigo({super.key});

  @override
  State<EcranFrigo> createState() => _EcranFrigoState();
}

class _EcranFrigoState extends State<EcranFrigo> {
  // --- VARIABLES D'ÉTAT ---
  String _recherche = "";
  String _categorieSelectionnee = "Tout";

  // Liste des catégories
  final List<String> _categories = ['Tout', 'Légume', 'Fruit', 'Viande', 'Épices', 'Produit laitier', 'Autre'];

  @override
  Widget build(BuildContext context) {
    final alimentController = context.watch<AlimentController>();
    // On écoute le FrigoController pour mettre à jour le Total et les badges
    final frigoController = context.watch<FrigoController>();

    // --- FILTRAGE DE LA LISTE ---
    List<Aliment> alimentsAffiches = alimentController.catalogueAliments.where((aliment) {
      final matchRecherche = aliment.nom.toLowerCase().contains(_recherche.toLowerCase());
      // Gestion du cas où la catégorie est vide ou nulle
      final catAliment = (aliment.categorie.isEmpty) ? "Autre" : aliment.categorie;

      final matchCategorie = _categorieSelectionnee == "Tout" ||
          catAliment.toLowerCase().contains(_categorieSelectionnee.toLowerCase());

      return matchRecherche && matchCategorie;
    }).toList();


    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: alimentController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- TITRE ---
          Text(
            "Mon Frigo",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // --- CARD 1 : RECHERCHE & FILTRES ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche
                TextField(
                  onChanged: (value) => setState(() => _recherche = value),
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "Catégories",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // Filtres (Wrap pour le retour à la ligne)
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _categories.map((categorie) {
                      final isSelected = _categorieSelectionnee == categorie;
                      return FilterChip(
                        label: Text(categorie),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            _categorieSelectionnee = categorie;
                          });
                        },
                        backgroundColor: Colors.grey.shade50,
                        selectedColor: Colors.green.shade100,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.green.shade900 : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? Colors.green : Colors.grey.shade300),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- CARD 2 : GRILLE D'AJOUT ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ajouter (${alimentsAffiches.length})",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    // --- CALCUL ET AFFICHAGE DU TOTAL ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Builder(
                          builder: (context) {
                            // Calcul mathématique de la somme des quantités
                            double sommeTotale = 0;
                            for (var item in frigoController.contenuFrigo) {
                              sommeTotale += item.quantite;
                            }

                            return Text(
                              "Total: ${sommeTotale.toInt()}",
                              style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, fontSize: 12),
                            );
                          }
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 16),

                alimentsAffiches.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text("Aucun résultat 🥕")))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: alimentsAffiches.length,
                  itemBuilder: (context, index) {
                    final aliment = alimentsAffiches[index];

                    // Recherche de la quantité pour le badge (x1, x2...)
                    double quantiteTrouvee = 0;
                    try {
                      quantiteTrouvee = frigoController.contenuFrigo
                          .firstWhere((item) => item.id_aliment == aliment.id_aliment)
                          .quantite;
                    } catch (e) {}

                    return TuileIngredient(
                      aliment: aliment,
                      quantiteAuFrigo: quantiteTrouvee,
                      onTap: () {
                        _afficherFicheGestion(context, aliment);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// --- FONCTION POUR AFFICHER LE PANNEAU DE GESTION ---
  void _afficherFicheGestion(BuildContext context, Aliment aliment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        // Utilisation de Consumer pour mettre à jour le chiffre en temps réel dans le panneau
        return Consumer<FrigoController>(
          builder: (context, frigoCtrl, child) {

            // Recherche de la quantité actuelle
            double qte = 0;
            try {
              qte = frigoCtrl.contenuFrigo
                  .firstWhere((item) => item.id_aliment == aliment.id_aliment)
                  .quantite;
            } catch (e) {}

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image et Nom
                  Row(
                    children: [
                      Container(
                        height: 60, width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(aliment.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              aliment.nom,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Catégorie: ${aliment.categorie}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Compteur + / -
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // BOUTON MOINS
                        IconButton(
                          onPressed: qte > 0
                              ? () => frigoCtrl.diminuerQuantite(aliment)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 32,
                          color: Colors.red,
                        ),

                        // QUANTITÉ AU CENTRE
                        Text(
                          qte > 0 ? "${qte.toInt()}" : "0",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),

                        // BOUTON PLUS
                        IconButton(
                          onPressed: () => frigoCtrl.ajouterAlimentDuCatalogue(aliment),
                          icon: const Icon(Icons.add_circle),
                          iconSize: 32,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bouton Terminé
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Terminé", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}