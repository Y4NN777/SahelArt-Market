import { Product } from '../models/Product';
import { Category } from '../models/Category';
import { Order } from '../models/Order';
import { ApiError } from '../utils/ApiError';
import { RealtimeService } from './realtime.service';

export const ProductService = {
  async create(data: {
    vendorId: string;
    categoryId: string;
    name: string;
    description: string;
    price: number;
    stock: number;
    images?: string[];
  }) {
    if (data.stock < 0) {
      throw new ApiError(409, 'INVARIANT_VIOLATED', 'INV-1: Stock cannot be negative');
    }
    const category = await Category.findById(data.categoryId);
    if (!category) {
      throw new ApiError(404, 'NOT_FOUND', 'Category not found');
    }
    const product = await Product.create({
      vendorId: data.vendorId,
      categoryId: data.categoryId,
      name: data.name,
      description: data.description,
      price: data.price,
      stock: data.stock,
      images: data.images || []
    });

    RealtimeService.emitPublic('product:created', {
      productId: product.id,
      name: product.name,
      price: product.price
    });

    return product;
  },

  async list(filters: {
    page: number;
    limit: number;
    category?: string;
    minPrice?: number;
    maxPrice?: number;
    search?: string;
    vendorId?: string;
    status?: string;
    requesterRole?: string;
    requesterId?: string;
  }) {
    const query: Record<string, unknown> = {};

    if (filters.category) query.categoryId = filters.category;
    if (filters.vendorId) query.vendorId = filters.vendorId;
    if (filters.minPrice || filters.maxPrice) {
      query.price = {};
      if (filters.minPrice) (query.price as any).$gte = filters.minPrice;
      if (filters.maxPrice) (query.price as any).$lte = filters.maxPrice;
    }
    if (filters.search) {
      query.$text = { $search: filters.search };
    }

    if (filters.requesterRole === 'admin') {
      if (filters.status) query.status = filters.status;
    } else if (filters.requesterRole === 'vendor') {
      if (filters.vendorId && filters.vendorId === filters.requesterId) {
        if (filters.status) query.status = filters.status;
      } else {
        query.status = 'active';
      }
    } else {
      query.status = 'active';
    }

    const skip = (filters.page - 1) * filters.limit;
    const [data, total] = await Promise.all([
      Product.find(query).skip(skip).limit(filters.limit).sort({ createdAt: -1 }),
      Product.countDocuments(query)
    ]);

    return {
      data,
      pagination: {
        page: filters.page,
        limit: filters.limit,
        total,
        pages: Math.ceil(total / filters.limit),
        hasNext: filters.page * filters.limit < total,
        hasPrev: filters.page > 1
      }
    };
  },

  async getById(id: string, requester?: { role?: string; id?: string }) {
    const product = await Product.findById(id);
    if (!product) {
      throw new ApiError(404, 'NOT_FOUND', 'Product not found');
    }
    if (product.status === 'inactive') {
      const isAdmin = requester?.role === 'admin';
      const isOwner = requester?.role === 'vendor' && requester?.id === product.vendorId.toString();
      if (!isAdmin && !isOwner) {
        throw new ApiError(404, 'NOT_FOUND', 'Product not found');
      }
    }
    return product;
  },

  async update(id: string, data: Record<string, unknown>, requester: { role: string; id: string }) {
    const product = await Product.findById(id);
    if (!product) {
      throw new ApiError(404, 'NOT_FOUND', 'Product not found');
    }
    if (requester.role === 'vendor' && product.vendorId.toString() !== requester.id) {
      throw new ApiError(403, 'FORBIDDEN', 'Not product owner');
    }
    if (data.stock !== undefined && Number(data.stock) < 0) {
      throw new ApiError(409, 'INVARIANT_VIOLATED', 'INV-1: Stock cannot be negative');
    }
    if (data.categoryId) {
      const category = await Category.findById(data.categoryId);
      if (!category) {
        throw new ApiError(404, 'NOT_FOUND', 'Category not found');
      }
    }
    const updated = await Product.findByIdAndUpdate(id, data, { new: true });

    if (updated) {
      RealtimeService.emitPublic('product:updated', {
        productId: updated.id,
        name: updated.name,
        price: updated.price,
        stock: updated.stock,
        status: updated.status
      });
    }

    return updated;
  },

  async delete(id: string, requester: { role: string; id: string }) {
    const product = await Product.findById(id);
    if (!product) {
      throw new ApiError(404, 'NOT_FOUND', 'Product not found');
    }
    if (requester.role === 'vendor' && product.vendorId.toString() !== requester.id) {
      throw new ApiError(403, 'FORBIDDEN', 'Not product owner');
    }
    const activeOrder = await Order.findOne({
      'items.productId': product.id,
      status: { $in: ['Pending', 'Paid', 'Shipped'] }
    });
    if (activeOrder) {
      throw new ApiError(409, 'PRODUCT_IN_ACTIVE_ORDERS', 'Cannot delete product with active orders');
    }
    await Product.findByIdAndDelete(id);
  },

  async appendImages(id: string, images: string[], requester: { role: string; id: string }) {
    const product = await Product.findById(id);
    if (!product) {
      throw new ApiError(404, 'NOT_FOUND', 'Product not found');
    }
    if (requester.role === 'vendor' && product.vendorId.toString() !== requester.id) {
      throw new ApiError(403, 'FORBIDDEN', 'Not product owner');
    }
    const merged = [...product.images, ...images];
    if (merged.length > 5) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Max 5 images allowed');
    }
    product.images = merged;
    await product.save();
    return product.images;
  }
};
