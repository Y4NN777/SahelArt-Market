# SahelArt - API Contract

## Document de Référence API

**Version** : 1.0.0
**Date** : 2026-02-06
**Base URL** : `http://localhost:3000/api` (dev) | `https://api.sahelart.bf/api` (prod)

---

## Table des matières

1. [Introduction](#introduction)
2. [Conventions générales](#conventions-générales)
3. [Authentification](#authentification)
4. [Modèles de données](#modèles-de-données)
5. [Endpoints Authentication](#endpoints-authentication)
6. [Endpoints Users](#endpoints-users)
7. [Endpoints Products](#endpoints-products)
8. [Endpoints Categories](#endpoints-categories)
9. [Endpoints Orders](#endpoints-orders)
10. [Endpoints Payments](#endpoints-payments)
11. [Endpoints Shipments](#endpoints-shipments)
12. [Endpoints Admin](#endpoints-admin)
13. [Codes d'erreur](#codes-derreur)
14. [Flows complets](#flows-complets)

---

## Introduction

Ce document définit le **contrat API** entre le backend (Node.js/Express) et le frontend (Flutter).

**Principe** : Ce document est la source de vérité. Tout changement d'API DOIT être documenté ici AVANT implémentation.

**Règles** :
- Backend implémente exactement ce qui est documenté
- Frontend consomme exactement ce qui est documenté
- Tout écart doit être discuté et validé par l'équipe

---

## Conventions générales

### Format de communication

**Protocol** : HTTPS
**Format** : JSON
**Encoding** : UTF-8

### Structure de réponse standard

**Succès** :
```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message"
}
```

**Erreur** :
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "field": "fieldName",
    "details": { ... }
  }
}
```

### Pagination

Toutes les listes paginées suivent ce format :

**Request** :
```
GET /endpoint?page=1&limit=20
```

**Response** :
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8,
    "hasNext": true,
    "hasPrev": false
  }
}
```

**Paramètres** :
- `page` : Numéro de page (défaut: 1, min: 1)
- `limit` : Items par page (défaut: 20, min: 1, max: 100)

### Headers requis

**Toutes les requêtes** :
```
Content-Type: application/json
Accept: application/json
```

**Requêtes authentifiées** :
```
Authorization: Bearer <JWT_TOKEN>
```

### Codes HTTP

| Code | Signification | Usage |
|------|---------------|-------|
| 200 | OK | Succès (GET, PATCH, DELETE) |
| 201 | Created | Ressource créée (POST) |
| 204 | No Content | Succès sans contenu (DELETE) |
| 400 | Bad Request | Données invalides |
| 401 | Unauthorized | Token manquant/invalide |
| 403 | Forbidden | Accès interdit (rôle insuffisant) |
| 404 | Not Found | Ressource introuvable |
| 409 | Conflict | Invariant violé, conflit logique |
| 422 | Unprocessable Entity | Validation échouée |
| 500 | Internal Server Error | Erreur serveur |

---

## Authentification

### Méthode

**JWT (JSON Web Token)** stocké côté client.

**Token Payload** :
```json
{
  "userId": "65a1b2c3d4e5f6789",
  "email": "user@example.com",
  "role": "customer" | "vendor" | "admin",
  "iat": 1702340000,
  "exp": 1702426400
}
```

**Durée de vie** : 24h (production)

### Stockage côté frontend

- **Mobile** : Flutter Secure Storage
- **Web** : LocalStorage (ou SessionStorage)

### Refresh

Pour le MVP, pas de refresh token. L'utilisateur doit se reconnecter après expiration.

---

## Modèles de données

### User

```typescript
{
  "_id": "ObjectId",
  "email": "string",
  "role": "customer" | "vendor" | "admin",
  "profile": {
    "firstName": "string",
    "lastName": "string",
    "phone": "string?",
    "address": "string?"
  },
  "status": "active" | "suspended",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Product

```typescript
{
  "_id": "ObjectId",
  "vendorId": "ObjectId",
  "categoryId": "ObjectId",
  "name": "string",
  "description": "string",
  "price": "number",
  "stock": "number",
  "images": "string[]",
  "status": "active" | "inactive",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Category

```typescript
{
  "_id": "ObjectId",
  "name": "string",
  "description": "string",
  "slug": "string",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Order

```typescript
{
  "_id": "ObjectId",
  "customerId": "ObjectId",
  "items": [
    {
      "productId": "ObjectId",
      "vendorId": "ObjectId",
      "name": "string",
      "price": "number",
      "quantity": "number",
      "subtotal": "number"
    }
  ],
  "total": "number",
  "status": "Pending" | "Paid" | "Shipped" | "Delivered" | "Cancelled",
  "shippingAddress": {
    "street": "string",
    "city": "string",
    "postalCode": "string?",
    "country": "string",
    "phone": "string"
  },
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Payment

```typescript
{
  "_id": "ObjectId",
  "orderId": "ObjectId",
  "customerId": "ObjectId",
  "amount": "number",
  "method": "orange_money" | "wave" | "moov" | "cash",
  "status": "Pending" | "Completed" | "Failed",
  "transactionId": "string?",
  "providerReference": "string?",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

### Shipment

```typescript
{
  "_id": "ObjectId",
  "orderId": "ObjectId",
  "vendorId": "ObjectId",
  "trackingNumber": "string?",
  "status": "Preparing" | "Shipped" | "InTransit" | "Delivered",
  "shippedAt": "Date?",
  "deliveredAt": "Date?",
  "createdAt": "Date",
  "updatedAt": "Date"
}
```

---

## Endpoints Authentication

### POST /auth/register

Créer un nouveau compte utilisateur.

**Authentication** : Non
**Autorisation** : Public

**Request Body** :
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123",
  "role": "customer" | "vendor",
  "profile": {
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+22670123456",
    "address": "Ouagadougou, Burkina Faso"
  }
}
```

**Validation** :
- `email` : Format email valide, unique
- `password` : Min 8 caractères
- `role` : "customer" ou "vendor" uniquement (pas "admin")
- `profile.firstName` : Requis, 2-50 caractères
- `profile.lastName` : Requis, 2-50 caractères
- `profile.phone` : Optionnel, format international

**Response 201 Created** :
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "65a1b2c3d4e5f6789",
      "email": "user@example.com",
      "role": "customer",
      "profile": {
        "firstName": "John",
        "lastName": "Doe",
        "phone": "+22670123456",
        "address": "Ouagadougou, Burkina Faso"
      },
      "status": "active",
      "createdAt": "2026-02-06T10:30:00Z",
      "updatedAt": "2026-02-06T10:30:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Account created successfully"
}
```

**Errors** :
- `400` : Validation échouée
- `409` : Email déjà utilisé

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@example.com",
    "password": "SecurePass123",
    "role": "vendor",
    "profile": {
      "firstName": "Marie",
      "lastName": "Kaboré",
      "phone": "+22670123456"
    }
  }'
```

---

### POST /auth/login

Authentifier un utilisateur existant.

**Authentication** : Non
**Autorisation** : Public

**Request Body** :
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123"
}
```

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "65a1b2c3d4e5f6789",
      "email": "user@example.com",
      "role": "customer",
      "profile": { ... },
      "status": "active"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "message": "Login successful"
}
```

**Errors** :
- `400` : Email ou password manquant
- `401` : Identifiants invalides
- `403` : Compte suspendu

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "vendor@example.com",
    "password": "SecurePass123"
  }'
```

---

### GET /auth/me

Récupérer les informations de l'utilisateur connecté.

**Authentication** : Oui
**Autorisation** : Tous (customer, vendor, admin)

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "65a1b2c3d4e5f6789",
      "email": "user@example.com",
      "role": "customer",
      "profile": { ... },
      "status": "active",
      "createdAt": "2026-02-06T10:30:00Z",
      "updatedAt": "2026-02-06T10:30:00Z"
    }
  }
}
```

**Errors** :
- `401` : Token manquant ou invalide

**Exemple curl** :
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Endpoints Users

### PATCH /users/me

Mettre à jour le profil de l'utilisateur connecté.

**Authentication** : Oui
**Autorisation** : Tous

**Request Body** (tous les champs optionnels) :
```json
{
  "profile": {
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+22670123456",
    "address": "Ouagadougou"
  }
}
```

**Note** : On ne peut pas changer `email`, `role`, ou `status` via cet endpoint.

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "user": { ... }
  },
  "message": "Profile updated successfully"
}
```

**Errors** :
- `400` : Validation échouée
- `401` : Non authentifié

---

## Endpoints Products

### GET /products

Lister les produits avec filtres et pagination.

**Authentication** : Non
**Autorisation** : Public
**Invariants** : Aucun (lecture seule)

**Query Parameters** :
- `page` : Numéro de page (défaut: 1)
- `limit` : Items par page (défaut: 20, max: 100)
- `category` : Filter par categoryId
- `minPrice` : Prix minimum
- `maxPrice` : Prix maximum
- `search` : Recherche texte (name + description)
- `vendorId` : Filter par vendorId
- `status` : Filter par status (admin seulement)

**Note** : Par défaut, seuls les produits `status: "active"` sont retournés (sauf pour admin/vendor propriétaire).

**Response 200 OK** :
```json
{
  "success": true,
  "data": [
    {
      "_id": "65b1c2d3e4f5g6h7i8",
      "vendorId": "65a1b2c3d4e5f6789",
      "categoryId": "65c1d2e3f4g5h6i7j8",
      "name": "Poterie Artisanale",
      "description": "Belle poterie faite à la main...",
      "price": 5000,
      "stock": 12,
      "images": [
        "/uploads/products/vendor123/product456/main.jpg",
        "/uploads/products/vendor123/product456/gallery-1.jpg"
      ],
      "status": "active",
      "createdAt": "2026-02-06T10:00:00Z",
      "updatedAt": "2026-02-06T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3,
    "hasNext": true,
    "hasPrev": false
  }
}
```

**Exemple curl** :
```bash
# Tous les produits (page 1)
curl http://localhost:3000/api/products

# Filtrer par catégorie
curl "http://localhost:3000/api/products?category=65c1d2e3f4g5h6i7j8"

# Filtrer par prix
curl "http://localhost:3000/api/products?minPrice=1000&maxPrice=10000"

# Recherche texte
curl "http://localhost:3000/api/products?search=poterie"

# Pagination
curl "http://localhost:3000/api/products?page=2&limit=10"
```

---

### GET /products/:id

Récupérer les détails d'un produit.

**Authentication** : Non
**Autorisation** : Public

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "_id": "65b1c2d3e4f5g6h7i8",
    "vendorId": "65a1b2c3d4e5f6789",
    "categoryId": "65c1d2e3f4g5h6i7j8",
    "name": "Poterie Artisanale",
    "description": "Belle poterie faite à la main par des artisans locaux...",
    "price": 5000,
    "stock": 12,
    "images": [ ... ],
    "status": "active",
    "createdAt": "2026-02-06T10:00:00Z",
    "updatedAt": "2026-02-06T10:00:00Z"
  }
}
```

**Errors** :
- `404` : Produit introuvable

**Exemple curl** :
```bash
curl http://localhost:3000/api/products/65b1c2d3e4f5g6h7i8
```

---

### POST /products

Créer un nouveau produit (vendor uniquement).

**Authentication** : Oui
**Autorisation** : vendor, admin
**Invariants** : INV-1 (stock >= 0), INV-9 (product belongs to exactly one vendor)

**Request Body** :
```json
{
  "categoryId": "65c1d2e3f4g5h6i7j8",
  "name": "Poterie Artisanale",
  "description": "Belle poterie faite à la main...",
  "price": 5000,
  "stock": 12,
  "images": []
}
```

**Validation** :
- `categoryId` : Requis, doit exister
- `name` : Requis, 3-200 caractères
- `description` : Requis, 10-2000 caractères
- `price` : Requis, > 0
- `stock` : Requis, >= 0, entier
- `images` : Optionnel, max 5 images

**Response 201 Created** :
```json
{
  "success": true,
  "data": {
    "_id": "65b1c2d3e4f5g6h7i8",
    "vendorId": "65a1b2c3d4e5f6789",
    "categoryId": "65c1d2e3f4g5h6i7j8",
    "name": "Poterie Artisanale",
    "description": "Belle poterie faite à la main...",
    "price": 5000,
    "stock": 12,
    "images": [],
    "status": "active",
    "createdAt": "2026-02-06T10:00:00Z",
    "updatedAt": "2026-02-06T10:00:00Z"
  },
  "message": "Product created successfully"
}
```

**Note** : Le `vendorId` est automatiquement extrait du JWT (pas dans le body).

**Errors** :
- `400` : Validation échouée
- `401` : Non authentifié
- `403` : Pas le rôle vendor/admin
- `404` : Category non trouvée
- `409` : INV-1 violé (stock négatif)

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "categoryId": "65c1d2e3f4g5h6i7j8",
    "name": "Poterie Traditionnelle",
    "description": "Poterie authentique du Burkina Faso, faite à la main...",
    "price": 7500,
    "stock": 5
  }'
```

---

### PATCH /products/:id

Mettre à jour un produit existant.

**Authentication** : Oui
**Autorisation** : vendor (propriétaire uniquement), admin
**Invariants** : INV-1 (stock >= 0)

**Request Body** (tous les champs optionnels) :
```json
{
  "name": "Nouveau nom",
  "description": "Nouvelle description",
  "price": 6000,
  "stock": 8,
  "status": "active" | "inactive",
  "categoryId": "65c1d2e3f4g5h6i7j8"
}
```

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "_id": "65b1c2d3e4f5g6h7i8",
    "vendorId": "65a1b2c3d4e5f6789",
    "name": "Nouveau nom",
    "price": 6000,
    "stock": 8,
    ...
  },
  "message": "Product updated successfully"
}
```

**Errors** :
- `400` : Validation échouée
- `401` : Non authentifié
- `403` : Pas le propriétaire du produit
- `404` : Produit introuvable
- `409` : INV-1 violé (stock négatif)

**Exemple curl** :
```bash
curl -X PATCH http://localhost:3000/api/products/65b1c2d3e4f5g6h7i8 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "stock": 15,
    "price": 5500
  }'
```

---

### DELETE /products/:id

Supprimer un produit.

**Authentication** : Oui
**Autorisation** : vendor (propriétaire), admin
**Invariants** : FR-10 (cannot delete product in active orders)

**Response 200 OK** :
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Pas le propriétaire
- `404` : Produit introuvable
- `409` : Produit lié à des commandes actives (INV violation)

**Exemple curl** :
```bash
curl -X DELETE http://localhost:3000/api/products/65b1c2d3e4f5g6h7i8 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### POST /products/:id/images

Uploader des images pour un produit.

**Authentication** : Oui
**Autorisation** : vendor (propriétaire), admin
**Content-Type** : `multipart/form-data`

**Request Body** :
```
FormData:
  - images: File[] (max 5 images)
```

**Validation** :
- Format : jpg, png, webp
- Taille max : 5MB par image
- Dimensions min : 400x400px
- Max 5 images au total pour le produit

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "images": [
      "/uploads/products/vendor123/product456/main.jpg",
      "/uploads/products/vendor123/product456/gallery-1.jpg"
    ]
  },
  "message": "Images uploaded successfully"
}
```

**Errors** :
- `400` : Validation fichier échouée (format, taille)
- `401` : Non authentifié
- `403` : Pas le propriétaire
- `404` : Produit introuvable
- `413` : Fichier trop large

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/api/products/65b1c2d3e4f5g6h7i8/images \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "images=@/path/to/image1.jpg" \
  -F "images=@/path/to/image2.jpg"
```

---

## Endpoints Categories

### GET /categories

Lister toutes les catégories.

**Authentication** : Non
**Autorisation** : Public

**Response 200 OK** :
```json
{
  "success": true,
  "data": [
    {
      "_id": "65c1d2e3f4g5h6i7j8",
      "name": "Poterie",
      "description": "Articles en poterie artisanale",
      "slug": "poterie",
      "createdAt": "2026-02-06T10:00:00Z",
      "updatedAt": "2026-02-06T10:00:00Z"
    },
    {
      "_id": "65c1d2e3f4g5h6i7j9",
      "name": "Textile",
      "description": "Tissus et vêtements traditionnels",
      "slug": "textile",
      "createdAt": "2026-02-06T10:00:00Z",
      "updatedAt": "2026-02-06T10:00:00Z"
    }
  ]
}
```

**Exemple curl** :
```bash
curl http://localhost:3000/api/categories
```

---

## Endpoints Orders

### POST /orders

Créer une nouvelle commande.

**Authentication** : Oui
**Autorisation** : customer
**Invariants** : INV-1, INV-2, INV-3, INV-4

**Request Body** :
```json
{
  "items": [
    {
      "productId": "65b1c2d3e4f5g6h7i8",
      "quantity": 2
    },
    {
      "productId": "65b1c2d3e4f5g6h7i9",
      "quantity": 1
    }
  ],
  "shippingAddress": {
    "street": "Rue 12.34",
    "city": "Ouagadougou",
    "postalCode": "01 BP 1234",
    "country": "Burkina Faso",
    "phone": "+22670123456"
  }
}
```

**Validation** :
- `items` : Requis, au moins 1 item (INV-2)
- `items[].productId` : Doit exister
- `items[].quantity` : > 0, entier
- `shippingAddress.street` : Requis
- `shippingAddress.city` : Requis
- `shippingAddress.country` : Requis
- `shippingAddress.phone` : Requis

**Traitement backend** :
1. Vérifier stock disponible pour chaque produit (INV-1)
2. Calculer le total = sum(price × quantity) (INV-3)
3. Créer la commande avec transaction MongoDB (INV-4)
4. Réserver le stock atomiquement (INV-4)
5. Créer l'enregistrement de paiement (status: Pending)

**Response 201 Created** :
```json
{
  "success": true,
  "data": {
    "order": {
      "_id": "65d1e2f3g4h5i6j7k8",
      "customerId": "65a1b2c3d4e5f6789",
      "items": [
        {
          "productId": "65b1c2d3e4f5g6h7i8",
          "vendorId": "65a1b2c3d4e5f6789",
          "name": "Poterie Artisanale",
          "price": 5000,
          "quantity": 2,
          "subtotal": 10000
        },
        {
          "productId": "65b1c2d3e4f5g6h7i9",
          "vendorId": "65a1b2c3d4e5f6790",
          "name": "Textile Traditionnel",
          "price": 8000,
          "quantity": 1,
          "subtotal": 8000
        }
      ],
      "total": 18000,
      "status": "Pending",
      "shippingAddress": { ... },
      "createdAt": "2026-02-06T11:00:00Z",
      "updatedAt": "2026-02-06T11:00:00Z"
    },
    "payment": {
      "_id": "65e1f2g3h4i5j6k7l8",
      "orderId": "65d1e2f3g4h5i6j7k8",
      "amount": 18000,
      "status": "Pending",
      "method": "orange_money"
    }
  },
  "message": "Order created successfully"
}
```

**Errors** :
- `400` : Validation échouée
- `401` : Non authentifié
- `403` : Rôle non autorisé (seuls customers)
- `404` : Produit non trouvé
- `409` : INV-1 violé (stock insuffisant)
- `409` : INV-2 violé (aucun produit dans la commande)
- `409` : INV-3 violé (total incorrect)

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/api/orders \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"productId": "65b1c2d3e4f5g6h7i8", "quantity": 2}
    ],
    "shippingAddress": {
      "street": "Rue 12.34",
      "city": "Ouagadougou",
      "country": "Burkina Faso",
      "phone": "+22670123456"
    }
  }'
```

---

### GET /orders

Lister les commandes de l'utilisateur connecté.

**Authentication** : Oui
**Autorisation** : customer (ses commandes), vendor (commandes avec ses produits), admin (toutes)

**Query Parameters** :
- `page` : Numéro de page (défaut: 1)
- `limit` : Items par page (défaut: 20)
- `status` : Filter par status

**Logique** :
- Customer : Retourne les commandes où `customerId = userId`
- Vendor : Retourne les commandes contenant au moins un produit du vendor
- Admin : Retourne toutes les commandes

**Response 200 OK** :
```json
{
  "success": true,
  "data": [
    {
      "_id": "65d1e2f3g4h5i6j7k8",
      "customerId": "65a1b2c3d4e5f6789",
      "items": [ ... ],
      "total": 18000,
      "status": "Paid",
      "shippingAddress": { ... },
      "createdAt": "2026-02-06T11:00:00Z",
      "updatedAt": "2026-02-06T11:05:00Z"
    }
  ],
  "pagination": { ... }
}
```

**Exemple curl** :
```bash
# Customer voit ses commandes
curl http://localhost:3000/api/orders \
  -H "Authorization: Bearer CUSTOMER_TOKEN"

# Filtrer par status
curl "http://localhost:3000/api/orders?status=Paid" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### GET /orders/:id

Récupérer les détails d'une commande.

**Authentication** : Oui
**Autorisation** : customer (propriétaire), vendor (si produit dans commande), admin

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "_id": "65d1e2f3g4h5i6j7k8",
    "customerId": "65a1b2c3d4e5f6789",
    "items": [
      {
        "productId": "65b1c2d3e4f5g6h7i8",
        "vendorId": "65a1b2c3d4e5f6789",
        "name": "Poterie Artisanale",
        "price": 5000,
        "quantity": 2,
        "subtotal": 10000
      }
    ],
    "total": 18000,
    "status": "Paid",
    "shippingAddress": { ... },
    "createdAt": "2026-02-06T11:00:00Z",
    "updatedAt": "2026-02-06T11:05:00Z"
  }
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Pas autorisé à voir cette commande
- `404` : Commande introuvable

**Exemple curl** :
```bash
curl http://localhost:3000/api/orders/65d1e2f3g4h5i6j7k8 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### PATCH /orders/:id/ship

Marquer une commande comme expédiée (vendor uniquement).

**Authentication** : Oui
**Autorisation** : vendor (si produit dans commande), admin
**Invariants** : INV-6 (order must be Paid before shipping), INV-8 (only product vendor ships)

**Request Body** :
```json
{
  "trackingNumber": "TRACK123456"
}
```

**Validation** :
- La commande doit être en status "Paid" (INV-6)
- Le vendor doit avoir au moins un produit dans la commande (INV-8)

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "order": {
      "_id": "65d1e2f3g4h5i6j7k8",
      "status": "Shipped",
      "updatedAt": "2026-02-06T12:00:00Z",
      ...
    },
    "shipment": {
      "_id": "65f1g2h3i4j5k6l7m8",
      "orderId": "65d1e2f3g4h5i6j7k8",
      "vendorId": "65a1b2c3d4e5f6789",
      "trackingNumber": "TRACK123456",
      "status": "Shipped",
      "shippedAt": "2026-02-06T12:00:00Z"
    }
  },
  "message": "Order marked as shipped"
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Vendor n'a pas de produit dans cette commande
- `404` : Commande introuvable
- `409` : INV-6 violé (commande pas encore payée)

**Exemple curl** :
```bash
curl -X PATCH http://localhost:3000/api/orders/65d1e2f3g4h5i6j7k8/ship \
  -H "Authorization: Bearer VENDOR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"trackingNumber": "TRACK123456"}'
```

---

### PATCH /orders/:id/delivered

Confirmer la réception d'une commande (customer uniquement).

**Authentication** : Oui
**Autorisation** : customer (propriétaire uniquement)

**Validation** :
- La commande doit être en status "Shipped"

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "order": {
      "_id": "65d1e2f3g4h5i6j7k8",
      "status": "Delivered",
      "updatedAt": "2026-02-06T14:00:00Z",
      ...
    }
  },
  "message": "Order marked as delivered"
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Pas le client de cette commande
- `404` : Commande introuvable
- `409` : Commande pas en status "Shipped"

**Exemple curl** :
```bash
curl -X PATCH http://localhost:3000/api/orders/65d1e2f3g4h5i6j7k8/delivered \
  -H "Authorization: Bearer CUSTOMER_TOKEN"
```

---

### PATCH /orders/:id/cancel

Annuler une commande.

**Authentication** : Oui
**Autorisation** : customer (propriétaire), admin

**Validation** :
- La commande doit être en status "Pending" (avant paiement)

**Traitement backend** :
1. Vérifier status = "Pending"
2. Restaurer le stock des produits (transaction)
3. Mettre à jour status = "Cancelled"

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "order": {
      "_id": "65d1e2f3g4h5i6j7k8",
      "status": "Cancelled",
      "updatedAt": "2026-02-06T11:30:00Z",
      ...
    }
  },
  "message": "Order cancelled successfully"
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Pas autorisé
- `404` : Commande introuvable
- `409` : Commande déjà payée (cannot cancel)

**Exemple curl** :
```bash
curl -X PATCH http://localhost:3000/api/orders/65d1e2f3g4h5i6j7k8/cancel \
  -H "Authorization: Bearer CUSTOMER_TOKEN"
```

---

## Endpoints Payments

### POST /payments

Initier un paiement pour une commande (MVP : simulé).

**Authentication** : Oui
**Autorisation** : customer (propriétaire de la commande)
**Invariants** : INV-5 (payment amount = order total)

**Request Body** :
```json
{
  "orderId": "65d1e2f3g4h5i6j7k8",
  "method": "orange_money" | "wave" | "moov" | "cash",
  "amount": 18000
}
```

**Validation** :
- `orderId` : Requis, doit exister
- `method` : Requis, valeurs autorisées
- `amount` : Requis, doit égaler order.total (INV-5)

**MVP Behavior** :
- Pour le MVP, le paiement est directement marqué comme "Completed"
- Phase 2 : Intégration réelle avec Orange Money/Wave

**Response 201 Created** :
```json
{
  "success": true,
  "data": {
    "payment": {
      "_id": "65e1f2g3h4i5j6k7l8",
      "orderId": "65d1e2f3g4h5i6j7k8",
      "customerId": "65a1b2c3d4e5f6789",
      "amount": 18000,
      "method": "orange_money",
      "status": "Completed",
      "transactionId": "TXN123456789",
      "createdAt": "2026-02-06T11:05:00Z",
      "updatedAt": "2026-02-06T11:05:00Z"
    },
    "order": {
      "_id": "65d1e2f3g4h5i6j7k8",
      "status": "Paid",
      ...
    }
  },
  "message": "Payment successful"
}
```

**Errors** :
- `400` : Validation échouée
- `401` : Non authentifié
- `403` : Pas le propriétaire de la commande
- `404` : Commande introuvable
- `409` : INV-5 violé (montant incorrect)
- `409` : Commande déjà payée

**Exemple curl** :
```bash
curl -X POST http://localhost:3000/api/payments \
  -H "Authorization: Bearer CUSTOMER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "65d1e2f3g4h5i6j7k8",
    "method": "orange_money",
    "amount": 18000
  }'
```

---

### POST /webhooks/payment

Webhook pour confirmation de paiement (Phase 2 - Payment providers).

**Authentication** : Non (validé par signature provider)
**Autorisation** : Payment provider signature

**Request Body** (exemple Orange Money) :
```json
{
  "transactionId": "OM123456789",
  "orderId": "65d1e2f3g4h5i6j7k8",
  "amount": 18000,
  "status": "SUCCESS",
  "signature": "abc123...",
  "timestamp": "2026-02-06T11:05:00Z"
}
```

**Traitement backend** :
1. Vérifier signature du provider
2. Vérifier montant = order.total (INV-5)
3. Idempotence : si déjà payé, ignorer (INV-12)
4. Mettre à jour payment status = "Completed"
5. Mettre à jour order status = "Paid"

**Response 200 OK** :
```json
{
  "success": true,
  "message": "Payment confirmed"
}
```

**Note** : Pour le MVP, cet endpoint n'est pas utilisé (paiement simulé).

---

## Endpoints Shipments

### GET /shipments/:orderId

Récupérer les informations de livraison pour une commande.

**Authentication** : Oui
**Autorisation** : customer (propriétaire), vendor (produit dans commande), admin

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "_id": "65f1g2h3i4j5k6l7m8",
    "orderId": "65d1e2f3g4h5i6j7k8",
    "vendorId": "65a1b2c3d4e5f6789",
    "trackingNumber": "TRACK123456",
    "status": "Shipped",
    "shippedAt": "2026-02-06T12:00:00Z",
    "deliveredAt": null,
    "createdAt": "2026-02-06T12:00:00Z",
    "updatedAt": "2026-02-06T12:00:00Z"
  }
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Pas autorisé
- `404` : Shipment introuvable

**Exemple curl** :
```bash
curl http://localhost:3000/api/shipments/65d1e2f3g4h5i6j7k8 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Endpoints Admin

### GET /admin/stats

Récupérer les statistiques globales de la plateforme.

**Authentication** : Oui
**Autorisation** : admin uniquement

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "users": {
      "total": 1250,
      "customers": 1000,
      "vendors": 250,
      "active": 1200,
      "suspended": 50
    },
    "products": {
      "total": 5000,
      "active": 4500,
      "inactive": 500
    },
    "orders": {
      "total": 3200,
      "pending": 50,
      "paid": 100,
      "shipped": 80,
      "delivered": 2900,
      "cancelled": 70
    },
    "revenue": {
      "total": 45000000,
      "thisMonth": 5000000,
      "lastMonth": 4200000
    }
  }
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Rôle non autorisé

**Exemple curl** :
```bash
curl http://localhost:3000/api/admin/stats \
  -H "Authorization: Bearer ADMIN_TOKEN"
```

---

### GET /admin/users

Lister tous les utilisateurs (admin).

**Authentication** : Oui
**Autorisation** : admin uniquement

**Query Parameters** :
- `page`, `limit` : Pagination
- `role` : Filter par rôle
- `status` : Filter par status

**Response 200 OK** :
```json
{
  "success": true,
  "data": [
    {
      "_id": "65a1b2c3d4e5f6789",
      "email": "user@example.com",
      "role": "customer",
      "profile": { ... },
      "status": "active",
      "createdAt": "2026-02-06T10:00:00Z"
    }
  ],
  "pagination": { ... }
}
```

---

### PATCH /admin/users/:id/suspend

Suspendre un utilisateur.

**Authentication** : Oui
**Autorisation** : admin uniquement

**Request Body** :
```json
{
  "reason": "Violation des conditions d'utilisation"
}
```

**Response 200 OK** :
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "65a1b2c3d4e5f6789",
      "status": "suspended",
      ...
    }
  },
  "message": "User suspended successfully"
}
```

**Errors** :
- `401` : Non authentifié
- `403` : Pas admin
- `404` : Utilisateur introuvable

---

## Codes d'erreur

### Codes HTTP standardisés

| Code | Nom | Usage | Exemple |
|------|-----|-------|---------|
| 400 | Bad Request | Données invalides | `{"error": {"code": "VALIDATION_ERROR", "message": "Email format invalid"}}` |
| 401 | Unauthorized | Token manquant/invalide | `{"error": {"code": "UNAUTHORIZED", "message": "No token provided"}}` |
| 403 | Forbidden | Rôle insuffisant | `{"error": {"code": "FORBIDDEN", "message": "Vendor access required"}}` |
| 404 | Not Found | Ressource introuvable | `{"error": {"code": "NOT_FOUND", "message": "Product not found"}}` |
| 409 | Conflict | Invariant violé | `{"error": {"code": "INVARIANT_VIOLATED", "message": "INV-1: Stock cannot be negative"}}` |
| 422 | Unprocessable Entity | Validation métier échouée | `{"error": {"code": "BUSINESS_RULE_VIOLATED", "message": "Cannot delete product with active orders"}}` |
| 500 | Internal Server Error | Erreur serveur | `{"error": {"code": "INTERNAL_ERROR", "message": "An unexpected error occurred"}}` |

### Codes d'erreur métier

| Code | Message | Cause |
|------|---------|-------|
| `EMAIL_ALREADY_EXISTS` | Email already registered | Registration avec email existant |
| `INVALID_CREDENTIALS` | Invalid email or password | Login échoué |
| `ACCOUNT_SUSPENDED` | Account is suspended | Compte suspendu |
| `INSUFFICIENT_STOCK` | Insufficient stock available | INV-1 violé |
| `INVALID_ORDER_TOTAL` | Order total mismatch | INV-3 violé |
| `ORDER_NOT_PAID` | Order must be paid before shipping | INV-6 violé |
| `NOT_PRODUCT_OWNER` | You are not the owner of this product | Ownership check failed |
| `PAYMENT_AMOUNT_MISMATCH` | Payment amount does not match order total | INV-5 violé |
| `PRODUCT_IN_ACTIVE_ORDERS` | Cannot delete product with active orders | FR-10 violé |

### Format d'erreur avec détails

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email format is invalid"
      },
      {
        "field": "password",
        "message": "Password must be at least 8 characters"
      }
    ]
  }
}
```

---

## Flows complets

### Flow 1 : Customer crée une commande et paye

```
1. Customer s'authentifie
   POST /auth/login
   → Reçoit JWT token

2. Customer browse les produits
   GET /products?category=poterie
   → Liste des produits

3. Customer voit détails d'un produit
   GET /products/65b1c2d3e4f5g6h7i8
   → Détails + stock disponible

4. Customer crée une commande
   POST /orders
   Body: {items: [{productId, quantity}], shippingAddress}
   → Order créé (status: Pending)
   → Stock réservé atomiquement
   → Payment record créé (status: Pending)

5. Customer paye
   POST /payments
   Body: {orderId, method: "orange_money", amount}
   → Payment confirmé (status: Completed)
   → Order status → "Paid"

6. Customer suit sa commande
   GET /orders/65d1e2f3g4h5i6j7k8
   → Détails de la commande
```

### Flow 2 : Vendor traite une commande

```
1. Vendor s'authentifie
   POST /auth/login
   → JWT token

2. Vendor voit les commandes avec ses produits
   GET /orders
   → Liste des commandes (filtrées par vendorId dans items)

3. Vendor voit détails d'une commande
   GET /orders/65d1e2f3g4h5i6j7k8
   → Détails de la commande

4. Vendor expédie la commande
   PATCH /orders/65d1e2f3g4h5i6j7k8/ship
   Body: {trackingNumber: "TRACK123"}
   → Order status → "Shipped"
   → Shipment créé

5. Customer confirme réception
   PATCH /orders/65d1e2f3g4h5i6j7k8/delivered
   → Order status → "Delivered"
```

### Flow 3 : Vendor crée un produit

```
1. Vendor s'authentifie
   POST /auth/login
   → JWT token

2. Vendor récupère les catégories
   GET /categories
   → Liste des catégories disponibles

3. Vendor crée le produit
   POST /products
   Body: {categoryId, name, description, price, stock}
   → Produit créé (vendorId auto depuis JWT)

4. Vendor upload des images
   POST /products/65b1c2d3e4f5g6h7i8/images
   FormData: images[]
   → Images uploadées et URLs retournées

5. Vendor met à jour le stock
   PATCH /products/65b1c2d3e4f5g6h7i8
   Body: {stock: 20}
   → Stock mis à jour
```

---

## Notes d'implémentation

### Backend (the-y4nn)

**Checklist par endpoint** :
- [ ] Implémenter la route dans `routes/`
- [ ] Ajouter middleware auth si nécessaire
- [ ] Ajouter middleware RBAC
- [ ] Ajouter middleware ownership si nécessaire
- [ ] Ajouter middleware invariants
- [ ] Implémenter controller
- [ ] Implémenter service avec logique métier
- [ ] Implémenter repository
- [ ] Ajouter tests unitaires (service)
- [ ] Ajouter tests d'intégration (API)
- [ ] Tester avec Postman
- [ ] Documenter dans ce fichier si changements

### Frontend (Mourina & Eliezer)

**Checklist par endpoint** :
- [ ] Créer model Dart avec JSON serialization
- [ ] Créer méthode dans Repository
- [ ] Implémenter appel API dans Service
- [ ] Gérer erreurs avec try/catch
- [ ] Ajouter au Provider si state management nécessaire
- [ ] Créer UI qui consomme l'endpoint
- [ ] Tester avec backend local
- [ ] Gérer loading states
- [ ] Gérer error states

### Communication

**Avant de coder** :
1. Vérifier que l'endpoint est documenté dans ce fichier
2. Si changement nécessaire : discussion d'équipe
3. Mettre à jour ce document
4. Implémenter

**Pendant le dev** :
- Backend : Tester avec Postman, partager collection
- Frontend : Pointer vers backend local (localhost:3000)

**Après implémentation** :
- Backend : Merge dans main
- Frontend : Pull main, tester intégration

---

**Document Version** : 1.0.0
**Dernière mise à jour** : 2026-02-06
**Maintenu par** : the-y4nn (Backend), Mourina & Eliezer (Frontend)
