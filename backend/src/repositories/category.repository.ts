import { Category } from '../models/Category';

export const CategoryRepository = {
  create: (data: Record<string, unknown>) => Category.create(data),
  list: () => Category.find().sort({ name: 1 }),
  findById: (id: string) => Category.findById(id),
  findBySlug: (slug: string) => Category.findOne({ slug })
};
