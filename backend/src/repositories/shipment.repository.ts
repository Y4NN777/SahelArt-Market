import { Shipment } from '../models/Shipment';

export const ShipmentRepository = {
  create: (data: Record<string, unknown>, session?: any) => Shipment.create([{ ...data }], { session }),
  findByOrderId: (orderId: string) => Shipment.findOne({ orderId }),
  updateById: (id: string, data: Record<string, unknown>) =>
    Shipment.findByIdAndUpdate(id, data, { new: true })
};
