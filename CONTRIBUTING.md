# Guide de Contribution - SahelArt

## Table des matières

1. [Introduction](#introduction)
2. [Équipe & Responsabilités](#équipe--responsabilités)
3. [Prérequis](#prérequis)
4. [Configuration du projet](#configuration-du-projet)
5. [Workflow de contribution](#workflow-de-contribution)
6. [Standards de code](#standards-de-code)
7. [Conventions de commits](#conventions-de-commits)
8. [Conventions de branches](#conventions-de-branches)
9. [Process de Pull Request](#process-de-pull-request)
10. [Code Review](#code-review)
11. [Tests](#tests)
12. [Documentation](#documentation)
13. [Résolution de problèmes](#résolution-de-problèmes)

---

## Introduction

Ce document définit les pratiques de collaboration pour l'équipe de développement SahelArt.

**Principe fondamental** : Nous suivons une approche Contract-First. Le code implémente le contrat système défini dans `docs/sahel_art_system_contract_and_invariants.md`.

---

## Équipe & Responsabilités

**Backend** :
- **the-y4nn** : Node.js/Express, MongoDB, API REST
- Responsable de : Routes, Controllers, Services, Repositories, Models
- Dossier principal : `backend/`

**Frontend** :
- **Mourina** : Flutter (Web + Mobile)
- **Eliezer** : Flutter (Web + Mobile)
- Responsables de : UI, State Management (Provider), Repositories, API integration
- Dossier principal : `frontend/`

**Workflow** : Collaboration directe sur le repository principal avec branches (pas de fork).

### Coordination Backend-Frontend

**Contrat API** : Le fichier `docs/API.md` définit le contrat entre backend et frontend.

**Règles de collaboration** :
1. **Backend** : Implémente l'API selon `docs/API.md`
2. **Frontend** : Consomme l'API selon `docs/API.md`
3. Tout changement d'API doit être discuté et documenté AVANT l'implémentation
4. Les endpoints doivent être testés avec Postman avant intégration frontend
5. Communication via issues GitHub ou discussions d'équipe

**Process de développement** :
```
1. Backend crée l'endpoint selon docs/API.md
2. Backend teste avec Postman (ou équivalent)
3. Backend ouvre une PR vers develop (intégration sur develop)
4. Frontend consomme l'endpoint depuis develop
5. Frontend teste l'intégration sur develop
6. Frontend ouvre une PR vers develop et vérifie les conflits
```

---

## Prérequis

### Compétences requises

**Backend** :
- Node.js / TypeScript
- Express.js
- MongoDB / Mongoose
- REST API design
- JWT authentication

**Frontend** :
- Flutter / Dart
- Provider state management
- REST API consumption
- Responsive design

### Outils nécessaires

```bash
# Backend
- Node.js 20.x LTS
- npm ou yarn
- MongoDB 7.x
- Git

# Frontend
- Flutter SDK 3.27+
- Dart SDK
- Android Studio (pour mobile Android)
- Xcode (pour mobile iOS, macOS uniquement)

# Communs
- Git
- Un IDE (VS Code recommandé)
- Postman ou similar (pour tester l'API)
```

---

## Configuration du projet

### 1. Clone du repository

```bash
# 1. Cloner le repository principal
git clone https://github.com/the-y4nn/SahelArt-Market.git
cd SahelArt-Market

# 2. Vérifier le remote
git remote -v
# Devrait afficher :
# origin  https://github.com/the-y4nn/SahelArt-Market.git (fetch)
# origin  https://github.com/the-y4nn/SahelArt-Market.git (push)
```

**Note** : Tout le monde travaille directement sur le repository principal avec des branches.

### 2. Configuration Backend

```bash
cd backend

# Installer les dépendances
npm install

# Copier le fichier d'environnement
cp .env.example .env

# Modifier .env avec vos paramètres locaux
nano .env  # ou vim, code, etc.
```

**Configuration MongoDB locale (Docker)** :

```bash
# Démarrer MongoDB avec Docker
docker run -d \
  --name sahelart-mongo \
  -p 27017:27017 \
  -v sahelart-data:/data/db \
  mongo:7

# Vérifier que MongoDB fonctionne
docker ps | grep sahelart-mongo
```

**Démarrer le backend** :

```bash
# Mode développement (avec hot reload)
npm run dev

# Le serveur devrait démarrer sur http://localhost:3000
```

### 3. Configuration Frontend

```bash
cd frontend

# Vérifier l'installation Flutter
flutter doctor

# Installer les dépendances
flutter pub get

# Générer les fichiers de sérialisation JSON
flutter pub run build_runner build --delete-conflicting-outputs

# Lancer l'application (web)
flutter run -d chrome

# Ou pour mobile (avec émulateur/device connecté)
flutter run
```

### 4. Vérification de l'installation

**Backend** :
```bash
# Tester un endpoint
curl http://localhost:3000/api/health

# Devrait retourner : {"status": "ok"}
```

**Frontend** :
```bash
# Vérifier qu'aucune erreur n'apparaît au démarrage
# L'app devrait se lancer sans erreur de compilation
```

---

## Workflow de contribution

### Vue d'ensemble du workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW COMPLET                         │
└─────────────────────────────────────────────────────────────┘

1. Repository Principal
   ├─ main (production, protégée)
   └─ develop (intégration, créée depuis main)

2. Vous créez une issue (optionnel mais recommandé)
   └─ Décrivez le bug ou la feature

3. Vous synchronisez votre branche develop locale
   └─ git checkout develop && git pull origin develop

4. Vous créez une branche depuis develop
   └─ git checkout -b backend/nom-de-la-feature
   └─ git checkout -b frontend/nom-de-la-feature

5. Vous développez et committez
   └─ git commit -m "feat: description"

6. Vous pushez sur origin
   └─ git push origin backend/nom-de-la-feature

7. Vous créez une Pull Request
   └─ De origin/backend/... vers origin/develop

8. Code Review par l'équipe
   └─ Modifications si demandées

9. Merge dans origin/develop
   └─ Branche automatiquement supprimée

10. Release
    └─ PR de develop vers main après validation
```

### Workflow détaillé étape par étape

#### Étape 1 : Créer ou choisir une issue

**Avant de coder, toujours créer/choisir une issue** :

```bash
# Sur GitHub, aller dans l'onglet "Issues"
# Cliquer sur "New Issue"
```

**Template d'issue pour une feature** :

```markdown
## Description
Ajout de la fonctionnalité de filtrage des produits par catégorie.

## User Story
En tant que client, je veux filtrer les produits par catégorie pour trouver rapidement ce que je cherche.

## Acceptance Criteria
- [ ] Dropdown de sélection de catégorie dans la page produits
- [ ] Filtrage côté backend avec query param `?category=xyz`
- [ ] Mise à jour en temps réel de la liste des produits
- [ ] Conservation du filtre lors de la pagination

## Technical Notes
- Modifier `ProductRepository.getProducts()` pour accepter `category`
- Ajouter query param dans `product.routes.ts`
- Créer widget `CategoryFilter` dans frontend

## Invariants concernés
INV-3 : Les totaux de commande doivent rester corrects après filtrage
```

**Template d'issue pour un bug** :

```markdown
## Description
Le stock d'un produit peut devenir négatif lors de commandes simultanées.

## Steps to Reproduce
1. Créer un produit avec stock = 1
2. Ouvrir 2 navigateurs
3. Ajouter le produit au panier dans les 2 navigateurs
4. Valider les 2 commandes en même temps

## Expected Behavior
Une seule commande devrait réussir, l'autre devrait recevoir une erreur 409.

## Actual Behavior
Les 2 commandes sont créées, stock = -1

## Invariant Violated
INV-1 : Stock MUST NOT be negative
INV-4 : Stock reservation MUST be atomic

## Proposed Solution
Utiliser une transaction MongoDB pour l'opération de création de commande.
```

#### Étape 2 : Synchroniser avec develop

**TOUJOURS synchroniser avant de créer une branche** :

```bash
# Se placer sur develop
git checkout develop

# Récupérer et fusionner les derniers changements
git pull origin develop
```

**Pourquoi ?**
- Éviter les conflits de merge plus tard
- Travailler sur la version la plus récente du code partagée par l'équipe

#### Étape 3 : Créer une branche

```bash
# Créer et basculer sur une nouvelle branche
git checkout -b backend/filter-products-by-category

# OU côté frontend
git checkout -b frontend/filter-products-by-category

# Vérifier que vous êtes sur la bonne branche
git branch
# * backend/filter-products-by-category
#   develop
```

**Convention de nommage** (voir section dédiée) :
- `backend/description-courte`
- `frontend/description-courte`
- `hotfix/description`

#### Étape 4 : Développer

**Workflow de développement** :

```bash
# 1. Écrire le code

# 2. Tester localement
npm test                    # Backend
flutter test                # Frontend

# 3. Vérifier que les invariants sont respectés
npm run test:invariants     # Si disponible

# 4. Vérifier le linting
npm run lint                # Backend
flutter analyze             # Frontend

# 5. Formatter le code
npm run format              # Backend
flutter format .            # Frontend
```

**Règles importantes** :
- Ne JAMAIS coder sans avoir lu les docs d'architecture
- Toujours vérifier les invariants du système
- Tester avant de committer
- Committer fréquemment (petits commits atomiques)

#### Étape 5 : Committer

```bash
# Voir les fichiers modifiés
git status

# Ajouter les fichiers au staging
git add backend/src/services/order.service.ts
git add backend/src/middleware/invariants.ts

# Committer avec un message conventionnel
git commit -m "feat(backend): add atomic stock reservation

- Implement MongoDB transaction for order creation
- Enforce INV-1 and INV-4 invariants
- Add test for concurrent order scenarios

Resolves #42"
```

**Anatomie d'un bon commit** :

```
<type>(<scope>): <subject>
                   |
                   +-> Résumé en impératif présent (max 50 chars)

<body>            |
                  +-> Description détaillée (optionnelle)
                      - Bullet points pour les changements
                      - Expliquer le "pourquoi", pas le "quoi"

<footer>          |
                  +-> Références (issues, breaking changes)
```

#### Étape 6 : Pousser sur origin

```bash
# Pousser la branche sur origin (le repository principal)
git push origin backend/filter-products-by-category

# Si c'est votre premier push de cette branche (configure le tracking)
git push -u origin backend/filter-products-by-category
```

**Note** : Ne JAMAIS push directement sur `main` (branche protégée). Toujours passer par une branche et une Pull Request.

#### Étape 7 : Créer une Pull Request

**Sur GitHub** :

1. Aller sur le repository : `https://github.com/the-y4nn/SahelArt-Market`
2. GitHub affichera un bandeau : "Compare & pull request" → cliquer
3. Vérifier les branches :
   - **Base branch** : `develop`
   - **Compare branch** : `backend/filter-products-by-category`

4. Remplir le template de PR :

```markdown
## Description
Ajout du filtrage des produits par catégorie dans la liste des produits.

## Type de changement
- [x] Feature (nouvelle fonctionnalité)
- [ ] Bugfix (correction de bug)
- [ ] Refactoring (pas de changement de comportement)
- [ ] Documentation

## Issue liée
Resolves #42

## Changements effectués
- Ajout du paramètre `category` dans `ProductRepository.getProducts()`
- Création du widget `CategoryFilterDropdown`
- Ajout de tests unitaires pour le filtrage
- Mise à jour de la documentation API

## Checklist
- [x] Le code compile sans erreur
- [x] Les tests passent (`npm test` / `flutter test`)
- [x] Le code est formaté (`npm run format` / `flutter format`)
- [x] Aucun warning de lint
- [x] Les invariants sont respectés
- [x] La documentation est à jour
- [x] Les commits suivent la convention

## Screenshots (si UI)
![Filtrage par catégorie](./screenshots/category-filter.png)

## Tests effectués
- [x] Filtrage par catégorie "Poterie"
- [x] Filtrage par catégorie "Textile"
- [x] Suppression du filtre (afficher tout)
- [x] Pagination avec filtre actif
- [x] Combinaison filtre catégorie + recherche texte

## Impact sur les invariants
Aucun impact. Cette feature est en lecture seule (GET).

## Notes pour les reviewers
J'ai ajouté un index sur `categoryId` dans MongoDB pour optimiser les queries.
```

5. Cliquer sur "Create pull request"

#### Étape 8 : Code Review

**En tant qu'auteur de la PR** :

1. **Attendre le review** : Un ou plusieurs reviewers vont examiner votre code
2. **Répondre aux commentaires** :
   ```markdown
   > Pourquoi utiliser `findOne` ici au lieu de `findById` ?

   Bonne question ! `findOne` permet de filtrer aussi par `status`,
   ce qui évite une requête supplémentaire. J'ai ajouté un commentaire
   pour clarifier.
   ```

3. **Appliquer les modifications demandées** :
   ```bash
   # Faire les changements
   git add .
   git commit -m "refactor: use findById for clarity"
   git push origin backend/filter-products-by-category

   # La PR se met à jour automatiquement
   ```

4. **Re-request review** : Sur GitHub, cliquer sur "Re-request review" après les modifications

**En tant que reviewer** (voir section Code Review)

#### Étape 9 : Merge

**Une fois approuvée** :

1. Un mainteneur du projet mergera la PR dans `develop`
2. La branche sera automatiquement supprimée sur GitHub
3. Vous recevrez une notification

**Après le merge** :

```bash
# Retourner sur develop
git checkout develop

# Synchroniser avec origin
git pull origin develop

# Supprimer votre branche locale (la branche remote est déjà supprimée par GitHub)
git branch -d feature/filter-products-by-category
```

---

## Standards de code

### Backend (Node.js / TypeScript)

#### Structure de fichier

```typescript
// 1. Imports externes
import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';

// 2. Imports internes (ordre alphabétique)
import { ApiError } from '../utils/ApiError';
import { Order } from '../models/Order';
import { Product } from '../models/Product';

// 3. Types / Interfaces
interface CreateOrderDTO {
  customerId: string;
  items: OrderItemDTO[];
}

// 4. Constantes
const MAX_ORDER_ITEMS = 50;

// 5. Classe / Fonctions principales
export class OrderService {
  // ...
}

// 6. Exports
```

#### Conventions de nommage

```typescript
// Classes : PascalCase
class OrderService {}

// Interfaces : PascalCase avec préfixe "I"
interface IOrder {}

// Types : PascalCase
type OrderStatus = 'Pending' | 'Paid';

// Fonctions / Méthodes : camelCase
function createOrder() {}

// Variables : camelCase
const orderTotal = 1000;

// Constantes : UPPER_SNAKE_CASE
const MAX_FILE_SIZE = 5 * 1024 * 1024;

// Privées (class) : préfixe "_"
private _repository: OrderRepository;

// Fichiers : kebab-case
// order-service.ts, auth-middleware.ts
```

#### Règles TypeScript

```typescript
// Toujours typer les paramètres et retours
function calculateTotal(items: OrderItem[]): number {
  return items.reduce((sum, item) => sum + item.subtotal, 0);
}

// Utiliser des types stricts (pas "any")
// MAUVAIS
function process(data: any) { }

// BON
function process(data: OrderDTO) { }

// Préférer les interfaces pour les objets
interface Product {
  id: string;
  name: string;
  price: number;
}

// Préférer les types pour les unions/alias
type OrderStatus = 'Pending' | 'Paid' | 'Shipped';

// Utiliser readonly quand approprié
interface Config {
  readonly apiUrl: string;
}
```

#### Gestion d'erreurs

```typescript
// Utiliser ApiError pour les erreurs métier
if (product.stock < quantity) {
  throw new ApiError(409, 'INV-1 violated: Insufficient stock');
}

// Try/catch pour les opérations async
try {
  await orderRepository.create(order);
} catch (error) {
  if (error instanceof ApiError) {
    throw error; // Re-throw les erreurs métier
  }
  // Logger les erreurs inattendues
  logger.error('Unexpected error in createOrder', error);
  throw new ApiError(500, 'Internal server error');
}
```

#### Documentation

```typescript
/**
 * Create a new order with atomic stock reservation
 *
 * This method enforces the following invariants:
 * - INV-1: Stock must not go negative
 * - INV-2: Order must contain at least 1 product
 * - INV-3: Order total must equal sum of subtotals
 * - INV-4: Stock reservation must be atomic
 *
 * @param data - Order creation data
 * @returns Created order with payment record
 * @throws {ApiError} 409 if stock insufficient or invariant violated
 * @throws {ApiError} 404 if product not found
 */
async createOrder(data: CreateOrderDTO): Promise<IOrder> {
  // Implementation
}
```

### Frontend (Flutter / Dart)

#### Structure de fichier

```dart
// 1. Imports Flutter/Dart
import 'package:flutter/material.dart';

// 2. Imports packages externes (ordre alphabétique)
import 'package:provider/provider.dart';

// 3. Imports internes (ordre alphabétique)
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

// 4. Classe principale
class ProductCard extends StatelessWidget {
  // ...
}
```

#### Conventions de nommage

```dart
// Classes : PascalCase
class ProductCard extends StatelessWidget {}

// Variables / Fonctions : camelCase
final productName = 'Poterie';
void addToCart() {}

// Constantes : lowerCamelCase (Dart convention)
const maxFileSize = 5 * 1024 * 1024;

// Privées : préfixe "_"
String _token;
void _initAuth() {}

// Fichiers : snake_case
// product_card.dart, auth_provider.dart
```

#### Widget structure

```dart
class ProductCard extends StatelessWidget {
  // 1. Champs finals en premier
  final Product product;
  final VoidCallback onTap;

  // 2. Constructeur
  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Card(
      // ...
    );
  }

  // 4. Méthodes privées helpers
  void _handleTap() {
    // ...
  }
}
```

#### Provider usage

```dart
// Utiliser Consumer pour écouter les changements
Consumer<ProductProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return LoadingIndicator();
    }
    return ProductList(products: provider.products);
  },
)

// Utiliser context.read pour les actions (ne rebuild pas)
onPressed: () {
  context.read<CartProvider>().addItem(product);
}

// Utiliser context.watch dans build (rebuild si changement)
final cartCount = context.watch<CartProvider>().itemCount;
```

---

## Conventions de commits

### Format Conventional Commits

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types de commits

| Type | Description | Exemple |
|------|-------------|---------|
| `feat` | Nouvelle fonctionnalité | `feat(products): add category filter` |
| `fix` | Correction de bug | `fix(orders): prevent negative stock` |
| `refactor` | Refactoring (pas de changement fonctionnel) | `refactor(auth): extract token validation` |
| `docs` | Documentation uniquement | `docs(api): update product endpoints` |
| `style` | Formatting, indentation | `style(backend): apply prettier` |
| `test` | Ajout/modification de tests | `test(orders): add concurrent orders test` |
| `chore` | Tâches de maintenance | `chore(deps): update mongoose to 8.0` |
| `perf` | Amélioration de performance | `perf(products): add index on categoryId` |

### Scopes

**Backend** :
- `auth`, `products`, `orders`, `payments`, `shipments`, `users`, `admin`

**Frontend** :
- `auth`, `products`, `cart`, `orders`, `profile`, `ui`

**Global** :
- `backend`, `frontend`, `docs`, `ci`, `deps`

### Exemples de bons commits

```bash
# Feature
git commit -m "feat(products): add image upload for products

- Implement multer middleware for file handling
- Add image validation (type, size, dimensions)
- Store images in /uploads/products/{vendorId}/{productId}/
- Update Product model to store image URLs array

Resolves #23"

# Bugfix
git commit -m "fix(orders): enforce atomic stock reservation

- Wrap order creation in MongoDB transaction
- Prevent race condition on concurrent orders
- Add test for simultaneous order placement

Fixes #42
Enforces INV-1 and INV-4"

# Refactoring
git commit -m "refactor(auth): extract JWT verification logic

- Move token verification to separate utility
- Improve error messages
- Add unit tests

No functional changes"

# Documentation
git commit -m "docs(architecture): add sequence diagram for payment flow"

# Performance
git commit -m "perf(products): add composite index for search queries

- Add index on (categoryId, status, createdAt)
- Improves query performance from 800ms to 50ms
- Tested with 10k products dataset"
```

### Mauvais exemples

```bash
# Trop vague
git commit -m "update code"

# Pas de type
git commit -m "add filter"

# Scope incorrect
git commit -m "feat(stuff): add feature"

# Message trop long dans le subject
git commit -m "feat(products): add the ability to filter products by category and also by price range and search text"

# Mélange de changements non liés
git commit -m "feat: add product filter and fix payment bug and update docs"
```

---

## Conventions de branches

### Nomenclature

```
<type>/<short-description>
```

### Types de branches

| Type | Usage | Exemple |
|------|-------|---------|
| `backend/` | Travail backend | `backend/product-filtering` |
| `frontend/` | Travail frontend | `frontend/product-filtering` |
| `hotfix/` | Fix urgent prod (depuis main) | `hotfix/payment-timeout` |

### Règles

1. **Toujours créer depuis `develop`** (après sync)
2. **Nom descriptif mais court** (max 40 caractères)
3. **Kebab-case** (tirets, pas d'underscores)
4. **Pas de numéros d'issue** dans le nom (mettre dans la PR)
5. **Une branche = une fonctionnalité/fix** (pas de mélange)

### Exemples

```bash
# BON
git checkout -b backend/category-filter
git checkout -b frontend/cart-ui
git checkout -b hotfix/payment-timeout

# MAUVAIS
git checkout -b new-feature           # Pas de type
git checkout -b backend_category       # Underscore au lieu de tiret
git checkout -b fix-issue-42           # Type non autorisé
git checkout -b backend/add-category-filter-and-price-range  # Trop long, multiple features
```

### Cycle de vie d'une branche

```
develop
 │
 ├─ backend/category-filter (créée)
 │   │
 │   ├─ commits...
 │   │
 │   ├─ Push to origin
 │   │
 │   ├─ PR créée vers develop
 │   │
 │   ├─ Review & modifications
 │   │
 │   ├─ Approved & Merged
 │   │
 │   └─ Branche supprimée (GitHub + local)
 │
 develop (mise à jour avec le merge)
```

---

## Process de Pull Request

**Règle** : PRs de `backend/*` et `frontend/*` vont vers `develop`. La release se fait via PR `develop` → `main`.

### Checklist avant de créer une PR

Vérifier que :

```bash
# 1. Code compile
npm run build        # Backend
flutter build web    # Frontend

# 2. Tests passent
npm test
flutter test

# 3. Linting OK
npm run lint
flutter analyze

# 4. Code formaté
npm run format
flutter format .

# 5. Pas de console.log oubliés
grep -r "console.log" src/  # Devrait être vide

# 6. Documentation à jour
# Vérifier que les nouvelles fonctions sont documentées
```

### Template de Pull Request

```markdown
## Description
<!-- Description claire et concise des changements -->

## Type de changement
<!-- Cocher la case appropriée -->
- [ ] Feature (nouvelle fonctionnalité)
- [ ] Bugfix (correction de bug)
- [ ] Refactoring (amélioration du code sans changer le comportement)
- [ ] Documentation
- [ ] Performance
- [ ] Tests

## Issue liée
<!-- Lien vers l'issue GitHub -->
Resolves #XX
<!-- OU -->
Related to #XX

## Changements effectués
<!-- Liste détaillée des modifications -->
- Ajout de X
- Modification de Y
- Suppression de Z

## Invariants concernés
<!-- Quels invariants du système sont impactés ? -->
- INV-1 : Stock must not be negative → Enforced par transaction MongoDB
- INV-4 : Atomic stock reservation → Implémenté dans OrderService.createOrder()

## Checklist
<!-- Cocher TOUTES les cases avant de soumettre -->
- [ ] Le code compile sans erreur
- [ ] Tous les tests passent
- [ ] Le code est formaté correctement
- [ ] Aucun warning de linting
- [ ] Les invariants sont respectés
- [ ] La documentation est à jour
- [ ] Les commits suivent la convention
- [ ] J'ai testé manuellement les changements
- [ ] J'ai ajouté des tests si nécessaire

## Tests effectués
<!-- Décrire les scénarios testés manuellement -->
- [ ] Test 1 : Description
- [ ] Test 2 : Description

## Screenshots
<!-- Si changements UI, ajouter des screenshots AVANT/APRÈS -->

## Notes pour les reviewers
<!-- Informations supplémentaires pour faciliter la review -->
```

### Labels de PR

Ajouter les labels appropriés :

- `feature` : Nouvelle fonctionnalité
- `bugfix` : Correction de bug
- `documentation` : Changements de docs
- `backend` : Changements backend
- `frontend` : Changements frontend
- `breaking-change` : Changements non rétrocompatibles
- `needs-review` : En attente de review
- `work-in-progress` : Travail en cours (ajouter `[WIP]` dans le titre)

### Draft PR

Pour obtenir des feedbacks tôt :

```bash
# Créer une Draft PR sur GitHub
# Utile pour :
# - Demander des conseils sur l'approche
# - Montrer le travail en cours
# - Collaborer sur une grosse feature

# Marquer comme "Ready for review" quand terminé
```

---

## Code Review

### En tant que Reviewer

#### Checklist de review

**Fonctionnel** :
- [ ] Le code fait ce qu'il est censé faire
- [ ] Les cas limites sont gérés
- [ ] Les erreurs sont gérées correctement
- [ ] Pas de régression introduite

**Architecture & Design** :
- [ ] Respect de l'architecture en couches
- [ ] Séparation des responsabilités claire
- [ ] Pas de duplication de code
- [ ] Les invariants sont respectés et enforcés

**Code Quality** :
- [ ] Code lisible et compréhensible
- [ ] Noms de variables/fonctions explicites
- [ ] Commentaires appropriés (pourquoi, pas quoi)
- [ ] Pas de code mort (commenté ou inutilisé)

**Performance** :
- [ ] Pas de N+1 queries
- [ ] Utilisation appropriée des index MongoDB
- [ ] Pas de calculs inutiles dans les boucles
- [ ] Images optimisées si applicable

**Sécurité** :
- [ ] Validation des inputs
- [ ] Sanitization des données utilisateur
- [ ] Pas de secrets hardcodés
- [ ] Authentification/autorisation correcte

**Tests** :
- [ ] Tests unitaires ajoutés/modifiés
- [ ] Tests couvrent les cas importants
- [ ] Tests passent tous

#### Comment reviewer

**1. Lire la description de la PR** :
- Comprendre l'objectif
- Vérifier l'issue liée
- Noter les points d'attention mentionnés

**2. Vérifier les changements à haut niveau** :
```bash
# Voir la diff complète
git fetch origin
git diff develop..origin/backend/category-filter

# Ou sur GitHub, onglet "Files changed"
```

**3. Lire le code ligne par ligne** :
- Comprendre la logique
- Vérifier la cohérence
- Identifier les problèmes potentiels

**4. Tester localement si nécessaire** :
```bash
# Checkout la branche de la PR
git fetch origin
git checkout origin/backend/category-filter

# Ou avec GitHub CLI
gh pr checkout 42

# Lancer les tests
npm test

# Tester manuellement
npm run dev
```

**5. Laisser des commentaires constructifs** :

**BON commentaire** :
```markdown
Cette approche peut causer un problème de performance avec beaucoup de produits.

Suggestion : Utiliser une agrégation MongoDB au lieu de filtrer en mémoire.

```javascript
// Au lieu de
const filtered = products.filter(p => p.category === category);

// Faire
const products = await Product.find({ category });
```

Qu'en penses-tu ?
```

**MAUVAIS commentaire** :
```markdown
C'est nul, refais tout.
```

**6. Approuver ou demander des changements** :
- **Approve** : Si tout est bon
- **Request changes** : Si des modifications sont nécessaires
- **Comment** : Pour des questions ou suggestions mineures

#### Types de commentaires

**Nit (Nitpick)** : Suggestions mineures, non bloquantes
```markdown
**Nit:** Je suggérerais de renommer `data` en `productData` pour plus de clarté.
```

**Question** : Demander des clarifications
```markdown
**Question:** Pourquoi utiliser `setTimeout` ici ? Est-ce pour simuler un délai réseau en dev ?
```

**Suggestion** : Proposer une amélioration
```markdown
**Suggestion:** On pourrait extraire cette logique dans une fonction réutilisable `calculateOrderTotal()`.
```

**Blocker** : Problème qui doit être résolu avant merge
```markdown
**Blocker:** Cette approche viole INV-4 (atomic stock reservation). Il faut utiliser une transaction MongoDB.
```

### En tant qu'auteur de PR

#### Répondre aux commentaires

**Être ouvert et professionnel** :

```markdown
> **Suggestion:** Utiliser `Promise.all()` au lieu de boucles séquentielles.

Excellente suggestion ! Je viens de refactorer pour utiliser Promise.all(),
ça réduit le temps d'exécution de 500ms à 100ms.

Commit: abc123
```

**Si vous n'êtes pas d'accord, expliquer** :

```markdown
> **Suggestion:** Supprimer ce try/catch, il cache les erreurs.

Je comprends la préoccupation, mais ce try/catch est nécessaire ici car
on veut continuer le traitement même si un email échoue (envoi de notification).

Les erreurs sont loggées ligne 45, donc on ne les cache pas complètement.

Qu'en penses-tu ?
```

#### Appliquer les modifications

```bash
# Faire les changements demandés
git add .
git commit -m "refactor: apply review suggestions

- Use Promise.all for parallel uploads
- Rename 'data' to 'productData'
- Add comments for error handling"

git push origin backend/category-filter

# La PR se met à jour automatiquement
```

#### Re-request review

Une fois les modifications appliquées :
1. Répondre aux commentaires pour expliquer ce qui a été fait
2. Cliquer sur "Re-request review" sur GitHub

---

## Tests

### Backend Tests

#### Structure des tests

```
backend/tests/
├── unit/                   # Tests unitaires (fonctions isolées)
│   ├── services/
│   │   └── order.service.test.ts
│   └── utils/
│       └── validators.test.ts
├── integration/            # Tests d'intégration (API + DB)
│   └── api/
│       └── orders.api.test.ts
└── e2e/                    # Tests end-to-end (scénarios complets)
    └── order-flow.e2e.test.ts
```

#### Exemple de test unitaire

```typescript
// backend/tests/unit/services/order.service.test.ts
import { OrderService } from '../../../src/services/order.service';
import { Product } from '../../../src/models/Product';
import { ApiError } from '../../../src/utils/ApiError';

describe('OrderService', () => {
  describe('createOrder', () => {
    it('should create order when stock is sufficient', async () => {
      // Arrange
      const mockProduct = {
        _id: 'product-1',
        stock: 10,
        price: 1000,
        save: jest.fn()
      };

      jest.spyOn(Product, 'findById').mockResolvedValue(mockProduct);

      const orderData = {
        customerId: 'customer-1',
        items: [{ productId: 'product-1', quantity: 2 }]
      };

      // Act
      const order = await OrderService.createOrder(orderData);

      // Assert
      expect(order).toBeDefined();
      expect(order.total).toBe(2000);
      expect(mockProduct.stock).toBe(8);
    });

    it('should throw 409 when stock is insufficient (INV-1)', async () => {
      // Arrange
      const mockProduct = {
        _id: 'product-1',
        stock: 1,
        price: 1000
      };

      jest.spyOn(Product, 'findById').mockResolvedValue(mockProduct);

      const orderData = {
        customerId: 'customer-1',
        items: [{ productId: 'product-1', quantity: 5 }]
      };

      // Act & Assert
      await expect(OrderService.createOrder(orderData))
        .rejects
        .toThrow(new ApiError(409, /INV-1 violated/));
    });
  });
});
```

#### Lancer les tests

```bash
# Tous les tests
npm test

# Tests en mode watch
npm run test:watch

# Tests avec coverage
npm run test:coverage

# Test d'un fichier spécifique
npm test -- order.service.test.ts
```

### Frontend Tests

#### Exemple de test widget

```dart
// frontend/test/widget/product_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sahelart/presentation/widgets/product/product_card.dart';
import 'package:sahelart/data/models/product_model.dart';

void main() {
  group('ProductCard Widget', () {
    testWidgets('should display product name and price', (tester) async {
      // Arrange
      final product = ProductModel(
        id: '1',
        name: 'Poterie Artisanale',
        price: 5000,
        stock: 10,
        images: ['https://example.com/image.jpg'],
        // ... autres champs
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Poterie Artisanale'), findsOneWidget);
      expect(find.text('5000 FCFA'), findsOneWidget);
    });

    testWidgets('should show "Rupture de stock" when stock is 0', (tester) async {
      // Arrange
      final product = ProductModel(
        id: '1',
        name: 'Poterie',
        price: 5000,
        stock: 0,
        images: [],
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ProductCard(product: product, onTap: () {}),
        ),
      );

      // Assert
      expect(find.text('Rupture de stock'), findsOneWidget);
    });
  });
}
```

#### Lancer les tests Flutter

```bash
# Tous les tests
flutter test

# Test avec coverage
flutter test --coverage

# Test d'un fichier spécifique
flutter test test/widget/product_card_test.dart
```

---

## Documentation

### Code Documentation

**Backend (JSDoc)** :

```typescript
/**
 * Confirms a payment for an order and updates order status
 *
 * Enforces the following invariants:
 * - INV-5: Payment amount must equal order total
 * - INV-12: Payment confirmation is idempotent
 *
 * @param orderId - The order ID to confirm payment for
 * @param paymentData - Payment confirmation data from provider
 * @param paymentData.transactionId - Unique transaction identifier
 * @param paymentData.providerReference - Provider's reference number
 * @param paymentData.amount - Payment amount in FCFA
 *
 * @returns The updated order with status 'Paid'
 *
 * @throws {ApiError} 404 - Order not found
 * @throws {ApiError} 409 - Payment amount mismatch (INV-5 violated)
 *
 * @example
 * ```typescript
 * const order = await OrderService.confirmPayment(
 *   'order-123',
 *   {
 *     transactionId: 'txn-456',
 *     providerReference: 'OM-789',
 *     amount: 25000
 *   }
 * );
 * ```
 */
async confirmPayment(orderId: string, paymentData: PaymentData): Promise<IOrder> {
  // ...
}
```

**Frontend (DartDoc)** :

```dart
/// A card widget that displays product information
///
/// This widget shows:
/// - Product image (or placeholder if none)
/// - Product name (max 2 lines with ellipsis)
/// - Price in FCFA
/// - Stock status
///
/// Example:
/// ```dart
/// ProductCard(
///   product: product,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class ProductCard extends StatelessWidget {
  /// The product to display
  final ProductModel product;

  /// Callback when the card is tapped
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

### Mise à jour de la documentation

Quand mettre à jour les docs :

1. **Nouvelle feature** → Ajouter section dans README ou créer guide
2. **Changement d'API** → Mettre à jour docs/API.md
3. **Nouveau workflow** → Mettre à jour CONTRIBUTING.md
4. **Changement architecture** → Mettre à jour docs/ARCHITECTURE.md

---

## Résolution de problèmes

### Conflits Git

#### Scénario : Conflit lors du merge de develop

```bash
# 1. Sync avec origin
git checkout develop
git pull origin develop

# 2. Retourner sur votre branche
git checkout backend/category-filter

# 3. Merger develop dans votre branche
git merge develop

# Si conflit :
# Auto-merging backend/src/services/product.service.ts
# CONFLICT (content): Merge conflict in backend/src/services/product.service.ts
```

**Résoudre le conflit** :

```bash
# 1. Ouvrir le fichier en conflit dans votre IDE
# Vous verrez :

<<<<<<< HEAD
// Votre code
const products = await Product.find({ category });
=======
// Code de develop
const products = await Product.find({ status: 'active' });
>>>>>>> develop

# 2. Choisir la version ou combiner :
const products = await Product.find({
  category,
  status: 'active'
});

# 3. Supprimer les marqueurs de conflit (<<<, ===, >>>)

# 4. Ajouter le fichier résolu
git add backend/src/services/product.service.ts

# 5. Terminer le merge
git commit -m "merge: resolve conflict with develop"

# 6. Pousser
git push origin backend/category-filter
```

### PR rejettée par CI

```bash
# Si les tests échouent en CI mais passent localement :

# 1. Vérifier les logs CI sur GitHub
# 2. Reproduire l'environnement CI localement

# Exemple : Tests échouent sur Node 20 mais pas Node 18
nvm use 20
npm test

# 3. Corriger le problème
# 4. Commit et push
```

### Branche désynchronisée

```bash
# Votre branche est derrière develop de 10 commits

# Option 1 : Rebase (recommandé pour historique linéaire)
git checkout backend/category-filter
git fetch origin
git rebase origin/develop

# Résoudre les conflits s'il y en a
git add .
git rebase --continue

# Force push (ATTENTION : seulement sur votre branche de feature)
git push --force-with-lease origin backend/category-filter

# Option 2 : Merge (plus safe si branche partagée)
git checkout backend/category-filter
git pull origin develop
git push origin backend/category-filter
```

### Oublié de créer une branche

```bash
# Vous avez commité sur develop par erreur

# 1. Créer une branche depuis develop (garde les commits)
git checkout -b backend/my-feature

# 2. Reset develop pour revenir à origin/develop
git checkout develop
git reset --hard origin/develop

# 3. Retourner sur votre branche
git checkout backend/my-feature

# 4. Push
git push origin backend/my-feature
```

---

## Questions Fréquentes

**Q: Puis-je travailler sur plusieurs features en parallèle ?**

R: Oui, créez une branche séparée pour chaque feature :
```bash
git checkout develop
git pull origin develop
git checkout -b backend/filter-products
# Travailler...

git checkout develop
git pull origin develop
git checkout -b frontend/add-reviews
# Travailler sur autre chose...
```

**Q: Comment annuler mon dernier commit (pas encore pushé) ?**

R:
```bash
# Garder les changements dans le working directory
git reset --soft HEAD~1

# Supprimer complètement les changements
git reset --hard HEAD~1
```

**Q: J'ai pushé un secret (API key) par erreur, que faire ?**

R:
1. **IMMÉDIATEMENT** révoquer la clé/secret compromise
2. Créer une nouvelle clé et la mettre dans .env (jamais commitée)
3. Contacter **the-y4nn** pour nettoyer l'historique Git
4. Ajouter le fichier dans `.gitignore` si ce n'est pas déjà fait

**Q: Combien de temps avant qu'une PR soit reviewée ?**

R:
- Backend : Review par **the-y4nn**
- Frontend : Review par **Mourina** ou **Eliezer**
- Délai habituel : 24-48h max
- Si urgent, mentionner dans la PR

**Q: Je veux travailler sur une feature, comment m'organiser ?**

R:
1. Créer une issue ou vérifier qu'elle existe
2. S'assigner l'issue sur GitHub
3. Créer une branche depuis develop
4. Développer et pousser régulièrement
5. Créer la PR quand prêt

**Q: Backend et Frontend en même temps : comment synchroniser ?**

R:
- Backend implémente l'endpoint en premier
- PR vers develop après tests
- Frontend récupère develop et consomme l'endpoint
- Si besoin de modifier l'API : discussion d'équipe AVANT modification

---

## Contact & Support

**Questions sur le code** : Créer une issue avec label `question`

**Discussions** : Utiliser GitHub Discussions

**Bugs urgents** : Créer une issue avec label `bug` + `priority-high`

---

Merci de contribuer à SahelArt ! Votre aide est précieuse pour digitaliser le commerce artisanal au Sahel.
