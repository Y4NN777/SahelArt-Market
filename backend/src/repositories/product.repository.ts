import { Product } from '../models/Product';

export const ProductRepository = {
  create: (data: Record<string, unknown>) => Product.create(data),
  findById: (id: string) => Product.findById(id),
  updateById: (id: string, data: Record<string, unknown>) =>
    Product.findByIdAndUpdate(id, data, { new: true }),
  deleteById: (id: string) => Product.findByIdAndDelete(id),
  list: (filter: Record<string, unknown>, skip: number, limit: number, sort?: Record<string, 1 | -1>) =>
    Product.find(filter).skip(skip).limit(limit).sort(sort || { createdAt: -1 }),
  count: (filter: Record<string, unknown>) => Product.countDocuments(filter)
};
