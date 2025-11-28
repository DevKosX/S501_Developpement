import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/controllers/feedback_recette_controller.dart';
import '../../../core/models/feedback_recette_model.dart';
import '../../../core/models/recette_model.dart';
import '../recettes/ecran_detail_recette.dart';

class EcranFavoris extends StatefulWidget {
  const EcranFavoris({super.key});

  @override
  State<EcranFavoris> createState() => _EcranFavorisState();
}

class _EcranFavorisState extends State<EcranFavoris> {
  List<Map<String, dynamic>> _recettesFavorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerFavoris();
  }

  Future<void> _chargerFavoris() async {
    setState(() => _isLoading = true);
    try {
      final controller = Provider.of<FeedbackRecetteController>(context, listen: false);
      final favoris = await controller.getFavorisAvecDetails();
      setState(() {
        _recettesFavorites = favoris;
        _isLoading = false;
      });
    } catch (e) {
      print("Erreur lors du chargement des favoris: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavori(int idRecette) async {
    final controller = Provider.of<FeedbackRecetteController>(context, listen: false);
    final feedback = FeedbackRecette(idrecette: idRecette, favori: 1, note: 0);
    await controller.toggleFavori(feedback);
    await _chargerFavoris();
  }

  String _formatTemps(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final heures = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${heures}h ${mins}min' : '${heures}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.withOpacity(0.8),
                          Colors.pink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mes Favoris',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Vos recettes préférées',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenu
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recettesFavorites.isEmpty
                      ? _buildEmptyState()
                      : _buildListeFavoris(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune recette favorite',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des recettes à vos favoris\nen appuyant sur le cœur',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeFavoris() {
    return RefreshIndicator(
      onRefresh: _chargerFavoris,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Compteur
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${_recettesFavorites.length} recette${_recettesFavorites.length > 1 ? 's' : ''} favorite${_recettesFavorites.length > 1 ? 's' : ''}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),

          // Liste des recettes
          ..._recettesFavorites.map((recetteData) {
            return _buildRecetteCard(recetteData);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecetteCard(Map<String, dynamic> recetteData) {
    final idRecette = recetteData['id_recette'] as int;
    final titre = recetteData['titre'] as String? ?? 'Sans titre';
    final image = recetteData['image'] as String? ?? '';
    final typeRecette = recetteData['type_recette'] as String? ?? 'Autre';
    final tempsPreparation = recetteData['temps_preparation'] as int? ?? 0;
    final difficulte = recetteData['difficulte'] as String? ?? 'Moyenne';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image avec badge et favori
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: image.isNotEmpty
                    ? Image.asset(
                        image,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.restaurant,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      ),
              ),

              // Badge type de recette
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    typeRecette,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),

              // Bouton favori
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => _toggleFavori(idRecette),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Détails
                Row(
                  children: [
                    // Temps
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTemps(tempsPreparation),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Difficulté
                    Icon(
                      Icons.signal_cellular_alt,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      difficulte,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Personnes (exemple fixe, peut être ajouté au modèle)
                    Icon(
                      Icons.people,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4 pers.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Bouton
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Créer un objet Recette à partir des données
                      final recette = Recette(
                        id_recette: recetteData['id_recette'] as int,
                        titre: recetteData['titre'] as String? ?? 'Sans titre',
                        instructions: recetteData['instructions'] as String? ?? '',
                        tempsPreparation: recetteData['temps_preparation'] as int? ?? 0,
                        typeRecette: recetteData['type_recette'] as String? ?? 'Autre',
                        score: (recetteData['score'] is int)
                            ? (recetteData['score'] as int).toDouble()
                            : (recetteData['score'] as double? ?? 0.0),
                        noteBase: recetteData['note_base'] as int? ?? 0,
                        image: recetteData['image'] as String? ?? '',
                        difficulte: recetteData['difficulte'] as String? ?? 'Moyenne',
                      );

                      // Navigation vers le détail de la recette
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EcranDetailRecette(recette: recette),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Voir la recette',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
