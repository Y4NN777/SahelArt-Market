# 🎨 Authentication UI - Modern Refactor

## 📁 Architecture

### Register Flow (NEW! ✨)

Nouvelle architecture modulaire et maintenable avec design moderne 2026.

```
presentation/
├── login_page.dart                    # Login (152 lignes vs 546)
├── register_page.dart                 # OLD - À SUPPRIMER
├── splash_page.dart                   # Splash screen
│
├── pages/                             # NEW Register Flow
│   ├── role_selection_page.dart      # Sélection Customer/Vendor
│   ├── customer_register_page.dart   # Register Customer (simple)
│   └── vendor_register_page.dart     # Register Vendor (stepper 2 étapes)
│
├── styles/
│   └── auth_styles.dart              # Design tokens centralisés
│
└── widgets/                           # Composants réutilisables
    ├── auth_background_hero.dart     # Background avec gradient moderne
    ├── auth_branding_header.dart     # Logo et branding cohérent
    ├── auth_glass_card.dart          # Glassmorphism card (desktop)
    ├── auth_input_field.dart         # Input fields avec animations
    ├── login_form_content.dart       # Formulaire de connexion
    ├── mobile_auth_sheet.dart        # Bottom sheet animée (mobile)
    └── mobile_hero_header.dart       # Hero header mobile
```

---

## ✨ Améliorations

### Architecture
- ✅ **Séparation des responsabilités** : Chaque widget a un rôle unique
- ✅ **Réutilisabilité** : Composants partagés (inputs, cards, branding)
- ✅ **Maintenabilité** : Code divisé en petits modules (< 200 lignes)
- ✅ **Testabilité** : Chaque composant testable indépendamment
- ✅ **Lisibilité** : Code clair avec documentation inline

### Design
- 🎨 **Design moderne 2026** avec glassmorphism
- 🎨 **Palette Sahel** : couleurs terres, sables, artisanat
- 🎨 **Micro-interactions** : animations fluides sur inputs
- 🎨 **Hiérarchie visuelle** claire et cohérente
- 🎨 **Responsive** optimisé mobile + desktop
- 🎨 **Accessibilité** : contrastes améliorés, tailles de texte

### Performance
- ⚡ **Moins de rebuilds** : widgets séparés + const constructors
- ⚡ **Animations optimisées** : AnimationController réutilisables
- ⚡ **Lazy loading** : composants chargés à la demande

---

## 🎯 Utilisation

### Design Tokens

Tous les styles sont centralisés dans `auth_styles.dart` :

```dart
// Spacing système
AuthStyles.spacing8
AuthStyles.spacing16
AuthStyles.spacing24

// Couleurs Sahel
AuthStyles.earthBrown
AuthStyles.desertSand
AuthStyles.clayOrange

// Border radius
AuthStyles.radiusMedium
AuthStyles.radiusXLarge

// Animations
AuthStyles.animationNormal
AuthStyles.animationCurve

// Gradients
AuthStyles.backgroundGradient()
AuthStyles.heroGradientOverlay()
```

### Composants réutilisables

#### AuthInputField
Input field avec animations et validation :

```dart
AuthInputField(
  controller: emailController,
  label: 'Email',
  prefixIcon: Icons.email_outlined,
  validator: EmailValidator.validate,
  keyboardType: TextInputType.emailAddress,
)
```

#### AuthBrandingHeader
Branding cohérent sur toutes les pages :

```dart
AuthBrandingHeader(showPill: true) // Pill avec fond
AuthBrandingHeader(showPill: false) // Logo + texte simple
```

#### AuthGlassCard
Card glassmorphism pour desktop :

```dart
AuthGlassCard(
  child: YourContent(),
  blur: 10.0,
  opacity: 0.95,
)
```

---

## 📋 Register Flow

### Architecture du flux d'inscription

```
1. role_selection_page.dart
   │
   ├─→ Customer → customer_register_page.dart
   │              └─ Formulaire simple (1 étape)
   │                 - Prénom, Nom
   │                 - Email, Mot de passe
   │
   └─→ Vendor → vendor_register_page.dart
                └─ Stepper 2 étapes
                   ├─ Étape 1: Infos personnelles
                   │  - Prénom, Nom
                   │  - Email, Mot de passe
                   │
                   └─ Étape 2: Infos business
                      - Nom de boutique
                      - Description activité
                      - Téléphone
```

### Utilisation

```dart
// 1. Afficher la sélection de rôle
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RoleSelectionPage(
      onRoleSelected: (role) {
        if (role == 'customer') {
          // Aller vers CustomerRegisterPage
        } else {
          // Aller vers VendorRegisterPage
        }
      },
      onBackToLogin: () => Navigator.pop(context),
    ),
  ),
);

// 2. Customer Register
CustomerRegisterPage(
  onRegister: ({required firstName, required lastName, ...}) async {
    // Appeler AuthProvider
  },
  onBack: () => Navigator.pop(context),
  loading: false,
)

// 3. Vendor Register (avec stepper)
VendorRegisterPage(
  onRegister: ({required firstName, ..., required businessName, ...}) async {
    // Appeler AuthProvider avec role='vendor'
  },
  onBack: () => Navigator.pop(context),
  loading: false,
)
```

## 🚀 Prochaines étapes

### À faire
- [x] ✅ Créer le register flow moderne (Customer/Vendor)
- [ ] Supprimer l'ancien `register_page.dart`
- [ ] Intégrer avec AuthProvider
- [ ] Créer `forgot_password_page.dart` avec les mêmes composants
- [ ] Ajouter des tests unitaires pour les validators
- [ ] Ajouter des tests widgets pour les composants
- [ ] Améliorer l'accessibilité (screen readers)

### Améliorations potentielles
- Ajouter des animations de transition entre pages
- Support du dark mode
- Internationalisation (i18n)
- Animations de chargement plus élaborées
- Social login buttons (Google, Facebook)

---

## 📝 Notes de développement

### Breakpoints responsive
- Mobile : < 600px
- Tablet : 600px - 899px
- Desktop : >= 900px

### Conventions de nommage
- Widgets publics : `AuthInputField`, `LoginFormContent`
- Widgets privés : `_DecorativeCircle`, `_BrandingPill`
- Constantes : `AuthStyles.spacing16`

### Performance tips
- Utilisez `const` constructors autant que possible
- Évitez les rebuilds inutiles avec `mounted` checks
- Réutilisez les controllers et focus nodes

---

**Refactoré avec ❤️ pour SahelArt Market**
