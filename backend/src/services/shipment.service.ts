import { Shipment } from '../models/Shipment';
import { Order } from '../models/Order';
import { ApiError } from '../utils/ApiError';

export const ShipmentService = {
  async getByOrderId(orderId: string, requester: { id: string; role: string }) {
    const order = await Order.findById(orderId);
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

    const shipment = await Shipment.findOne({ orderId });
    if (!shipment) {
      throw new ApiError(404, 'NOT_FOUND', 'Shipment not found');
    }
    return shipment;
  }
};
