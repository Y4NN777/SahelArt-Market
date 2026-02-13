# 🎯 Bruno API Testing Session - Complete Guide

**Estimated Time**: 30-60 minutes
**Goal**: Verify all endpoints work, validate documentation accuracy, prepare for Flutter integration

---

## 📋 Pre-Session Checklist

```bash
# 1. Ensure Docker is running
make up

# 2. Verify API is healthy
curl http://localhost:3000/api/v1/health
# Expected: {"status":"ok"}

# 3. Check AI is enabled
docker logs sahelart-api 2>&1 | grep "AI features enabled"
# Expected: "AI features enabled with Gemini"

# 4. Open Bruno
# Download from: https://www.usebruno.com/
# Import collection: bruno/ folder
# Select environment: "local"
```

---

## 🎬 Session Workflow

### Phase 1: Authentication (5 min)
**Goal**: Create test accounts and verify auth flow

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 1 | `auth/register-customer.bru` | ✅ Status 201<br>✅ Returns `accessToken` & `refreshToken`<br>✅ Token auto-saved to env | Email: `fatou@sahelart.com` |
| 2 | `auth/register-vendor.bru` | ✅ Status 201<br>✅ `vendorToken` auto-saved<br>✅ `passwordHash` NOT in response | Email: `moussa@sahelart.com` |
| 3 | `auth/me.bru` | ✅ Status 200<br>✅ Returns user profile<br>✅ No `passwordHash` field | Uses customer token |
| 4 | `auth/refresh.bru` | ✅ Status 200<br>✅ New `accessToken` returned<br>✅ Cookie set | Tests token refresh |

**⚠️ Manual Step**: Create admin account
```bash
# In terminal:
docker exec -it sahelart-mongo mongosh sahelart --eval \
  'db.users.updateOne(
    {email: "admin@sahelart.com"},
    {$set: {role: "admin"}},
    {upsert: false}
  )'

# If no admin exists, register one first then update
```

| 5 | `auth/login.bru` | ✅ Status 200<br>✅ `adminToken` auto-saved | Use admin credentials |

**📝 Notes**:
- [ ] Tokens auto-populate correctly?
- [ ] `passwordHash` never appears in responses?
- [ ] Error messages clear when password wrong?

---

### Phase 2: Categories (2 min)
**Goal**: Verify category listing works

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 6 | `categories/list-categories.bru` | ✅ Status 200<br>✅ Returns array of categories<br>✅ `categoryId` auto-saved | No auth required |

**📝 Notes**:
- [ ] At least one category returned?
- [ ] `categoryId` variable populated?

---

### Phase 3: Products (10 min)
**Goal**: Full product CRUD + image upload

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 7 | `products/create-product.bru` | ✅ Status 201<br>✅ Product created<br>✅ `productId` auto-saved | Uses `vendorToken` |
| 8 | `products/list-products.bru` | ✅ Status 200<br>✅ New product in list<br>✅ Pagination object present | Public endpoint |
| 9 | `products/get-product.bru` | ✅ Status 200<br>✅ Full product details | Uses `productId` |
| 10 | `products/update-product.bru` | ✅ Status 200<br>✅ Changes reflected | Vendor can update own product |
| 11 | `products/upload-images.bru` | ⚠️ **Manual**: Update file paths<br>✅ Status 200<br>✅ Image URLs returned | See instructions below |
| 12 | `products/delete-product.bru` | ⏭️ **SKIP for now** | We need this product for orders |

**🖼️ Image Upload Instructions**:
1. Prepare 1-2 test images (JPEG/PNG/WebP, >400x400px)
2. In Bruno: Edit `upload-images.bru`
3. Remove `~` from file paths (enables them)
4. Update paths to your test images
5. Send request

**📝 Notes**:
- [ ] Create works with vendor auth?
- [ ] Returns 403 when customer tries?
- [ ] Pagination format correct?
- [ ] Image upload validates file types?
- [ ] ObjectId validation working? (Try invalid `productId`)

---

### Phase 4: Orders & Payments (8 min)
**Goal**: Complete purchase flow

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 13 | `orders/create-order.bru` | ✅ Status 201<br>✅ Order & payment created<br>✅ `orderId` auto-saved<br>✅ Stock decremented | Uses customer token |
| 14 | `orders/list-orders.bru` | ✅ Status 200<br>✅ New order visible<br>✅ Pagination works | Customer sees their orders |
| 15 | `orders/get-order.bru` | ✅ Status 200<br>✅ Full order details<br>✅ Status: "Pending" | |
| 16 | `payments/create-payment.bru` | ✅ Status 201<br>✅ Order status → "Paid"<br>✅ Payment completed | Amount must match order total |
| 17 | `orders/mark-shipped.bru` | ✅ Status 200<br>✅ Order status → "Shipped"<br>✅ Shipment created | Uses vendor token |
| 18 | `orders/mark-delivered.bru` | ✅ Status 200<br>✅ Order status → "Delivered" | Customer confirms delivery |
| 19 | `shipments/get-shipment.bru` | ✅ Status 200<br>✅ Shipment details<br>✅ Tracking info | Uses `orderId` |

**📝 Notes**:
- [ ] Can't ship before payment? (INV-6)
- [ ] Payment amount mismatch rejected? (INV-5)
- [ ] Stock went negative? (should fail - INV-1)
- [ ] Order total = sum of items? (INV-3)

**🧪 Test Invariants**:
Try these to verify protection:
```
# Test INV-6: Ship unpaid order (should fail 409)
- Skip payment step, try mark-shipped directly

# Test INV-5: Wrong payment amount (should fail 409)
- In create-payment, change amount to different value

# Test INV-1: Negative stock (should fail 409)
- Create order with quantity > available stock
```

---

### Phase 5: AI Features (10 min) ⭐ NEW
**Goal**: Verify all AI endpoints work with real Gemini API

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 20 | `ai/enhance-description.bru` | ✅ Status 200<br>✅ Returns `fr` & `en` descriptions<br>✅ Cultural context present<br>⏱️ Takes 3-10s | Vendor/Admin only |
| 21 | `ai/analyze-image.bru` | ✅ Status 200<br>✅ Returns categories, tags, description<br>⏱️ Takes 3-10s | Uses base64 image |
| 22 | `ai/recommendations.bru` | ✅ Status 200<br>✅ Returns empty array (no order history yet)<br>⚡ Fast (<1s) | Customer only |
| 23 | `ai/admin-insights.bru` | ✅ Status 200<br>✅ Returns summary, insights, recommendations<br>⏱️ Takes 5-15s | Admin only |

**📝 Notes**:
- [ ] Descriptions mention "Sahel" or cultural terms?
- [ ] FR description is in French?
- [ ] EN description is in English?
- [ ] Both >100 words?
- [ ] Image analysis makes sense?
- [ ] Admin insights are relevant?
- [ ] Returns 503 if API key missing?
- [ ] Second call faster (cache hit)?

**🧪 Test Cache**:
- Run `enhance-description` twice with same product
- Second call should be instant (<100ms)

**🧪 Test Auth**:
- Try AI endpoints with customer token (should fail 403)

---

### Phase 6: Admin Operations (5 min)
**Goal**: Verify admin functionality

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 24 | `admin/stats.bru` | ✅ Status 200<br>✅ Returns counts & stats | Admin only |
| 25 | `admin/list-users.bru` | ✅ Status 200<br>✅ Pagination format<br>✅ No `passwordHash` | Filter by role works? |
| 26 | `admin/suspend-user.bru` | ✅ Status 200<br>✅ User suspended | Can't login after? |

**📝 Notes**:
- [ ] Non-admin gets 403?
- [ ] User list properly paginated?
- [ ] Suspended user can't login?

---

### Phase 7: Edge Cases & Cleanup (5 min)
**Goal**: Test error handling

| # | Request | What to Check | Notes |
|---|---------|---------------|-------|
| 27 | `orders/cancel-order.bru` | ✅ Status 200 (if Pending)<br>✅ Stock restored | Only works on Pending orders |
| 28 | `auth/logout.bru` | ✅ Status 200<br>✅ Token revoked | Can't use after logout |
| 29 | `webhooks/payment-webhook.bru` | ⚠️ Needs signature calculation | See webhook docs |

**🧪 Error Testing**:
```bash
# Test invalid ObjectId
curl http://localhost:3000/api/v1/products/invalid-id
# Expected: 400 "Invalid id format"

# Test rate limiting (in production mode)
# Make 101 requests in 15 min - should hit limit

# Test CORS
curl -H "Origin: http://evil.com" http://localhost:3000/api/v1/health
# Should reject if ALLOWED_ORIGINS is set
```

---

## 📊 Session Completion Checklist

### Core Functionality
- [ ] Authentication flow works (register, login, refresh, me)
- [ ] Customer can create orders
- [ ] Vendor can create products & ship orders
- [ ] Admin can view stats & manage users
- [ ] Payment processing works
- [ ] Order status transitions correctly (Pending → Paid → Shipped → Delivered)

### New Features
- [ ] AI description enhancement works
- [ ] AI image analysis works
- [ ] AI recommendations work (customer)
- [ ] AI admin insights work
- [ ] Caching working (second AI call faster)

### Security & Validation
- [ ] `passwordHash` never exposed
- [ ] ObjectId validation working
- [ ] Role-based access control working (RBAC)
- [ ] Invariants enforced (INV-1 through INV-6)
- [ ] File upload validation works

### Documentation Quality
- [ ] All requests have clear descriptions
- [ ] Variable auto-population works
- [ ] Examples are realistic
- [ ] Error responses are documented

---

## 🐛 Issues Found Template

**Use this to track any issues**:

```markdown
## Issue 1: [Brief description]
- **Request**: auth/register-customer.bru
- **Expected**: Token auto-saved
- **Actual**: Variable not populated
- **Fix needed**: Update post-response script

## Issue 2: [Brief description]
...
```

---

## 📄 Post-Session: Create Frontend Integration Guide

**After Bruno session, create** `docs/FRONTEND_INTEGRATION.md`:

```markdown
# Frontend Integration Guide

## Authentication
[Copy working examples from Bruno]

## Product Management
[Copy working examples]

## Order Flow
[Document the complete flow you just tested]

## AI Features
[Document AI integration patterns]

## Socket.IO Integration
[Include connection example]

## Common Pitfalls
[Document any issues you found]
```

---

## 🎯 Success Criteria

**Session is successful if**:
✅ All 28 core requests work as documented
✅ All 4 AI endpoints return valid responses
✅ Invariants are enforced (tried to break them, couldn't)
✅ RBAC working (customers can't do vendor actions)
✅ Documentation matches reality
✅ You understand the complete API flow
✅ Confident to hand off to Flutter team

---

## ⏱️ Time Breakdown

- **Setup**: 5 min
- **Phase 1-3**: 15 min (Auth → Categories → Products)
- **Phase 4**: 8 min (Orders & Payments)
- **Phase 5**: 10 min (AI Features) ⭐
- **Phase 6-7**: 10 min (Admin & Edge Cases)
- **Documentation**: 10 min (Write findings)

**Total**: ~60 min

---

## 🚀 Ready?

**Start with**:
1. `make up` (ensure Docker is running)
2. Open Bruno → Import `bruno/` folder
3. Select "local" environment
4. Begin with Phase 1: `auth/register-customer.bru`

**Good luck! You've got this! 🎉**

Save any issues/notes - we'll review and update docs in the next session before Flutter work begins.

---

## 📞 Quick Reference

### Environment Variables (bruno/environments/local.bru)
```
baseUrl: http://localhost:3000/api/v1
customerEmail: fatou@sahelart.com
vendorEmail: moussa@sahelart.com
adminEmail: admin@sahelart.com
```

### Common Issues & Solutions

**Issue**: Token not auto-saved
- **Solution**: Check post-response script in request

**Issue**: 401 Unauthorized
- **Solution**: Token expired (15min TTL), use refresh endpoint

**Issue**: 400 Invalid ObjectId
- **Solution**: Check that IDs are properly formatted MongoDB ObjectIds

**Issue**: 503 AI Service Error
- **Solution**: Verify `GEMINI_API_KEY` is set in Docker environment

**Issue**: 409 Conflict
- **Solution**: Invariant violation - check error message for which one

---

## 📚 Additional Resources

- **API Spec**: `docs/API.md`
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md`
- **Bruno Collection README**: `bruno/README.md`
- **Architecture**: `backend/ARCHITECTURE.md`
- **System Contract**: `docs/sahel_art_system_contract_and_invariants.md`

---

**Next Session**: Flutter frontend integration with Socket.IO and AI features!
