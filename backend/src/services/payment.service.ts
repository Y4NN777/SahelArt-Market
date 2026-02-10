import crypto from 'crypto';
import { Payment } from '../models/Payment';
import { Order } from '../models/Order';
import { ApiError } from '../utils/ApiError';

const generateTxnId = () => `TXN-${crypto.randomBytes(8).toString('hex')}`;

export const PaymentService = {
  async create(data: { orderId: string; method: string; amount: number; customerId: string }) {
    const order = await Order.findById(data.orderId);
    if (!order) {
      throw new ApiError(404, 'NOT_FOUND', 'Order not found');
    }
    if (order.customerId.toString() !== data.customerId) {
      throw new ApiError(403, 'FORBIDDEN', 'Not allowed');
    }
    if (order.status === 'Paid') {
      throw new ApiError(409, 'ORDER_ALREADY_PAID', 'Order already paid');
    }
    if (order.status !== 'Pending') {
      throw new ApiError(409, 'INVALID_ORDER_STATUS', 'Order cannot be paid');
    }
    if (order.total !== data.amount) {
      throw new ApiError(409, 'PAYMENT_AMOUNT_MISMATCH', 'INV-5: Payment amount does not match order total');
    }

    let payment = await Payment.findOne({ orderId: order.id });
    if (payment && payment.status === 'Completed') {
      throw new ApiError(409, 'ORDER_ALREADY_PAID', 'Order already paid');
    }

    if (!payment) {
      payment = await Payment.create({
        orderId: order.id,
        customerId: data.customerId,
        amount: data.amount,
        method: data.method,
        status: 'Completed',
        transactionId: generateTxnId()
      });
    } else {
      payment.method = data.method as any;
      payment.amount = data.amount;
      payment.status = 'Completed';
      payment.transactionId = generateTxnId();
      await payment.save();
    }

    order.status = 'Paid';
    await order.save();

    return { payment, order };
  },

  async webhook(payload: { orderId: string; amount: number; status: string; transactionId: string }, signature?: string) {
    const secret = process.env.PAYMENT_WEBHOOK_SECRET || '';
    if (secret) {
      const expected = crypto
        .createHmac('sha256', secret)
        .update(`${payload.transactionId}.${payload.orderId}.${payload.amount}.${payload.status}`)
        .digest('hex');
      if (!signature || signature !== expected) {
        throw new ApiError(401, 'UNAUTHORIZED', 'Invalid signature');
      }
    }

    if (payload.status !== 'SUCCESS') {
      throw new ApiError(400, 'PAYMENT_FAILED', 'Payment not successful');
    }

    const order = await Order.findById(payload.orderId);
    if (!order) {
      throw new ApiError(404, 'NOT_FOUND', 'Order not found');
    }
    if (order.total !== payload.amount) {
      throw new ApiError(409, 'PAYMENT_AMOUNT_MISMATCH', 'INV-5: Payment amount does not match order total');
    }

    let payment = await Payment.findOne({ orderId: order.id });
    if (!payment) {
      payment = await Payment.create({
        orderId: order.id,
        customerId: order.customerId,
        amount: payload.amount,
        method: 'orange_money',
        status: 'Completed',
        transactionId: payload.transactionId
      });
    } else if (payment.status !== 'Completed') {
      payment.status = 'Completed';
      payment.transactionId = payload.transactionId;
      await payment.save();
    }

    if (order.status !== 'Paid') {
      order.status = 'Paid';
      await order.save();
    }

    return { payment, order };
  }
};
