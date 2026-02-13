# SahelArt Market API - Bruno Collection

Complete API test collection for the SahelArt Market backend.

## 🚀 Quick Start

1. **Install Bruno**: Download from [usebruno.com](https://www.usebruno.com/)
2. **Open Collection**: File → Open Collection → Select the `bruno/` folder
3. **Select Environment**: Choose "local" from the environment dropdown
4. **Run Workflow**: Follow the test workflow below

## 📋 Environment Variables

Located in `environments/local.bru`:

```
baseUrl: http://localhost:3000/api/v1
customerEmail: fatou@sahelart.com
vendorEmail: moussa@sahelart.com
adminEmail: admin@sahelart.com
```

Variables auto-populate via post-response scripts as you run requests.

## 🔄 Complete Test Workflow

### Phase 1: Setup & Authentication

1. **Register Customer** (`auth/register-customer.bru`)
   - Creates customer account
   - Auto-saves `accessToken` & `refreshToken`

2. **Register Vendor** (`auth/register-vendor.bru`)
   - Creates vendor account
   - Auto-saves `vendorToken`

3. **Login Admin** (manual setup required)
   - First, create admin via MongoDB:
     ```bash
     make db-shell
     # In mongosh:
     use sahelart
     db.users.updateOne(
       { email: "admin@sahelart.com" },
       { $set: { role: "admin" } }
     )
     ```
   - Then run `auth/login.bru` with admin credentials
   - Auto-saves `adminToken`

### Phase 2: Categories

4. **List Categories** (`categories/list-categories.bru`)
   - Fetches all available categories
   - Auto-saves first `categoryId` for product creation

### Phase 3: Products

5. **Create Product** (`products/create-product.bru`)
   - Vendor creates a product
   - Auto-saves `productId`

6. **Upload Images** (`products/upload-images.bru`) ⚠️ *New*
   - Upload product images (max 5)
   - Update file paths in request body
   - Validates: format (JPEG/PNG/WebP), size (5MB max), dimensions (400x400 min)

7. **List Products** (`products/list-products.bru`)
   - View all active products
   - Supports filtering & pagination

8. **Get Product** (`products/get-product.bru`)
   - Get single product details

9. **Update Product** (`products/update-product.bru`)
   - Vendor updates their product

10. **Delete Product** (`products/delete-product.bru`)
    - Vendor deletes their product (if no active orders)

### Phase 4: Orders & Payments

11. **Create Order** (`orders/create-order.bru`)
    - Customer creates order
    - Auto-saves `orderId`
    - Reserves stock atomically

12. **Create Payment** (`payments/create-payment.bru`)
    - Pay for the order
    - Marks order as "Paid"
    - Amount must match order total (INV-5)

13. **Mark Shipped** (`orders/mark-shipped.bru`)
    - Vendor ships the order
    - Optional tracking number
    - Only works on "Paid" orders (INV-6)

14. **Mark Delivered** (`orders/mark-delivered.bru`)
    - Customer confirms delivery
    - Only works on "Shipped" orders

15. **Get Shipment** (`shipments/get-shipment.bru`)
    - Check shipment status

### Phase 5: AI Features ⚠️ *New*

**Requires**: `GEMINI_API_KEY` set in backend `.env`

16. **Enhance Description** (`ai/enhance-description.bru`)
    - Generates rich FR/EN product descriptions
    - Includes Sahel cultural context
    - Uses 24h cache

17. **Analyze Image** (`ai/analyze-image.bru`)
    - Extracts categories, tags, description from image
    - Supports vision analysis

18. **Recommendations** (`ai/recommendations.bru`)
    - Personalized product recommendations
    - Based on customer order history

19. **Admin Insights** (`ai/admin-insights.bru`)
    - Business insights & recommendations
    - Analyzes platform statistics

### Phase 6: Admin Operations

20. **Stats** (`admin/stats.bru`)
    - Platform-wide statistics

21. **List Users** (`admin/list-users.bru`)
    - List all users
    - Filter by role/status

22. **Suspend User** (`admin/suspend-user.bru`)
    - Suspend a user account

### Phase 7: Other Operations

23. **Cancel Order** (`orders/cancel-order.bru`)
    - Cancel pending order
    - Restores stock

24. **Update Profile** (`users/update-profile.bru`)
    - Update user profile

25. **Payment Webhook** (`webhooks/payment-webhook.bru`)
    - Simulates payment provider webhook
    - Requires HMAC signature

26. **Logout** (`auth/logout.bru`)
    - Revokes refresh token

27. **Refresh Token** (`auth/refresh.bru`)
    - Get new access token

28. **Me** (`auth/me.bru`)
    - Get current user info

## 🆕 New Features in This Release

### Security & Optimization
- ✅ **CORS whitelist** - Configured via `ALLOWED_ORIGINS` env var
- ✅ **Enhanced upload validation** - FileFilter + filename sanitization
- ✅ **Rate limiting** - API-wide (100/15min), Webhooks (10/min)
- ✅ **Request size limit** - 10KB JSON body max
- ✅ **ObjectId validation** - All `:id` params validated
- ✅ **Compression** - Gzip enabled
- ✅ **Production error masking** - No stack traces leaked

### Real-time (Socket.IO)
- ✅ **WebSocket events** for orders, payments, products
- ✅ **Room-based notifications** (customer, vendor, admin)
- ✅ **JWT authentication** for Socket.IO handshake
- Connect: `io('http://localhost:3000', { auth: { token: 'your-jwt' } })`

### AI Features (Gemini 2.5 Flash)
- ✅ **Description enhancement** - FR/EN with cultural context
- ✅ **Image analysis** - Categories, tags, descriptions
- ✅ **Recommendations** - Personalized product suggestions
- ✅ **Admin insights** - Business intelligence & recommendations
- ✅ **Smart caching** - 24h TTL, retry with exponential backoff

## 🔒 Authentication

Most endpoints require authentication via Bearer token:

```http
Authorization: Bearer {{accessToken}}
```

**Roles**:
- **Customer**: Create orders, view own orders, recommendations
- **Vendor**: Create products, upload images, ship orders, AI tools
- **Admin**: All operations, user management, insights

## 📊 Key System Invariants

These are enforced by the backend (see `docs/sahel_art_system_contract_and_invariants.md`):

- **INV-1**: Stock cannot be negative
- **INV-2**: Order must contain ≥1 product
- **INV-3**: Order total = sum of item subtotals
- **INV-4**: Stock reservation is atomic (MongoDB transactions)
- **INV-5**: Payment amount must equal order total
- **INV-6**: Cannot ship unpaid orders

## 🛠️ Tips

1. **Token Chain**: Tokens auto-populate via scripts. Run requests in order for smooth workflow.

2. **Rate Limiting**: Bypassed in test mode. In production:
   - API: 100 req/15min per IP
   - Webhooks: 10 req/min per IP
   - Auth: 50 req/15min per IP

3. **Image Upload**: Update file paths in `upload-images.bru` to point to actual images.

4. **AI Features**: Set `GEMINI_API_KEY` in backend `.env` to enable AI endpoints.

5. **Real-time Events**: Use a Socket.IO client to listen for events:
   ```javascript
   const io = require('socket.io-client');
   const socket = io('http://localhost:3000', {
     auth: { token: 'your-access-token' }
   });

   socket.on('order:created', (data) => console.log('New order!', data));
   socket.on('payment:completed', (data) => console.log('Payment!', data));
   ```

6. **Webhook Signature**: Payment webhook requires HMAC-SHA256 signature:
   ```javascript
   const crypto = require('crypto');
   const payload = `${transactionId}.${orderId}.${amount}.${status}`;
   const signature = crypto.createHmac('sha256', WEBHOOK_SECRET)
     .update(payload)
     .digest('hex');
   ```

## 📁 Collection Structure

```
bruno/
├── ai/                    # AI endpoints (NEW)
│   ├── enhance-description.bru
│   ├── analyze-image.bru
│   ├── recommendations.bru
│   └── admin-insights.bru
├── admin/                 # Admin operations
├── auth/                  # Authentication
├── categories/            # Product categories
├── orders/                # Order management
├── payments/              # Payment processing
├── products/              # Product CRUD
│   └── upload-images.bru  # NEW: Image upload
├── shipments/             # Shipment tracking
├── users/                 # User profile
├── webhooks/              # Payment webhooks
└── environments/
    └── local.bru          # Local dev config
```

## 🐛 Troubleshooting

**401 Unauthorized**
- Token expired (15min TTL) → Use refresh endpoint
- Wrong role → Check endpoint requirements

**400 Validation Error**
- Check request body against schema
- Ensure ObjectId format for IDs

**409 Conflict**
- Invariant violation (check error message)
- Stock insufficient or order status invalid

**503 Service Unavailable (AI)**
- `GEMINI_API_KEY` not set
- API quota exceeded
- Network issues

## 📚 Documentation

- **API Spec**: `docs/API.md`
- **Architecture**: `docs/ARCHITECTURE.md`, `backend/ARCHITECTURE.md`
- **Contract**: `docs/sahel_art_system_contract_and_invariants.md`
- **Contributing**: `CONTRIBUTING.md`

## 🔗 Related

- **Backend**: Node.js 20 + Express + TypeScript + MongoDB
- **Socket.IO**: Real-time events on port 3000
- **AI**: Gemini 2.5 Flash (vision + text)
- **Storage**: Local filesystem (uploads/) or configure S3

---

**Happy Testing! 🚀**

For issues or questions, see `CONTRIBUTING.md` or create an issue.
