# SahelArt — Product Requirements Document (PRD)

## 1. Product Overview

**Product Name:** SahelArt  
**Product Type:** Multi-vendor Artisan E-Commerce Marketplace  
**Product Vision:** Build a digital marketplace that enables artisans in Burkina Faso and the Sahel region to sell their products online in a structured, trustworthy, and scalable environment.

SahelArt is not merely an online shop. It is a digital infrastructure designed to formalize, structure, and modernize local artisan commerce.

---

## 2. Problem Statement

### 2.1 Current Situation

Local artisans face structural limitations:

- Limited physical reach (sales depend on local markets)
- No structured digital presence
- Informal inventory management
- No reliable order tracking
- Limited payment flexibility
- Low visibility beyond their immediate geography

Customers face friction:

- Difficulty discovering authentic local products
- No centralized trusted marketplace
- No delivery tracking
- No standardized purchasing process

### 2.2 Core Problem

There is no structured digital platform dedicated to connecting Sahel-region artisans with customers in a predictable, transparent, and scalable manner.

---

## 3. Product Objective

SahelArt exists to:

1. Digitize artisan commerce.
2. Provide structured vendor management tools.
3. Enable secure customer purchasing workflows.
4. Establish trust through order, payment, and delivery transparency.

Success means replacing informal trade processes with a robust digital contract between vendors and customers.

---

## 4. Target Users

### 4.1 Primary Users

**Artisans (Vendors)**
- Sell handmade products
- Manage inventory
- Track orders
- Monitor revenue

**Customers**
- Discover local artisan products
- Purchase items
- Track orders

### 4.2 Secondary Users

**Administrators**
- Moderate content
- Monitor transactions
- Handle disputes
- Maintain platform integrity

---

## 5. Product Scope

### 5.1 Core Features (In Scope)

#### 1. Vendor Onboarding
- Vendor registration
- Profile creation
- Vendor verification

#### 2. Product Management
- Create product
- Update product
- Upload images
- Set pricing
- Manage stock
- Categorize products

#### 3. Customer Experience
- Product browsing
- Search & filtering
- Product details view
- Add to cart
- Checkout process

#### 4. Order Management
- Order creation
- Order status tracking
- Order history
- Vendor order dashboard

#### 5. Payments
- Payment initiation
- Payment confirmation
- Payment status tracking

#### 6. Delivery Tracking
- Shipment status update
- Delivery confirmation

#### 7. Vendor Dashboard
- View revenue summary
- Manage inventory
- View active and past orders

---

### 5.2 Out of Scope (Phase 1)

- AI recommendations
- Cross-border logistics integration
- Advanced fraud detection
- Micro-lending services
- Real-time GPS tracking

These may be considered in future iterations.

---

## 6. System Contract (High-Level)

### 6.1 Actors

- Customer
- Vendor
- Administrator

### 6.2 Capabilities

Customers MAY:
- Browse products
- Create orders
- Pay for orders
- Track order status

Vendors MAY:
- Create and manage products
- Accept and process orders
- Update delivery status

Administrators MAY:
- Suspend vendors
- Moderate products
- Access system-wide reports

### 6.3 Guarantees (Invariants)

- An order MUST belong to a valid customer.
- An order MUST contain at least one valid product.
- A product MUST belong to exactly one vendor.
- A vendor MUST NOT access another vendor’s data.
- Payment amount MUST equal the total order value.
- Stock MUST NOT go below zero.

### 6.4 Explicit Refusals

The system MUST refuse:

- Creating orders with unavailable stock
- Modifying orders after confirmed payment (except via defined workflow)
- Access to protected routes without authentication
- Deleting products tied to active orders

---

## 7. Success Metrics

The system will be considered successful if:

- Vendors can independently list and manage products
- Customers can complete purchases without manual intervention
- Orders are consistently traceable from creation to delivery
- Payment discrepancies are minimized
- Platform uptime remains stable

Quantitative indicators (Phase 1 targets):

- ≥ 50 registered vendors
- ≥ 500 products listed
- ≥ 200 completed orders
- < 2% failed transactions

---

## 8. Risks & Assumptions

### Assumptions

- Vendors have access to smartphones or web devices.
- Customers are willing to adopt digital purchasing.
- Payment integration partners are available.

### Risks

- Low digital literacy among vendors
- Logistics coordination challenges
- Payment system instability
- Fraud attempts

Mitigation requires strong onboarding flows and administrative oversight.

---

## 9. Long-Term Vision

SahelArt may evolve into:

- A regional Sahel-wide artisan marketplace
- A logistics coordination hub
- A financial enablement platform
- A data-driven artisan analytics system

The architecture decisions must preserve this scalability potential.

---

## 10. Engineering Principle Reminder

This PRD defines the **Problem and Intent**.

It does NOT define:
- Database schema
- API endpoints
- UI design
- Technology stack

Those belong to later stages in the engineering decision hierarchy.

SahelArt must be designed before it is implemented.

Code is replaceable.
The contract is not.

