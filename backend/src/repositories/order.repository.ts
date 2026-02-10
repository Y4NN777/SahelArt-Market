import { Order } from '../models/Order';

export const OrderRepository = {
  create: (data: Record<string, unknown>, session?: any) => Order.create([{ ...data }], { session }),
  findById: (id: string) => Order.findById(id),
  findByIdWithSession: (id: string, session: any) => Order.findById(id).session(session),
  updateById: (id: string, data: Record<string, unknown>) =>
    Order.findByIdAndUpdate(id, data, { new: true }),
  list: (filter: Record<string, unknown>, skip: number, limit: number) =>
    Order.find(filter).skip(skip).limit(limit).sort({ createdAt: -1 }),
  count: (filter: Record<string, unknown>) => Order.countDocuments(filter)
};
