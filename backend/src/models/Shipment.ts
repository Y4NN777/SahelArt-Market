import mongoose, { Schema } from 'mongoose';

const shipmentSchema = new Schema(
  {
    orderId: { type: Schema.Types.ObjectId, ref: 'Order', required: true, index: true },
    vendorId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    trackingNumber: { type: String },
    status: { type: String, enum: ['Preparing', 'Shipped', 'InTransit', 'Delivered'], default: 'Preparing' },
    shippedAt: { type: Date },
    deliveredAt: { type: Date }
  },
  { timestamps: true }
);

export const Shipment = mongoose.model('Shipment', shipmentSchema);
