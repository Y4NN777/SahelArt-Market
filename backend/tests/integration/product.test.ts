import { request } from '../helpers/app.helper';
import { createAuthenticatedUser } from '../helpers/auth.helper';
import { createTestCategory, createTestProduct } from '../helpers/fixtures';

describe('Product API', () => {
  describe('POST /api/v1/products', () => {
    it('should allow vendor to create a product', async () => {
      const { token, user } = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();

      const res = await request()
        .post('/api/v1/products')
        .set('Authorization', `Bearer ${token}`)
        .send({
          categoryId: category.id,
          name: 'Masque Dogon',
          description: 'Masque cérémoniel traditionnel sculpté à la main',
          price: 75000,
          stock: 3
        });

      expect(res.status).toBe(201);
      expect(res.body.data.name).toBe('Masque Dogon');
      expect(res.body.data.vendorId).toBe(user.id);
    });

    it('should deny customer from creating a product', async () => {
      const { token } = await createAuthenticatedUser({ role: 'customer' });
      const category = await createTestCategory();

      const res = await request()
        .post('/api/v1/products')
        .set('Authorization', `Bearer ${token}`)
        .send({
          categoryId: category.id,
          name: 'Test Product',
          description: 'Some description for a test product here',
          price: 1000,
          stock: 1
        });

      expect(res.status).toBe(403);
    });

    it('should return 400 for validation errors', async () => {
      const { token } = await createAuthenticatedUser({ role: 'vendor' });

      const res = await request()
        .post('/api/v1/products')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'AB' });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/products', () => {
    it('should return only active products for public listing', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      await createTestProduct(vendor.user.id, category.id, { name: 'Active Bogolan', status: 'active' });
      await createTestProduct(vendor.user.id, category.id, { name: 'Inactive Bogolan', status: 'inactive' });

      const res = await request().get('/api/v1/products');

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
      expect(res.body.data[0].name).toBe('Active Bogolan');
    });

    it('should filter by category', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const cat1 = await createTestCategory({ name: 'Tissage', slug: 'tissage' });
      const cat2 = await createTestCategory({ name: 'Bijoux', slug: 'bijoux' });
      await createTestProduct(vendor.user.id, cat1.id, { name: 'Tissu' });
      await createTestProduct(vendor.user.id, cat2.id, { name: 'Bracelet' });

      const res = await request().get(`/api/v1/products?category=${cat1.id}`);

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
      expect(res.body.data[0].name).toBe('Tissu');
    });

    it('should filter by price range', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      await createTestProduct(vendor.user.id, category.id, { name: 'Cheap', price: 5000 });
      await createTestProduct(vendor.user.id, category.id, { name: 'Expensive', price: 100000 });

      const res = await request().get('/api/v1/products?minPrice=10000&maxPrice=200000');

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(1);
      expect(res.body.data[0].name).toBe('Expensive');
    });

    it('should support pagination', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      for (let i = 0; i < 3; i++) {
        await createTestProduct(vendor.user.id, category.id, { name: `Product ${i}` });
      }

      const res = await request().get('/api/v1/products?page=1&limit=2');

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(2);
      expect(res.body.pagination.total).toBe(3);
      expect(res.body.pagination.hasNext).toBe(true);
    });
  });

  describe('GET /api/v1/products/:id', () => {
    it('should return a product by id', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      const product = await createTestProduct(vendor.user.id, category.id);

      const res = await request().get(`/api/v1/products/${product.id}`);

      expect(res.status).toBe(200);
      expect(res.body.data._id).toBe(product.id);
    });

    it('should return 404 for inactive product (public)', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      const product = await createTestProduct(vendor.user.id, category.id, { status: 'inactive' });

      const res = await request().get(`/api/v1/products/${product.id}`);

      expect(res.status).toBe(404);
    });
  });

  describe('PATCH /api/v1/products/:id', () => {
    it('should allow vendor to update own product', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      const product = await createTestProduct(vendor.user.id, category.id);

      const res = await request()
        .patch(`/api/v1/products/${product.id}`)
        .set('Authorization', `Bearer ${vendor.token}`)
        .send({ price: 30000 });

      expect(res.status).toBe(200);
      expect(res.body.data.price).toBe(30000);
    });

    it('should deny vendor from updating another vendor product', async () => {
      const vendor1 = await createAuthenticatedUser({ role: 'vendor', email: 'v1@test.com' });
      const vendor2 = await createAuthenticatedUser({ role: 'vendor', email: 'v2@test.com' });
      const category = await createTestCategory();
      const product = await createTestProduct(vendor1.user.id, category.id);

      const res = await request()
        .patch(`/api/v1/products/${product.id}`)
        .set('Authorization', `Bearer ${vendor2.token}`)
        .send({ price: 99999 });

      expect(res.status).toBe(403);
    });
  });

  describe('DELETE /api/v1/products/:id', () => {
    it('should delete a product with no active orders', async () => {
      const vendor = await createAuthenticatedUser({ role: 'vendor' });
      const category = await createTestCategory();
      const product = await createTestProduct(vendor.user.id, category.id);

      const res = await request()
        .delete(`/api/v1/products/${product.id}`)
        .set('Authorization', `Bearer ${vendor.token}`);

      expect(res.status).toBe(200);
    });
  });
});
