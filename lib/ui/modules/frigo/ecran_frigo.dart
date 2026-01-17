import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Variable utilisée pour le filtrage (mise à jour uniquement lors de la validation)
  String _recherche = "";
  String _categorieSelectionnee = "Tout";

  // Contrôleur pour gérer la saisie du texte sans rafraîchir l'écran
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Méthode pour valider la recherche et mettre à jour l'affichage
  void _lancerRecherche() {
    setState(() {
      _recherche = _searchController.text.trim();
    });
    // Fermer le clavier
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final alimentController = context.watch<AlimentController>();
    final frigoController = context.watch<FrigoController>();

    final List<String> categories = ["Tout", ...alimentController.categories];

    // Le filtrage se base sur _recherche (qui ne change que lors du clic sur le bouton ou si vide)
    List<Aliment> alimentsAffiches = alimentController.catalogueAliments.where((aliment) {
      final matchRecherche = aliment.nom.toLowerCase().contains(_recherche.toLowerCase());
      final catAliment = aliment.categorie.isEmpty ? "Autre" : aliment.categorie;
      final matchCategorie = _categorieSelectionnee == "Tout" ||
          catAliment.toLowerCase() == _categorieSelectionnee.toLowerCase();

      return matchRecherche && matchCategorie;
    }).toList();

    int totalItems = 0;
    for (var item in frigoController.contenuFrigo) {
      totalItems += item.quantite.toInt();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: alimentController.isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE040FB)))
            : ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // --- HEADER ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Mon Frigo",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF2D3436),
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Gérez vos ingrédients disponibles",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- CARTE RÉSUMÉ DU FRIGO (Cliquable) ---
            GestureDetector(
              onTap: () => _afficherContenuFrigo(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFFAA00FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE040FB).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.kitchen,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Contenu du frigo",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${frigoController.contenuFrigo.length} aliment${frigoController.contenuFrigo.length > 1 ? 's' : ''} • $totalItems unité${totalItems > 1 ? 's' : ''}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- BARRE DE RECHERCHE ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController, // Utilisation du controller
                textInputAction: TextInputAction.search, // Affiche le bouton "Rechercher" sur le clavier
                onSubmitted: (_) => _lancerRecherche(), // Action quand on valide au clavier
                // AJOUT : Réinitialiser si le champ est vide
                onChanged: (text) {
                  if (text.isEmpty) {
                    setState(() {
                      _recherche = "";
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "Rechercher un aliment...",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  // Bouton de validation de recherche
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFFE040FB)),
                    onPressed: _lancerRecherche,
                    tooltip: "Lancer la recherche",
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- CATÉGORIES ---
            const Text(
              "Catégories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((categorie) {
                  final isSelected = _categorieSelectionnee == categorie;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _categorieSelectionnee = categorie;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE040FB) : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xFFE040FB).withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          categorie,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // --- TITRE GRILLE ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ajouter des aliments",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE040FB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${alimentsAffiches.length} disponible${alimentsAffiches.length > 1 ? 's' : ''}",
                    style: const TextStyle(
                      color: Color(0xFFAA00FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- GRILLE D'ALIMENTS ---
            alimentsAffiches.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      "Aucun résultat",
                      style: TextStyle(color: Colors.grey[500], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: alimentsAffiches.length,
              itemBuilder: (context, index) {
                final aliment = alimentsAffiches[index];

                double quantiteTrouvee = 0;
                String uniteTrouvee = "pcs";

                try {
                  final item = frigoController.contenuFrigo
                      .firstWhere((item) => item.id_aliment == aliment.id_aliment);
                  quantiteTrouvee = item.quantite;
                  uniteTrouvee = item.unite;
                } catch (e) {}

                return TuileIngredient(
                  aliment: aliment,
                  quantiteAuFrigo: quantiteTrouvee,
                  unite: uniteTrouvee,
                  onTap: () {
                    _afficherFicheGestion(context, aliment);
                  },
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- MODALE : CONTENU DU FRIGO ---
  void _afficherContenuFrigo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Consumer2<FrigoController, AlimentController>(
              builder: (context, frigoCtrl, alimentCtrl, child) {
                final contenu = frigoCtrl.contenuFrigo;

                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      // --- HANDLE ---
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // --- HEADER ---
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE040FB), Color(0xFFAA00FF)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.kitchen, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Mon Frigo",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3436),
                                    ),
                                  ),
                                  Text(
                                    "${contenu.length} aliment${contenu.length > 1 ? 's' : ''}",
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.close, color: Colors.grey[600], size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // --- LISTE ---
                      Expanded(
                        child: contenu.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                "Votre frigo est vide",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Ajoutez des ingrédients depuis le catalogue",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                            : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: contenu.length,
                          itemBuilder: (context, index) {
                            final item = contenu[index];

                            Aliment? aliment;
                            try {
                              aliment = alimentCtrl.catalogueAliments
                                  .firstWhere((a) => a.id_aliment == item.id_aliment);
                            } catch (e) {
                              aliment = null;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[100],
                                        child: aliment != null
                                            ? Image.asset(
                                          "assets/images/aliments/${aliment.image}",
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Icon(
                                            Icons.fastfood,
                                            color: Colors.grey[400],
                                          ),
                                        )
                                            : Icon(Icons.fastfood, color: Colors.grey[400]),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // Infos
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            aliment?.nom ?? "Aliment #${item.id_aliment}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Color(0xFF2D3436),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE040FB).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  "${item.quantite.toInt()} ${item.unite}",
                                                  style: const TextStyle(
                                                    color: Color(0xFFAA00FF),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              if (aliment != null)
                                                Text(
                                                  aliment.categorie,
                                                  style: TextStyle(
                                                    color: Colors.grey[500],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Bouton éditer
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        if (aliment != null) {
                                          _afficherFicheGestion(context, aliment);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE040FB).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Color(0xFFE040FB),
                                          size: 20,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // Bouton supprimer
                                    GestureDetector(
                                      onTap: () {
                                        frigoCtrl.supprimerItem(item.id_frigo);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- MODALE : GESTION D'UN ALIMENT AVEC SAISIE MANUELLE ---
  void _afficherFicheGestion(BuildContext context, Aliment aliment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: _FicheGestionAliment(aliment: aliment),
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

// --- WIDGET STATEFUL POUR LA FICHE DE GESTION ---
class _FicheGestionAliment extends StatefulWidget {
  final Aliment aliment;

  const _FicheGestionAliment({required this.aliment});

  @override
  State<_FicheGestionAliment> createState() => _FicheGestionAlimentState();
}

class _FicheGestionAlimentState extends State<_FicheGestionAliment> {
  late TextEditingController _quantiteController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _quantiteController = TextEditingController();
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<FrigoController>(
      builder: (context, frigoCtrl, child) {
        double qte = 0;
        String unite = "pcs";

        try {
          final item = frigoCtrl.contenuFrigo
              .firstWhere((item) => item.id_aliment == widget.aliment.id_aliment);
          qte = item.quantite;
          unite = item.unite;
        } catch (e) {}

        // Mettre à jour le controller seulement si on n'est pas en train d'éditer
        if (!_isEditing) {
          _quantiteController.text = qte > 0 ? qte.toInt().toString() : "";
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header avec image et infos
                Row(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/images/aliments/${widget.aliment.image}",
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.aliment.nom,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.aliment.categorie,
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (widget.aliment.nutriscore.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getNutriscoreColor(widget.aliment.nutriscore),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Nutriscore ${widget.aliment.nutriscore.toUpperCase()}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Unité affichée
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE040FB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE040FB).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.straighten, size: 18, color: Color(0xFFAA00FF)),
                      const SizedBox(width: 8),
                      Text(
                        "Unité: $unite",
                        style: const TextStyle(
                          color: Color(0xFFAA00FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- SAISIE MANUELLE DE LA QUANTITÉ ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Quantité",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Bouton -
                          GestureDetector(
                            onTap: () {
                              double current = double.tryParse(_quantiteController.text) ?? 0;
                              if (current > 0) {
                                setState(() {
                                  _isEditing = true;
                                  _quantiteController.text = (current - 1).toInt().toString();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.remove, color: Colors.red, size: 24),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Champ de saisie
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: _quantiteController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3436),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onTap: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: "0",
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFE040FB), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Bouton +
                          GestureDetector(
                            onTap: () {
                              double current = double.tryParse(_quantiteController.text) ?? 0;
                              setState(() {
                                _isEditing = true;
                                _quantiteController.text = (current + 1).toInt().toString();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE040FB).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Color(0xFFE040FB), size: 24),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Boutons raccourcis
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildQuickButton("+5", () {
                            double current = double.tryParse(_quantiteController.text) ?? 0;
                            setState(() {
                              _isEditing = true;
                              _quantiteController.text = (current + 5).toInt().toString();
                            });
                          }),
                          _buildQuickButton("+10", () {
                            double current = double.tryParse(_quantiteController.text) ?? 0;
                            setState(() {
                              _isEditing = true;
                              _quantiteController.text = (current + 10).toInt().toString();
                            });
                          }),
                          _buildQuickButton("+50", () {
                            double current = double.tryParse(_quantiteController.text) ?? 0;
                            setState(() {
                              _isEditing = true;
                              _quantiteController.text = (current + 50).toInt().toString();
                            });
                          }),
                          _buildQuickButton("+100", () {
                            double current = double.tryParse(_quantiteController.text) ?? 0;
                            setState(() {
                              _isEditing = true;
                              _quantiteController.text = (current + 100).toInt().toString();
                            });
                          }),
                          _buildQuickButton("Vider", () {
                            setState(() {
                              _isEditing = true;
                              _quantiteController.text = "0";
                            });
                          }, isDestructive: true),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton Valider
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      double nouvelleQuantite = double.tryParse(_quantiteController.text) ?? 0;
                      frigoCtrl.definirQuantite(widget.aliment, nouvelleQuantite);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE040FB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Valider",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Bouton Annuler
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Annuler",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickButton(String label, VoidCallback onTap, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDestructive ? Colors.red.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red : const Color(0xFF2D3436),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}