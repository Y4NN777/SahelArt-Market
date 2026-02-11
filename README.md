# SahelArt Market

**Marketplace multi-vendeurs pour artisans du Sahel**

SahelArt est une plateforme e-commerce dédiée à la digitalisation du commerce artisanal au Burkina Faso et dans la région du Sahel. Le projet permet aux artisans de vendre leurs produits en ligne via une infrastructure structurée, transparente et scalable.

---

## Table des matières

- [Vision du projet](#vision-du-projet)
- [Stack technique](#stack-technique)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Installation](#installation)
- [Démarrage rapide](#démarrage-rapide)
- [Équipe](#équipe)
- [Contribution](#contribution)

---

## Vision du projet

SahelArt n'est pas simplement une boutique en ligne. C'est une infrastructure digitale conçue pour formaliser, structurer et moderniser le commerce artisanal local.

### Problématique

Les artisans locaux font face à des limitations structurelles :
- Portée physique limitée (ventes dépendantes des marchés locaux)
- Absence de présence digitale structurée
- Gestion informelle des stocks
- Pas de suivi fiable des commandes
- Visibilité limitée au-delà de leur géographie immédiate

### Solution

Une plateforme centralisée qui permet aux artisans de :
- Gérer leurs produits et stocks en ligne
- Recevoir et traiter des commandes
- Suivre les paiements et livraisons
- Accéder à des analytics sur leurs ventes

Et aux clients de :
- Découvrir des produits artisanaux authentiques
- Acheter en toute sécurité
- Suivre leurs commandes en temps réel

---

## Stack technique

### Frontend
- **Framework** : Flutter 3.27+
- **Plateformes** : Web + Mobile (iOS/Android)
- **State Management** : Provider
- **HTTP Client** : Dio
- **Storage** : Flutter Secure Storage (mobile), LocalStorage (web)

### Backend
- **Runtime** : Node.js 20.x LTS
- **Framework** : Express 4.18+
- **Langage** : TypeScript 5.3+
- **Base de données** : MongoDB 7.0+
- **ODM** : Mongoose 8.0+
- **Authentification** : JWT (jsonwebtoken)
- **Validation** : Joi
- **File Upload** : Multer

### Infrastructure
- **Containerization** : Docker
- **Process Manager** : PM2
- **Reverse Proxy** : Nginx
- **Version Control** : Git + GitHub

---

## Architecture

Le projet suit une architecture en couches (Layered Architecture) avec séparation stricte des responsabilités :

### Architecture système

```
Frontend (Flutter)
      │
      │ REST API (JSON)
      │ JWT Authentication
      ▼
Backend (Express)
  ├─ Routes
  ├─ Middleware (Auth, RBAC, Invariants)
  ├─ Controllers
  ├─ Services (Business Logic)
  ├─ Repositories (Data Access)
  └─ Models (Mongoose Schemas)
      │
      ▼
MongoDB + File Storage
```

### Principes de conception

**Contract-First Development** :
- Le contrat système (invariants) est défini avant l'implémentation
- L'API est documentée avant le code
- Frontend et Backend se synchronisent via le contrat API

**Domain-Driven Design** :
- Domaines métier : Identity, Products, Orders, Payments, Shipments
- Bounded contexts clairement définis
- Communication inter-domaines via Services

**Security by Design** :
- Authentification JWT obligatoire pour les routes protégées
- Autorisation basée sur les rôles (RBAC)
- Enforcement des invariants au niveau middleware
- Isolation stricte des données vendeurs

---

## Documentation

Le projet dispose d'une documentation complète et structurée :

### Documents de planification

- **[PRD (Product Requirements Document)](docs/sahel_art_prd.md)** : Vision produit, objectifs, scope
- **[SRS (Software Requirements Specification)](docs/sahel_art_srs.md)** : Spécifications fonctionnelles et techniques
- **[Contrat Système & Invariants](docs/sahel_art_system_contract_and_invariants.md)** : Garanties, états interdits, machine à états

### Architecture

- **[Architecture Système](docs/ARCHITECTURE.md)** : Vue globale, domaines métier, sécurité, déploiement
- **[Architecture Backend](backend/ARCHITECTURE.md)** : Structure projet, middleware, modèles, services
- **[Architecture Frontend](frontend/ARCHITECTURE.md)** : Clean Architecture, Provider, repositories

### Contrat API

- **[API Contract](docs/API.md)** : Spécification complète de l'API REST
  - Tous les endpoints documentés
  - Request/Response avec exemples
  - Codes d'erreur standardisés
  - Mapping des invariants par endpoint
  - Flows complets end-to-end

### Contribution

- **[Guide de contribution](CONTRIBUTING.md)** : Workflow Git, conventions, standards de code, review process

---

## Installation

### Prérequis

**Backend** :
- Node.js 20.x LTS
- npm ou yarn
- MongoDB 7.0+ (ou Docker)
- Git

**Frontend** :
- Flutter SDK 3.27+
- Dart SDK
- Android Studio (pour mobile Android)
- Xcode (pour mobile iOS, macOS uniquement)

### Cloner le repository

```bash
git clone https://github.com/the-y4nn/SahelArt-Market.git
cd SahelArt-Market
```

### Configuration Backend

```bash
cd backend

# Installer les dépendances
npm install

# Copier le fichier d'environnement
cp .env.example .env

# Modifier .env avec vos paramètres
nano .env
```

**Démarrer MongoDB avec Docker** :

```bash
docker run -d \
  --name sahelart-mongo \
  -p 27017:27017 \
  -v sahelart-data:/data/db \
  mongo:7
```

### Configuration Frontend

```bash
cd frontend

# Vérifier l'installation Flutter
flutter doctor

# Installer les dépendances
flutter pub get

# Générer les fichiers de sérialisation JSON
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Démarrage rapide

### Backend

```bash
cd backend

# Mode développement (avec hot reload)
npm run dev

# Le serveur démarre sur http://localhost:3000
```

**Tester l'API** :

```bash
curl http://localhost:3000/api/health
# Devrait retourner: {"status": "ok"}
```

### Frontend

**Web** :

```bash
cd frontend
flutter run -d chrome

# L'application s'ouvre sur http://localhost:5173
```

**Mobile** :

```bash
# Avec émulateur/device connecté
flutter run
```

### Tests

**Backend** :

```bash
cd backend

# Lancer tous les tests
npm test

# Tests avec coverage
npm run test:coverage

# Tests en mode watch
npm run test:watch
```

**Frontend** :

```bash
cd frontend

# Lancer tous les tests
flutter test

# Tests avec coverage
flutter test --coverage
```

---

## Équipe

### Développement

**Backend** :
- **Yanis** : API REST, MongoDB, Architecture

**Frontend** :
- **Mourina** : Flutter (Web + Mobile)
- **Eliezer** : Flutter (Web + Mobile)

### Workflow de collaboration

L'équipe travaille directement sur le repository principal avec des branches de feature. Pas de workflow fork.

**Process** :
1. Créer une branche depuis `main`
2. Développer et tester
3. Créer une Pull Request
4. Code Review
5. Merge dans `main`

Voir le [Guide de contribution](CONTRIBUTING.md) pour plus de détails.

---

## Contribution

Les contributions sont les bienvenues ! Veuillez lire le [Guide de contribution](CONTRIBUTING.md) avant de commencer.

### Quick start

1. Cloner le repository
2. Créer une branche : `git checkout -b feature/ma-feature`
3. Coder en suivant les standards définis
4. Tester : `npm test` (backend) ou `flutter test` (frontend)
5. Commit : Suivre les conventions de commits (Conventional Commits)
6. Push : `git push origin feature/ma-feature`
7. Créer une Pull Request

### Standards de code

**Backend (TypeScript)** :
- ESLint + Prettier
- Architecture en couches
- Tests unitaires obligatoires
- Documentation JSDoc

**Frontend (Flutter/Dart)** :
- Flutter analyze
- Clean Architecture
- Provider pour state management
- Documentation DartDoc

---

## Contact

**Repository** : [github.com/the-y4nn/SahelArt-Market](https://github.com/Y4NN777/SahelArt-Market)

**Issues** : [github.com/the-y4nn/SahelArt-Market/issues](https://github.com/Y4NN777/SahelArt-Market/issues)

---

**Version** : 1.0.0-alpha
**Dernière mise à jour** : 2026-02-06

---

> "Code is replaceable. The contract is not."
>
> Principe fondamental de SahelArt : Le code implémente le contrat système défini.
