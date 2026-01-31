# SahelArt — Software Requirements Specification (SRS)

## 1. Introduction

This document defines the formal, verifiable, and implementation-independent requirements for the SahelArt system.

It specifies what the system MUST do and MUST NOT do, without describing how it is implemented.

---

## 2. System Scope

SahelArt is a multi-vendor e-commerce platform enabling artisans to list products and customers to purchase them through a structured digital workflow.

The system acts as an intermediary enforcing transactional integrity, data isolation, and order traceability.

---

## 3. Actors

### 3.1 Human Actors

- Customer
- Vendor
- Administrator

### 3.2 External Systems

- Payment Service Provider
- Notification Service (Email/SMS)

---

## 4. Functional Requirements

### 4.1 Authentication & Authorization

FR-1: The System MUST allow a user to register as a Customer.

FR-2: The System MUST allow a user to register as a Vendor.

FR-3: The System MUST authenticate users before granting access to protected resources.

FR-4: The System MUST enforce role-based access control.

FR-5: A Vendor MUST NOT access data belonging to another Vendor.

FR-6: A Customer MUST NOT access administrative interfaces.

---

### 4.2 Vendor Management

FR-7: The System MUST allow a Vendor to create a product.

FR-8: The System MUST allow a Vendor to update product information.

FR-9: The System MUST allow a Vendor to deactivate a product.

FR-10: The System MUST prevent deletion of a product associated with an active order.

---

### 4.3 Product Browsing

FR-11: The System MUST allow Customers to view available products.

FR-12: The System MUST allow Customers to search products by name or category.

FR-13: The System MUST display product price and stock availability.

FR-14: The System MUST NOT display inactive products to Customers.

---

### 4.4 Cart & Order Management

FR-15: The System MUST allow a Customer to add available products to a cart.

FR-16: The System MUST validate stock availability before confirming an order.

FR-17: The System MUST create an Order upon successful checkout.

FR-18: An Order MUST contain at least one product.

FR-19: An Order MUST be associated with exactly one Customer.

FR-20: The System MUST assign a unique identifier to each Order.

FR-21: The System MUST support the following Order states:
- Pending
- Paid
- Shipped
- Delivered
- Cancelled

FR-22: The System MUST enforce valid state transitions.

FR-23: An Order MUST NOT transition directly from Pending to Delivered.

---

### 4.5 Payment Processing

FR-24: The System MUST initiate payment through a Payment Service Provider.

FR-25: The System MUST verify payment confirmation before marking an Order as Paid.

FR-26: The System MUST ensure payment amount equals total order value.

FR-27: The System MUST prevent duplicate payment confirmation from altering order state more than once.

FR-28: An Order MUST NOT transition to Shipped unless marked as Paid.

---

### 4.6 Delivery Tracking

FR-29: The System MUST allow Vendors to update order shipment status.

FR-30: The System MUST allow Customers to view real-time order status.

FR-31: Only a Vendor associated with the Order MAY update shipment status.

---

### 4.7 Administrative Controls

FR-32: The System MUST allow Administrators to suspend Vendors.

FR-33: The System MUST allow Administrators to remove inappropriate products.

FR-34: The System MUST log administrative actions.

---

## 5. Business Rules

BR-1: A Product MUST belong to exactly one Vendor.

BR-2: Product stock MUST NOT fall below zero.

BR-3: Order total MUST equal the sum of product prices multiplied by quantities.

BR-4: A suspended Vendor MUST NOT create new products.

BR-5: A suspended Vendor MUST NOT process new orders.

BR-6: Customer data MUST remain isolated from other Customers.

---

## 6. Non-Functional Requirements

### 6.1 Security

NFR-1: All protected endpoints MUST require authentication.

NFR-2: Sensitive data MUST NOT be transmitted in plain text.

NFR-3: The System MUST log authentication attempts.

---

### 6.2 Performance

NFR-4: The System MUST respond to standard API requests within 500 milliseconds under normal load.

NFR-5: The System MUST support at least 500 concurrent users without degradation of core functionality.

---

### 6.3 Reliability

NFR-6: The System MUST preserve order data integrity in the event of unexpected shutdown.

NFR-7: Payment confirmation processing MUST be idempotent.

---

## 7. Error Handling Requirements

ER-1: The System MUST return a clear error when stock is insufficient.

ER-2: The System MUST reject malformed input.

ER-3: The System MUST return an authorization error when access is forbidden.

ER-4: If the Payment Service Provider is unavailable, the System MUST keep the Order in Pending state.

ER-5: If an internal failure occurs during order creation, the System MUST roll back partial operations.

---

## 8. Compliance Criteria

The system shall be considered compliant when:

- All MUST requirements are validated through automated or manual testing.
- All state transitions are enforceable and testable.
- All access control rules are verifiable.

---

## 9. Implementation Independence Clause

This document does not prescribe:

- Programming language
- Database engine
- Framework
- Deployment model

All requirements are independent of technological choices.

---

End of SahelArt SRS.

