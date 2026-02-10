import slugify from 'slugify';
import { Category } from '../models/Category';
import { ApiError } from '../utils/ApiError';

export const CategoryService = {
  async list() {
    return Category.find().sort({ name: 1 });
  },

  async create(data: { name: string; description: string }) {
    const slug = slugify(data.name, { lower: true, strict: true });
    const existing = await Category.findOne({ slug });
    if (existing) {
      throw new ApiError(409, 'VALIDATION_ERROR', 'Category already exists');
    }
    return Category.create({ name: data.name, description: data.description, slug });
  }
};
