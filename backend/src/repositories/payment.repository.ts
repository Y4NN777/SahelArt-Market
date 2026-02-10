import { Payment } from '../models/Payment';

export const PaymentRepository = {
  create: (data: Record<string, unknown>, session?: any) => Payment.create([{ ...data }], { session }),
  findByOrderId: (orderId: string) => Payment.findOne({ orderId }),
  updateById: (id: string, data: Record<string, unknown>) =>
    Payment.findByIdAndUpdate(id, data, { new: true })
};
