import crypto from 'crypto';
import { request } from '../helpers/app.helper';
import { createAuthenticatedUser } from '../helpers/auth.helper';
import { createTestCategory, createTestProduct, validShippingAddress } from '../helpers/fixtures';

describe('Payment API', () => {
  const createPaidScenario = async () => {
    const customer = await createAuthenticatedUser({ role: 'customer', email: 'pay-cust@test.com' });
    const vendor = await createAuthenticatedUser({ role: 'vendor', email: 'pay-vendor@test.com' });
    const category = await createTestCategory();
    const product = await createTestProduct(vendor.user.id, category.id, { stock: 20, price: 10000 });

    const orderRes = await request()
      .post('/api/v1/orders')
      .set('Authorization', `Bearer ${customer.token}`)
      .send({
        items: [{ productId: product.id, quantity: 2 }],
        shippingAddress: validShippingAddress
      });

    if (orderRes.status !== 201) {
      throw new Error(`Order creation failed: ${orderRes.status} ${JSON.stringify(orderRes.body)}`);
    }

    return { customer, vendor, product, order: orderRes.body.data.order, payment: orderRes.body.data.payment };
  };

  describe('POST /api/v1/payments', () => {
    it('should pay an order and mark it as Paid', async () => {
      const { customer, order } = await createPaidScenario();

      const res = await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          orderId: order._id,
          method: 'orange_money',
          amount: order.total
        });

      expect(res.status).toBe(201);
      expect(res.body.data.order.status).toBe('Paid');
      expect(res.body.data.payment.status).toBe('Completed');
    });

    it('should return 409 for amount mismatch (INV-5)', async () => {
      const { customer, order } = await createPaidScenario();

      const res = await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({
          orderId: order._id,
          method: 'orange_money',
          amount: 1
        });

      expect(res.status).toBe(409);
      expect(res.body.error.code).toBe('PAYMENT_AMOUNT_MISMATCH');
    });

    it('should return 409 for already paid order', async () => {
      const { customer, order } = await createPaidScenario();

      await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({ orderId: order._id, method: 'orange_money', amount: order.total });

      const res = await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${customer.token}`)
        .send({ orderId: order._id, method: 'wave', amount: order.total });

      expect(res.status).toBe(409);
    });

    it('should return 403 for wrong customer', async () => {
      const { order } = await createPaidScenario();
      const otherCustomer = await createAuthenticatedUser({ role: 'customer', email: 'other-pay@test.com' });

      const res = await request()
        .post('/api/v1/payments')
        .set('Authorization', `Bearer ${otherCustomer.token}`)
        .send({ orderId: order._id, method: 'orange_money', amount: order.total });

      expect(res.status).toBe(403);
    });
  });

  describe('POST /api/v1/webhooks/payment', () => {
    it('should process valid webhook and update order', async () => {
      const { order } = await createPaidScenario();
      const txnId = 'TXN-webhook-001';
      const secret = process.env.PAYMENT_WEBHOOK_SECRET || 'test-webhook-secret';

      const signature = crypto
        .createHmac('sha256', secret)
        .update(`${txnId}.${order._id}.${order.total}.SUCCESS`)
        .digest('hex');

      const res = await request()
        .post('/api/v1/webhooks/payment')
        .send({
          transactionId: txnId,
          orderId: order._id,
          amount: order.total,
          status: 'SUCCESS',
          signature
        });

      expect(res.status).toBe(200);
    });

    it('should return 401 for invalid signature', async () => {
      const { order } = await createPaidScenario();

      const res = await request()
        .post('/api/v1/webhooks/payment')
        .send({
          transactionId: 'TXN-bad',
          orderId: order._id,
          amount: order.total,
          status: 'SUCCESS',
          signature: 'invalid-signature'
        });

      expect(res.status).toBe(401);
    });
  });
});
