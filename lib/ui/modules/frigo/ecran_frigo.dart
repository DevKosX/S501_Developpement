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
  String _recherche = "";
  String _categorieSelectionnee = "Tout";


  final List<String> _categories = [
    'Tout',
    'Légume',
    'Fruit',
    'Viande',
    'Poisson',
    'Crèmerie',
    'Épicerie',
    'Boulangerie',
    'Charcuterie',
    'Condiment',
    'Boisson'
  ];

  @override
  Widget build(BuildContext context) {
    final alimentController = context.watch<AlimentController>();
    final frigoController = context.watch<FrigoController>();

    // Filtrage
    List<Aliment> alimentsAffiches = alimentController.catalogueAliments.where((aliment) {
      final matchRecherche = aliment.nom.toLowerCase().contains(_recherche.toLowerCase());


      final catAliment = aliment.categorie.isEmpty ? "Autre" : aliment.categorie;


      final matchCategorie = _categorieSelectionnee == "Tout" ||
          catAliment.toLowerCase() == _categorieSelectionnee.toLowerCase();

      return matchRecherche && matchCategorie;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: alimentController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Mon Frigo",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),


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
                // Recherche
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

                // Catégories
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


                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                      child: Builder(
                          builder: (context) {
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

  void _afficherFicheGestion(BuildContext context, Aliment aliment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Consumer<FrigoController>(
          builder: (context, frigoCtrl, child) {

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
                  Row(
                    children: [
                      Container(
                        height: 80, width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(

                              image: AssetImage("assets/images/${aliment.image}"),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {}
                          ),
                        ),

                        child: Image.asset(
                          "assets/images/${aliment.image}",
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 40, color: Colors.grey),
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Catégorie: ${aliment.categorie}",
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(height: 8),

                            // ✅ NUTRISCORE RÉEL DEPUIS LA BDD
                            if (aliment.nutriscore.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getNutriscoreColor(aliment.nutriscore),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Nutriscore ${aliment.nutriscore.toUpperCase()}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: qte > 0
                              ? () => frigoCtrl.diminuerQuantite(aliment)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          iconSize: 32,
                          color: Colors.red,
                        ),

                        Text(
                          qte > 0 ? "${qte.toInt()}" : "0",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),

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

  Color _getNutriscoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A': return const Color(0xFF038141);
      case 'B': return const Color(0xFF85BB2F);
      case 'C': return const Color(0xFFFECB02);
      case 'D': return const Color(0xFFEE8100);
      case 'E': return const Color(0xFFE63E11);
      default: return Colors.grey;
    }
  }
}