import 'package:flutter/material.dart';

class FormulaireIMC extends StatefulWidget {
  // On renvoie maintenant 3 valeurs : Poids, Taille, et l'Objectif choisi
  final Function(double poids, double taille, String objectif) onCalculer;

  const FormulaireIMC({super.key, required this.onCalculer});

  @override
  State<FormulaireIMC> createState() => _FormulaireIMCState();
}

class _FormulaireIMCState extends State<FormulaireIMC> {
  // Clé globale pour identifier le formulaire et lancer la validation
  final _formKey = GlobalKey<FormState>();

  final _tailleController = TextEditingController();
  final _poidsController = TextEditingController();

  // Valeur par défaut du menu déroulant
  String _objectifSelectionne = "Maintien";

  // CES TEXTES DOIVENT ÊTRE IDENTIQUES À CEUX DE TON CONTROLLER
  final List<String> _listeObjectifs = [
    "Perte de poids",
    "Maintien",
    "Prise de masse",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // On enveloppe la Column dans un Form pour activer la validation
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            const Row(
              children: [
                Icon(Icons.calculate_outlined, color: Color(0xFF9C27B0), size: 28),
                SizedBox(width: 10),
                Text("Calculateur d'IMC", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // Champ Taille
            const Text("Taille (cm ou m)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tailleController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Ex: 175 ou 1.75",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Validation : obligatoire
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre taille';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Champ Poids
            const Text("Poids (kg)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _poidsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: "Ex: 70",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Validation : obligatoire
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre poids';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- MENU DÉROULANT OBJECTIF ---
            const Text("Mon Objectif", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _objectifSelectionne,
                  isExpanded: true,
                  items: _listeObjectifs.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _objectifSelectionne = newValue!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bouton
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // On vérifie si les champs sont valides avant de continuer
                  if (_formKey.currentState!.validate()) {
                    final taille = double.tryParse(_tailleController.text.replaceAll(',', '.')) ?? 0.0;
                    final poids = double.tryParse(_poidsController.text.replaceAll(',', '.')) ?? 0.0;
                    
                    // On envoie les 3 infos au parent
                    widget.onCalculer(poids, taille, _objectifSelectionne);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.calculate),
                label: const Text("Calculer mon IMC"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


















































// import 'package:flutter/material.dart';

// class FormulaireIMC extends StatefulWidget {
//   // Fonction pour renvoyer les données au parent quand on clique sur Calculer
//   final Function(double poids, double taille) onCalculer;

//   const FormulaireIMC({super.key, required this.onCalculer});

//   @override
//   State<FormulaireIMC> createState() => _FormulaireIMCState();
// }

// class _FormulaireIMCState extends State<FormulaireIMC> {
//   final TextEditingController _tailleController = TextEditingController();
//   final TextEditingController _poidsController = TextEditingController();

//   @override
//   void dispose() {
//     _tailleController.dispose();
//     _poidsController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // En-tête du formulaire
//           const Row(
//             children: [
//               Icon(Icons.calculate_outlined, color: Color(0xFF9C27B0), size: 28),
//               SizedBox(width: 10),
//               Text(
//                 "Calculateur d'IMC",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),

//           // Champ Taille
//           const Text("Taille (cm)", style: TextStyle(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _tailleController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               hintText: "Ex: 175",
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Champ Poids
//           const Text("Poids (kg)", style: TextStyle(fontWeight: FontWeight.w600)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: _poidsController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               hintText: "Ex: 70",
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Colors.grey.shade300),
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // Bouton Calculer
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 // Conversion simple des textes en nombres
//                 // On remplace la virgule par un point au cas où l'utilisateur utilise ","
//                 final double taille = double.tryParse(_tailleController.text.replaceAll(',', '.')) ?? 0.0;
//                 final double poids = double.tryParse(_poidsController.text.replaceAll(',', '.')) ?? 0.0;
                
//                 widget.onCalculer(poids, taille);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey.shade200, // Gris clair comme sur la maquette
//                 foregroundColor: Colors.grey.shade800, // Texte foncé
//                 elevation: 0,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               icon: const Icon(Icons.touch_app, size: 20),
//               label: const Text(
//                 "Calculer mon IMC",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }