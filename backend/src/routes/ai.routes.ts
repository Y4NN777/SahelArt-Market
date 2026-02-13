import { Router, Request, Response } from 'express';
import Joi from 'joi';
import { requireAuth } from '../middleware/auth';
import { allowRoles } from '../middleware/rbac';
import { validate } from '../middleware/validation';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess, sendError } from '../utils/ApiResponse';
import { AIService } from '../services/ai.service';
import { Order } from '../models/Order';
import { Product } from '../models/Product';
import { Category } from '../models/Category';

const router = Router();

const enhanceDescriptionSchema = Joi.object({
  name: Joi.string().required(),
  categoryName: Joi.string().required(),
  existingDescription: Joi.string().optional()
});

const analyzeImageSchema = Joi.object({
  imageBase64: Joi.string().required(),
  mimeType: Joi.string().valid('image/jpeg', 'image/png', 'image/webp').required()
});

router.post(
  '/enhance-description',
  requireAuth,
  allowRoles('vendor', 'admin'),
  validate(enhanceDescriptionSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const { name, categoryName, existingDescription } = req.body;
    const result = await AIService.enhanceProductDescription(name, categoryName, existingDescription);

    if (!result.success) {
      return sendError(res, 503, 'AI_SERVICE_ERROR', result.error || 'AI service unavailable');
    }

    return sendSuccess(res, result.data, 'Description enhanced successfully');
  })
);

router.post(
  '/analyze-image',
  requireAuth,
  allowRoles('vendor', 'admin'),
  validate(analyzeImageSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const { imageBase64, mimeType } = req.body;
    const result = await AIService.analyzeProductImage(imageBase64, mimeType);

    if (!result.success) {
      return sendError(res, 503, 'AI_SERVICE_ERROR', result.error || 'AI service unavailable');
    }

    return sendSuccess(res, result.data, 'Image analyzed successfully');
  })
);

router.get(
  '/recommendations',
  requireAuth,
  allowRoles('customer'),
  asyncHandler(async (req: Request, res: Response) => {
    const userId = req.user!.id;

    const orders = await Order.find({ customerId: userId }).limit(20).sort({ createdAt: -1 });

    const productIds = orders.flatMap((order) => order.items.map((item: any) => item.productId));
    const products = await Product.find({ _id: { $in: productIds } }).populate('categoryId');

    const orderHistory = products.map((product: any) => ({
      productName: product.name,
      categoryName: product.categoryId?.name || 'Unknown'
    }));

    if (orderHistory.length === 0) {
      return sendSuccess(res, { recommendations: [] }, 'No order history available for recommendations');
    }

    const result = await AIService.generateRecommendations(userId, orderHistory);

    if (!result.success) {
      return sendError(res, 503, 'AI_SERVICE_ERROR', result.error || 'AI service unavailable');
    }

    return sendSuccess(res, result.data, 'Recommendations generated successfully');
  })
);

router.get(
  '/insights',
  requireAuth,
  allowRoles('admin'),
  asyncHandler(async (req: Request, res: Response) => {
    const totalOrders = await Order.countDocuments();
    const totalProducts = await Product.countDocuments({ status: 'active' });

    const revenueAgg = await Order.aggregate([
      { $match: { status: { $in: ['Paid', 'Shipped', 'Delivered'] } } },
      { $group: { _id: null, total: { $sum: '$total' } } }
    ]);
    const totalRevenue = revenueAgg[0]?.total || 0;

    const vendorsAgg = await Product.aggregate([
      { $group: { _id: '$vendorId' } },
      { $count: 'total' }
    ]);
    const totalVendors = vendorsAgg[0]?.total || 0;

    const categoriesAgg = await Product.aggregate([
      { $group: { _id: '$categoryId', count: { $sum: 1 } } },
      { $sort: { count: -1 } },
      { $limit: 5 }
    ]);

    const categoryIds = categoriesAgg.map((c) => c._id);
    const categories = await Category.find({ _id: { $in: categoryIds } });
    const categoryMap = new Map(categories.map((c: any) => [c._id.toString(), c.name]));

    const topCategories = categoriesAgg.map((c) => ({
      name: categoryMap.get(c._id.toString()) || 'Unknown',
      count: c.count
    }));

    const stats = {
      totalOrders,
      totalRevenue,
      totalProducts,
      totalVendors,
      topCategories,
      recentTrends: 'Growing interest in traditional textiles and handcrafted jewelry'
    };

    const result = await AIService.generateAdminInsights(stats);

    if (!result.success) {
      return sendError(res, 503, 'AI_SERVICE_ERROR', result.error || 'AI service unavailable');
    }

    return sendSuccess(res, result.data, 'Insights generated successfully');
  })
);

export default router;
