import mongoose, { Schema } from 'mongoose';

const paymentSchema = new Schema(
  {
    orderId: { type: Schema.Types.ObjectId, ref: 'Order', required: true, index: true },
    customerId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    amount: { type: Number, required: true },
    method: { type: String, enum: ['orange_money', 'wave', 'moov', 'cash'], required: true },
    status: { type: String, enum: ['Pending', 'Completed', 'Failed'], default: 'Pending' },
    transactionId: { type: String },
    providerReference: { type: String }
  },
  { timestamps: true }
);

export const Payment = mongoose.model('Payment', paymentSchema);
