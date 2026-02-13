import mongoose from 'mongoose';
import { Order } from '../models/Order';
import { Product } from '../models/Product';
import { Payment } from '../models/Payment';
import { Shipment } from '../models/Shipment';
import { User } from '../models/User';
import { ApiError } from '../utils/ApiError';
import { EmailService } from './email.service';
import { RealtimeService } from './realtime.service';

export const OrderService = {
  async create(data: {
    customerId: string;
    items: { productId: string; quantity: number }[];
    shippingAddress: {
      street: string;
      city: string;
      postalCode?: string;
      country: string;
      phone: string;
    };
  }) {
    if (!data.items || data.items.length === 0) {
      throw new ApiError(409, 'INVARIANT_VIOLATED', 'INV-2: Order must contain at least one product');
    }

    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const orderItems = [] as any[];
      let total = 0;

      for (const item of data.items) {
        if (item.quantity <= 0) {
          throw new ApiError(400, 'VALIDATION_ERROR', 'Quantity must be > 0');
        }
        const product = await Product.findById(item.productId).session(session);
        if (!product) {
          throw new ApiError(404, 'NOT_FOUND', 'Product not found');
        }
        if (product.status !== 'active') {
          throw new ApiError(404, 'NOT_FOUND', 'Product not found');
        }
        if (product.stock < item.quantity) {
          throw new ApiError(409, 'INSUFFICIENT_STOCK', 'INV-1: Insufficient stock');
        }
        const subtotal = product.price * item.quantity;
        total += subtotal;
        orderItems.push({
          productId: product.id,
          vendorId: product.vendorId,
          name: product.name,
          price: product.price,
          quantity: item.quantity,
          subtotal
        });
        product.stock -= item.quantity;
        await product.save({ session });
      }

      const orderDoc = await Order.create(
        [
          {
            customerId: data.customerId,
            items: orderItems,
            total,
            status: 'Pending',
            shippingAddress: data.shippingAddress
          }
        ],
        { session }
      );

      const paymentDoc = await Payment.create(
        [
          {
            orderId: orderDoc[0].id,
            customerId: data.customerId,
            amount: total,
            method: 'orange_money',
            status: 'Pending'
          }
        ],
        { session }
      );

      await session.commitTransaction();

      User.findById(data.customerId).then((customer) => {
        if (customer) {
          EmailService.sendOrderConfirmation(
            customer.email,
            orderDoc[0].id,
            orderItems.map((i) => ({ name: i.name, quantity: i.quantity, subtotal: i.subtotal })),
            total
          ).catch(() => {});
        }
      }).catch(() => {});

      RealtimeService.emitToUser(data.customerId, 'order:created', { orderId: orderDoc[0].id });
      RealtimeService.emitToAdmin('order:created', { orderId: orderDoc[0].id, customerId: data.customerId });

      const vendorIds = [...new Set(orderItems.map((item) => item.vendorId.toString()))];
      for (const vendorId of vendorIds) {
        RealtimeService.emitToVendor(vendorId, 'order:created', { orderId: orderDoc[0].id });

        const vendorItems = orderItems.filter((item) => item.vendorId.toString() === vendorId);
        for (const item of vendorItems) {
          const product = await Product.findById(item.productId);
          if (product && product.stock < 5) {
            RealtimeService.emitToVendor(vendorId, 'product:low_stock', {
              productId: product.id,
              productName: product.name,
              stock: product.stock
            });
          }
        }
      }

      return { order: orderDoc[0], payment: paymentDoc[0] };
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  },

  async list({ userId, role, status, page, limit }: { userId: string; role: string; status?: string; page: number; limit: number }) {
    const filter: any = {};
    if (status) filter.status = status;
    if (role === 'customer') {
      filter.customerId = userId;
    } else if (role === 'vendor') {
      filter['items.vendorId'] = userId;
    }

    const skip = (page - 1) * limit;
    const [data, total] = await Promise.all([
      Order.find(filter).skip(skip).limit(limit).sort({ createdAt: -1 }),
      Order.countDocuments(filter)
    ]);

    return {
      data,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
        hasNext: page * limit < total,
        hasPrev: page > 1
      }
    };
  },

  async getById(id: string, requester: { id: string; role: string }) {
    const order = await Order.findById(id);
    if (!order) {
      throw new ApiError(404, 'NOT_FOUND', 'Order not found');
    }
    if (requester.role === 'customer' && order.customerId.toString() !== requester.id) {
      throw new ApiError(403, 'FORBIDDEN', 'Not allowed');
    }
    if (requester.role === 'vendor') {
      const hasItem = order.items.some((item) => item.vendorId.toString() === requester.id);
      if (!hasItem) {
        throw new ApiError(403, 'FORBIDDEN', 'Not allowed');
      }
    }
    return order;
  },

  async markShipped(orderId: string, requester: { id: string; role: string }, trackingNumber?: string) {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new ApiError(404, 'NOT_FOUND', 'Order not found');
    }
    if (order.status !== 'Paid') {
      throw new ApiError(409, 'ORDER_NOT_PAID', 'INV-6: Order must be paid before shipping');
    }
    if (requester.role === 'vendor') {
      const hasItem = order.items.some((item) => item.vendorId.toString() === requester.id);
      if (!hasItem) {
        throw new ApiError(403, 'FORBIDDEN', 'Not allowed');
      }
    }

    order.status = 'Shipped';
    await order.save();

    let shipment = await Shipment.findOne({ orderId: order.id });
    if (!shipment) {
      shipment = await Shipment.create({
        orderId: order.id,
        vendorId: requester.role === 'vendor' ? requester.id : order.items[0].vendorId,
        trackingNumber,
        status: 'Shipped',
        shippedAt: new Date()
      });
    } else {
      shipment.status = 'Shipped';
      shipment.trackingNumber = trackingNumber || shipment.trackingNumber;
      shipment.shippedAt = new Date();
      await shipment.save();
    }

    User.findById(order.customerId).then((customer) => {
      if (customer) {
        EmailService.sendOrderShipped(customer.email, orderId, trackingNumber).catch(() => {});
      }
    }).catch(() => {});

    RealtimeService.emitToUser(order.customerId.toString(), 'order:shipped', {
      orderId: order.id,
      trackingNumber
    });

    return { order, shipment };
  },

  async markDelivered(orderId: string, requester: { id: string; role: string }) {
    const order = await Order.findById(orderId);
    if (!order) {
      throw new ApiError(404, 'NOT_FOUND', 'Order not found');
    }
    if (order.status !== 'Shipped') {
      throw new ApiError(409, 'INVALID_ORDER_STATUS', 'Order must be shipped before delivery');
    }
    if (requester.role === 'customer' && order.customerId.toString() !== requester.id) {
      throw new ApiError(403, 'FORBIDDEN', 'Not allowed');
    }

    order.status = 'Delivered';
    await order.save();

    const shipment = await Shipment.findOne({ orderId: order.id });
    if (shipment) {
      shipment.status = 'Delivered';
      shipment.deliveredAt = new Date();
      await shipment.save();
    }

    User.findById(order.customerId).then((customer) => {
      if (customer) {
        EmailService.sendOrderDelivered(customer.email, orderId).catch(() => {});
      }
    }).catch(() => {});

    RealtimeService.emitToUser(order.customerId.toString(), 'order:delivered', { orderId: order.id });

    return { order, shipment };
  },

  async cancel(orderId: string, requester: { id: string; role: string }) {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const order = await Order.findById(orderId).session(session);
      if (!order) {
        throw new ApiError(404, 'NOT_FOUND', 'Order not found');
      }
      if (requester.role === 'customer' && order.customerId.toString() !== requester.id) {
        throw new ApiError(403, 'FORBIDDEN', 'Not allowed');
      }
      if (order.status !== 'Pending') {
        throw new ApiError(409, 'INVALID_ORDER_STATUS', 'Order cannot be cancelled');
      }

      for (const item of order.items) {
        const product = await Product.findById(item.productId).session(session);
        if (product) {
          product.stock += item.quantity;
          await product.save({ session });
        }
      }

      order.status = 'Cancelled';
      await order.save({ session });

      await session.commitTransaction();

      RealtimeService.emitToUser(order.customerId.toString(), 'order:cancelled', { orderId: order.id });

      const vendorIds = [...new Set(order.items.map((item) => item.vendorId.toString()))];
      for (const vendorId of vendorIds) {
        RealtimeService.emitToVendor(vendorId, 'order:cancelled', { orderId: order.id });
      }

      return order;
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }
};
