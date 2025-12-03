# Application de Recommandation de Recettes

Application mobile Flutter de recommandation adaptative de recettes et de gestion de frigo, fonctionnant entierement hors-ligne.

---

## Table des matieres

1. [Contexte du Projet](#contexte-du-projet)
2. [Fonctionnalites](#fonctionnalites)
3. [Systeme de Recommandation](#systeme-de-recommandation)
4. [Installation](#installation)
5. [Utilisation](#utilisation)
6. [Technologies Utilisees](#technologies-utilisees)

---

## Contexte du Projet

### Cadre Academique

Ce projet est realise dans le cadre de la **SAE BUT3 5.Real.01 - Developpement avance** a l'IUT Villetaneuse, Universite Sorbonne Paris Nord.

L'objectif est de concevoir une **application mobile de recommandation adaptative independante**, c'est-a-dire fonctionnant entierement sur le smartphone de l'utilisateur, sans necessiter de connexion a un serveur distant.

### Problematique

Les applications de recommandation actuelles (TikTok, Netflix, Instagram) reposent sur des serveurs distants qui collectent et traitent les donnees des utilisateurs. Cette approche pose plusieurs problemes :

- **Confidentialite** : Les donnees d'utilisation sont stockees sur des serveurs tiers
- **Dependance** : L'application necessite une connexion internet permanente
- **Souverainete** : L'utilisateur n'a pas le controle total sur ses donnees

### Notre Solution

Notre application repond a ces enjeux en proposant :

1. **Recommandation locale** : Tous les calculs de recommandation sont effectues directement sur le smartphone
2. **Donnees isolees** : Les traces d'utilisation restent sur l'appareil de l'utilisateur
3. **Fonctionnement hors-ligne** : Aucune connexion internet n'est requise

### Thematique Choisie

Nous avons choisi la thematique de la **gestion culinaire** car elle repond a des besoins concrets :

- **Gaspillage alimentaire** : Selon l'ADEME, chaque Francais jette en moyenne 30 kg de nourriture par an
- **Manque d'inspiration** : Difficulte quotidienne a trouver des idees de repas
- **Alimentation equilibree** : Besoin de suivre ses apports nutritionnels
- **Courses inefficaces** : Achats en double par manque de visibilite sur le contenu du frigo

---

## Fonctionnalites

### Module Frigo

| Fonctionnalite | Description |
|----------------|-------------|
| Catalogue d'aliments | Plus de 90 aliments disponibles avec et informations nutritionnelles |
| Gestion des quantites | Ajout, modification et suppression avec saisie manuelle ou boutons rapides |
| Unites intelligentes | Recuperation automatique des unites depuis les recettes (g, ml, pcs...) |
| Categories dynamiques | Filtrage par categorie recupere dynamiquement depuis la base de donnees |
| Vue d'ensemble | Visualisation complete du contenu du frigo via une modale dediee |
| Recherche instantanee | Recherche en temps reel dans le catalogue d'aliments |

### Module Recettes

| Fonctionnalite | Description |
|----------------|-------------|
| Catalogue complet | Centaines d'aliment organisees par categories |
| Filtre avancee | Recette cuisinable et non cuisinable |
| Fiche recette detaillee | Ingredients, etapes de preparation, informations nutritionnelles |
| Verification des ingredients | Indication des ingredients disponibles dans le frigo |

### Module Recommandation

| Fonctionnalite | Description |
|----------------|-------------|
| Suggestions personnalisees | Recommandations basees sur le contenu du frigo |
| Adaptation continue | Evolution des suggestions en fonction de l'utilisation |
| Historique des preferences | Prise en compte des recettes realisees et mise en favoris |
| Score de faisabilite | Nombre d'ingredients manquant pour chaque recette |

### Informations Nutritionnelles

| Fonctionnalite | Description |
|----------------|-------------|
| Nutriscore | Affichage du score nutritionnel (A a E) avec code couleur |
| Aide a la decision | Informations pour des choix alimentaires eclaires |

---

## Systeme de Recommandation

### Strategie de Recommandation

Notre algorithme de recommandation repose sur plusieurs criteres :

1. **Disponibilite des ingredients** : Priorisation des recettes realisables avec le contenu actuel du frigo
2. **Historique d'utilisation** : Prise en compte des recettes deja consultees ou realisees
3. **Preferences implicites** : Analyse des categories de recettes les plus réalisés


### Representation des Donnees

Les donnees sont representees sous forme relationnelle dans une base SQLite locale, permettant :

- Des requetes rapides et efficaces
- Une faible consommation de ressources
- Un fonctionnement entierement hors-ligne

### Adaptation Continue

La recommandation evolue au fur et a mesure de l'utilisation :


- Les ajouts/suppressions du frigo influencent les suggestions
- Les preferences de categories sont mises a jour dynamiquement

---


### Pattern Architectural

L'application suit une architecture **Clean Architecture** avec le pattern **Repository** :

- **Presentation** : Ecrans, widgets et modales (Flutter)
- **Domaine** : Controllers (gestion d'etat avec Provider) et Repositories (abstraction)
- **Donnees** : Implementation des repositories et service de base de donnees (SQLite)

Cette separation permet :

- Une meilleure testabilite du code
- Une maintenance facilitee
- Une evolution independante de chaque couche

---

## Installation

### Prerequis

| Outil | Version minimale | Verification |
|-------|------------------|--------------|
| Flutter | 3.16.0+ | `flutter --version` |
| Dart | 3.2.0+ | `dart --version` |
| Android Studio | 2023.1+ | - |
| Git | 2.0+ | `git --version` |

### Cloner le Projet

```
git clone https://github.com/DevKosX/S501_Developpement.git
cd S501_Developpement
flutter pub get
```

### Lancer l'Application

**Mode debug :**
```
flutter run
```

**Mode release (optimise) :**
```
flutter run --release
```

### Build de Production

**Android APK :**
```
flutter build apk --release
```

**Android App Bundle (Google Play) :**
```
flutter build appbundle --release
```

---

## Utilisation

### Navigation Principale

L'application dispose d'une barre de navigation avec 6 onglets :

| Onglet | Description |
|--------|-------------|
| Accueil | Dashboard avec suggestions et resume du frigo |
| Recettes | Catalogue de recettes avec filtres et recherche |
| Frigo | Gestion du contenu du frigo |
| Favoris | Gestion des favoris |
| Historique | Gestion de l'historique |
| Profil | Parametres et preferences utilisateur |

### Guide du Module Accueil

**Consulter l'accueil :**
- Voir les 5 recettes avec le score le plus élever 



### Guide du Module Frigo

**Voir le contenu du frigo :**
- Cliquer sur la carte de resume en haut de l'ecran
- Une modale s'ouvre avec la liste complete des aliments

**Ajouter un aliment :**
1. Rechercher l'aliment dans la barre de recherche ou filtrer par categorie
2. Cliquer sur l'aliment souhaite
3. Entrer la quantite (saisie manuelle ou boutons +5, +10, +50, +100)
4. Valider

**Modifier une quantite :**
- Depuis la grille : cliquer sur un aliment deja present (bordure violette)
- Depuis la modale : cliquer sur l'icone editer
- Utiliser "Vider" pour supprimer l'aliment

**Affichage des quantites :**

| Type d'unite | Affichage | Exemple |
|--------------|-----------|---------|
| Comptage (pcs, piece) | x3 | x3 oeufs |
| Masse (g, kg) | 100g | 100g farine |
| Volume (ml, L, cl) | 500ml | 500ml lait |

### Guide du Module Recettes

**Parcourir les recettes :**
- Faire defiler pour decouvrir les recettes
- Utiliser la barre de recherche

**Consulter une recette :**
1. Cliquer sur une carte recette
2. Consulter les informations : temps, difficulte, portions
3. Voir la liste des ingredients avec quantites
4. Suivre les etapes de preparation

**Verification des ingredients :**
- Les ingredients presents dans le frigo sont mis en evidence
- Un indicateur montre le Nombre d'ingredients manquants

### Guide du Module Historique

**Parcourir l'historique :**
- Consulter les recettes qui ont était effectuer par l'utilisateurs

### Guide du Module Favoris

**Parcourir les favoris :**
- Consulter les recettes qui ont était mise en favoris

### Guide du Module Profil

**Suivre les recommandations de santé :**
- Calcule l'IMC
- Donne des conseils par rapport à la valeur et a l'objectif 
---

## Technologies Utilisees

### Stack Technique

| Technologie | Utilisation |
|-------------|-------------|
| Flutter | Framework UI cross-platform |
| Dart | Langage de programmation |
| SQLite (sqflite) | Base de donnees locale |
| Provider | Gestion d'etat reactive |

### Outils de Developpement

| Outil | Utilisation |
|-------|-------------|
| Android Studio | IDE principal |
| VS Code | Editeur alternatif |
| Git / GitHub | Versioning et collaboration |
| DB Browser for SQLite | Gestion de la base de donnees |

### Justification des Choix Techniques

**Flutter** a ete choisi pour :
- Le developpement cross-platform (Android et iOS avec un seul code)
- Les performances natives grace a la compilation AOT
- L'ecosysteme riche de packages

**SQLite** a ete choisi pour :
- Le fonctionnement entierement hors-ligne
- La legerete et les performances sur mobile
- La compatibilite native avec Flutter via sqflite

**Provider** a ete choisi pour :
- La simplicite d'implementation
- L'integration native avec Flutter
- La reactivite de l'interface

---




