import { Request, Response } from 'express';
import path from 'path';
import sharp from 'sharp';
import { ProductService } from '../services/product.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';
import { parsePagination } from '../utils/validators';
import { ApiError } from '../utils/ApiError';

const validateImages = async (files: Express.Multer.File[]) => {
  for (const file of files) {
    if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Invalid image format');
    }
    const metadata = await sharp(file.path).metadata();
    if ((metadata.width || 0) < 400 || (metadata.height || 0) < 400) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'Image dimensions too small');
    }
  }
};

export const ProductController = {
  list: asyncHandler(async (req: Request, res: Response) => {
    const { page, limit } = parsePagination(req.query.page as string, req.query.limit as string);
    const result = await ProductService.list({
      page,
      limit,
      category: req.query.category as string,
      minPrice: req.query.minPrice ? Number(req.query.minPrice) : undefined,
      maxPrice: req.query.maxPrice ? Number(req.query.maxPrice) : undefined,
      search: req.query.search as string,
      vendorId: req.query.vendorId as string,
      status: req.query.status as string,
      requesterRole: req.user?.role,
      requesterId: req.user?.id
    });
    return res.status(200).json({
      success: true,
      data: result.data,
      pagination: result.pagination
    });
  }),

  getById: asyncHandler(async (req: Request, res: Response) => {
    const product = await ProductService.getById(req.params.id, { role: req.user?.role, id: req.user?.id });
    return sendSuccess(res, product);
  }),

  create: asyncHandler(async (req: Request, res: Response) => {
    const product = await ProductService.create({
      vendorId: req.user!.id,
      categoryId: req.body.categoryId,
      name: req.body.name,
      description: req.body.description,
      price: req.body.price,
      stock: req.body.stock,
      images: req.body.images || []
    });
    return sendSuccess(res, product, 'Product created successfully', 201);
  }),

  update: asyncHandler(async (req: Request, res: Response) => {
    const product = await ProductService.update(req.params.id, req.body, { role: req.user!.role, id: req.user!.id });
    return sendSuccess(res, product, 'Product updated successfully');
  }),

  remove: asyncHandler(async (req: Request, res: Response) => {
    await ProductService.delete(req.params.id, { role: req.user!.role, id: req.user!.id });
    return sendSuccess(res, null, 'Product deleted successfully');
  }),

  uploadImages: asyncHandler(async (req: Request, res: Response) => {
    const files = (req.files as Express.Multer.File[]) || [];
    if (files.length === 0) {
      throw new ApiError(400, 'VALIDATION_ERROR', 'No images uploaded');
    }
    await validateImages(files);
    const uploadRoot = path.resolve(process.env.UPLOAD_DIR || 'uploads');
    const paths = files.map((file) => {
      const relative = path.relative(uploadRoot, file.path);
      return `/uploads/${relative}`.replace(/\\/g, '/');
    });
    const images = await ProductService.appendImages(req.params.id, paths, { role: req.user!.role, id: req.user!.id });
    return sendSuccess(res, { images }, 'Images uploaded successfully');
  })
};
