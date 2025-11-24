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


  final Color _primaryPurple = const Color(0xFFE040FB);

  @override
  Widget build(BuildContext context) {
    final alimentController = context.watch<AlimentController>();
    final frigoController = context.watch<FrigoController>();

    final List<String> categoriesDisponibles = alimentController.categories;

    List<Aliment> alimentsAffiches = alimentController.catalogueAliments.where((aliment) {
      final matchRecherche = aliment.nom.toLowerCase().contains(_recherche.toLowerCase());
      final catAliment = aliment.categorie.isEmpty ? "Autre" : aliment.categorie;
      final matchCategorie = _categorieSelectionnee == "Tout" ||
          catAliment.toLowerCase() == _categorieSelectionnee.toLowerCase();
      return matchRecherche && matchCategorie;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      body: alimentController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        children: [


          Row(
            children: [
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(

                    gradient: LinearGradient(
                        colors: [_primaryPurple, const Color(0xFFD500F9)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _primaryPurple.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]
                ),
                child: const Icon(Icons.kitchen, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mon Frigo",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1D1E),
                        fontSize: 28
                    ),
                  ),
                  Text(
                    "Gérez vos ingrédients",
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 30),

          //  CARD RECHERCHE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => setState(() => _recherche = value),
                  decoration: InputDecoration(
                    hintText: "Rechercher un ingrédient...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0), borderSide: BorderSide(color: _primaryPurple)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 20),

                Text("Catégories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.grey.shade800)),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: categoriesDisponibles.map((categorie) {
                      final isSelected = _categorieSelectionnee == categorie;
                      return FilterChip(
                        label: Text(categorie),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            _categorieSelectionnee = selected ? categorie : "Tout";
                          });
                        },
                        backgroundColor: const Color(0xFFF5F6F9),

                        selectedColor: _primaryPurple,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: BorderSide.none
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          //  CARD GRILLE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ingrédients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.grey.shade800)),

                    // Bouton "Voir Frigo"
                    InkWell(
                      onTap: () => _afficherContenuFrigo(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: _primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.shopping_basket_outlined, size: 18, color: _primaryPurple),
                            const SizedBox(width: 6),
                            Builder(
                                builder: (context) {
                                  double sommeTotale = 0;
                                  for (var item in frigoController.contenuFrigo) { sommeTotale += item.quantite; }
                                  return Text(
                                    "${sommeTotale.toInt()} dans le frigo",
                                    style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.bold, fontSize: 14),
                                  );
                                }
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                alimentsAffiches.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text("Aucun résultat ")))
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75
                  ),
                  itemCount: alimentsAffiches.length,
                  itemBuilder: (context, index) {
                    final aliment = alimentsAffiches[index];
                    double quantiteTrouvee = 0;
                    try {
                      quantiteTrouvee = frigoController.contenuFrigo.firstWhere((item) => item.id_aliment == aliment.id_aliment).quantite;
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

  // MODALE DE GESTION
  void _afficherFicheGestion(BuildContext context, Aliment aliment) {
    final frigoCtrlLecture = context.read<FrigoController>();
    final alimentCtrlLecture = context.read<AlimentController>();

    final List<String> unitesPossibles = alimentCtrlLecture.getUnitesPourAliment(aliment);
    double qte = 0;
    String uniteActuelle = unitesPossibles.first;
    try {
      final item = frigoCtrlLecture.contenuFrigo.firstWhere((item) => item.id_aliment == aliment.id_aliment);
      qte = item.quantite;
      uniteActuelle = item.unite;
    } catch (e) {}
    if (!unitesPossibles.contains(uniteActuelle)) { uniteActuelle = unitesPossibles.first; }
    String uniteSelectionnee = uniteActuelle;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 80, width: 80,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.grey.shade100),
                        child: Image.asset("assets/images/${aliment.image}", fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 40, color: Colors.grey)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(aliment.nom, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(aliment.categorie, style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            if (aliment.nutriscore.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: _getNutriscoreColor(aliment.nutriscore), borderRadius: BorderRadius.circular(8)),
                                child: Text("Nutriscore ${aliment.nutriscore.toUpperCase()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: uniteSelectionnee,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            uniteSelectionnee = newValue!;
                            if (qte > 0) {
                              frigoCtrlLecture.ajouterOuMettreAJourAliment(aliment: aliment, quantiteAjoutee: 0, unite: newValue);
                            }
                          });
                        },
                        items: unitesPossibles.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Consumer<FrigoController>(
                      builder: (context, frigoCtrl, child) {
                        double currentQte = 0;
                        try {
                          currentQte = frigoCtrl.contenuFrigo.firstWhere((item) => item.id_aliment == aliment.id_aliment).quantite;
                        } catch(e){}
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(onPressed: currentQte > 0 ? () => frigoCtrl.diminuerQuantite(aliment) : null, icon: const Icon(Icons.remove), iconSize: 28, color: Colors.red),
                              Text("${currentQte.toInt()} ${uniteSelectionnee}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                              IconButton(onPressed: () => frigoCtrl.ajouterOuMettreAJourAliment(aliment: aliment, quantiteAjoutee: 1.0, unite: uniteSelectionnee), icon: const Icon(Icons.add), iconSize: 28, color: Colors.green),
                            ],
                          ),
                        );
                      }
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            // 🔥 BOUTON FUCHSIA 🔥
                              backgroundColor: _primaryPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                              elevation: 5,
                              shadowColor: _primaryPurple.withOpacity(0.4)
                          ),
                          child: const Text("Terminé", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      )
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _afficherContenuFrigo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Mon Frigo", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 28), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<FrigoController>(
                  builder: (context, frigoCtrl, child) {
                    final items = frigoCtrl.contenuFrigo;
                    final alimentCtrl = context.read<AlimentController>();
                    if (items.isEmpty) {
                      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey.shade300), const SizedBox(height: 16), const Text("Votre frigo est vide !", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600))]);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: items.length,
                      separatorBuilder: (ctx, i) => const Divider(height: 1),
                      itemBuilder: (ctx, index) {
                        final itemFrigo = items[index];
                        final aliment = alimentCtrl.catalogueAliments.firstWhere((a) => a.id_aliment == itemFrigo.id_aliment, orElse: () => Aliment(id_aliment: 0, nom: "Inconnu", categorie: "", nutriscore: "", image: "", typeGestion: "unite"));
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(width: 56, height: 56, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey.shade100), child: Image.asset("assets/images/${aliment.image}", fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.fastfood, size: 24, color: Colors.grey))),
                          title: Text(aliment.nom, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),

                          subtitle: Text("${itemFrigo.quantite.toInt()} ${itemFrigo.unite}", style: TextStyle(color: _primaryPurple, fontWeight: FontWeight.w600)),
                          trailing: IconButton(icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400), onPressed: () => frigoCtrl.supprimerItem(itemFrigo.id_frigo)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
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