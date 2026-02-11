import { request } from '../helpers/app.helper';
import { createAuthenticatedUser } from '../helpers/auth.helper';
import { createTestCategory, createTestProduct, validShippingAddress } from '../helpers/fixtures';
import { Product } from '../../src/models/Product';

describe('Order API', () => {
  const createOrderScenario = async () => {
    const customer = await createAuthenticatedUser({ role: 'customer', email: 'order-cust@test.com' });
    const vendor = await createAuthenticatedUser({ role: 'vendor', email: 'order-vendor@test.com' });
    const admin = await createAuthenticatedUser({ role: 'admin', email: 'order-admin@test.com' });
    const category = await createTestCategory();
    const product = await createTestProduct(vendor.user.id, category.id, { stock: 10, price: 15000 });
    return { customer, vendor, admin, category, product };
  };

  describe('POST /api/v1/orders', () => {
    it('should create an order and decrement stock', async () => {
      const { customer, product } = await createOrderScenario();

      const res = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 2 }],
          shippingAddress: validShippingAddress
        });

      expect(res.status).toBe(201);
      expect(res.body.data.order.status).toBe('Pending');
      expect(res.body.data.order.total).toBe(30000);
      expect(res.body.data.payment).toBeDefined();

      const updated = await Product.findById(product.id);
      expect(updated!.stock).toBe(8);
    });

    it('should return 409 for insufficient stock (INV-1)', async () => {
      const { customer, product } = await createOrderScenario();

      const res = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 999 }],
          shippingAddress: validShippingAddress
        });

      expect(res.status).toBe(409);
      expect(res.body.error.code).toBe('INSUFFICIENT_STOCK');
    });

    it('should return 400 for empty items (Joi validates INV-2)', async () => {
      const { customer } = await createOrderScenario();

      const res = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [],
          shippingAddress: validShippingAddress
        });

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/orders', () => {
    it('should let customer see only own orders', async () => {
      const { customer, product } = await createOrderScenario();
      const otherCustomer = await createAuthenticatedUser({ role: 'customer', email: 'other@test.com' });

      await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const res = await request()
        .get('/api/v1/orders')
        .set('Authorization', `Bearer ${otherCustomer.token}`);

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveLength(0);
    });

    it('should let admin see all orders', async () => {
      const { customer, admin, product } = await createOrderScenario();

      await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const res = await request()
        .get('/api/v1/orders')
        .set('Authorization', `Bearer ${admin.token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThanOrEqual(1);
    });
  });

  describe('GET /api/v1/orders/:id', () => {
    it('should return 403 for cross-customer access', async () => {
      const { customer, product } = await createOrderScenario();
      const otherCustomer = await createAuthenticatedUser({ role: 'customer', email: 'intruder@test.com' });

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const res = await request()
        .get(`/api/v1/orders/${orderRes.body.data.order._id}`)
        .set('Authorization', `Bearer ${otherCustomer.token}`);

      expect(res.status).toBe(403);
    });
  });

  describe('PATCH /api/v1/orders/:id/ship', () => {
    it('should ship a paid order', async () => {
      const { customer, vendor, product } = await createOrderScenario();

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      // Pay the order
      await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          orderId: orderRes.body.data.order._id,
          method: 'orange_money',
          amount: orderRes.body.data.order.total
        });

      const res = await request()
        .patch(`/api/v1/orders/${orderRes.body.data.order._id}/ship`)
        .set('Authorization', `Bearer ${vendor.token}`)
        .send({ trackingNumber: 'TRK-SAHEL-001' });

      expect(res.status).toBe(200);
      expect(res.body.data.order.status).toBe('Shipped');
    });

    it('should return 409 when order is not paid (INV-6)', async () => {
      const { customer, vendor, product } = await createOrderScenario();

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const res = await request()
        .patch(`/api/v1/orders/${orderRes.body.data.order._id}/ship`)
        .set('Authorization', `Bearer ${vendor.token}`);

      expect(res.status).toBe(409);
      expect(res.body.error.code).toBe('ORDER_NOT_PAID');
    });
  });

  describe('PATCH /api/v1/orders/:id/delivered', () => {
    it('should mark shipped order as delivered', async () => {
      const { customer, vendor, product } = await createOrderScenario();

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const orderId = orderRes.body.data.order._id;

      await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({ orderId, method: 'orange_money', amount: orderRes.body.data.order.total });

      await request()
        .patch(`/api/v1/orders/${orderId}/ship`)
        .set('Authorization', `Bearer ${vendor.token}`);

      const res = await request()
        .patch(`/api/v1/orders/${orderId}/delivered`)
        .set('Authorization', `Bearer ${customer.token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.order.status).toBe('Delivered');
    });

    it('should return 409 when order is not shipped', async () => {
      const { customer, product } = await createOrderScenario();

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const res = await request()
        .patch(`/api/v1/orders/${orderRes.body.data.order._id}/delivered`)
        .set('Authorization', `Bearer ${customer.token}`);

      expect(res.status).toBe(409);
    });
  });

  describe('PATCH /api/v1/orders/:id/cancel', () => {
    it('should cancel a pending order and restore stock', async () => {
      const { customer, product } = await createOrderScenario();

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 3 }],
          shippingAddress: validShippingAddress
        });

      const res = await request()
        .patch(`/api/v1/orders/${orderRes.body.data.order._id}/cancel`)
        .set('Authorization', `Bearer ${customer.token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.status).toBe('Cancelled');

      const updated = await Product.findById(product.id);
      expect(updated!.stock).toBe(10);
    });

    it('should return 409 when order is not pending', async () => {
      const { customer, vendor, product } = await createOrderScenario();

      const orderRes = await request()
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          items: [{ productId: product.id, quantity: 1 }],
          shippingAddress: validShippingAddress
        });

      const orderId = orderRes.body.data.order._id;

      // Pay the order
      await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({ orderId, method: 'orange_money', amount: orderRes.body.data.order.total });

      const res = await request()
        .patch(`/api/v1/orders/${orderId}/cancel`)
        .set('Authorization', `Bearer ${customer.token}`);

      expect(res.status).toBe(409);
    });
  });
});
