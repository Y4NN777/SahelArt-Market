import { Request, Response } from 'express';
import { OrderService } from '../services/order.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';
import { parsePagination } from '../utils/validators';

export const OrderController = {
  create: asyncHandler(async (req: Request, res: Response) => {
    const result = await OrderService.create({
      customerId: req.user!.id,
      items: req.body.items,
      shippingAddress: req.body.shippingAddress
    });
    return sendSuccess(res, result, 'Order created successfully', 201);
  }),

  list: asyncHandler(async (req: Request, res: Response) => {
    const { page, limit } = parsePagination(req.query.page as string, req.query.limit as string);
    const result = await OrderService.list({
      userId: req.user!.id,
      role: req.user!.role,
      status: req.query.status as string,
      page,
      limit
    });
    return res.status(200).json({
      success: true,
      data: result.data,
      pagination: result.pagination
    });
  }),

  getById: asyncHandler(async (req: Request, res: Response) => {
    const order = await OrderService.getById(req.params.id, { id: req.user!.id, role: req.user!.role });
    return sendSuccess(res, order);
  }),

  ship: asyncHandler(async (req: Request, res: Response) => {
    const result = await OrderService.markShipped(req.params.id, { id: req.user!.id, role: req.user!.role }, req.body.trackingNumber);
    return sendSuccess(res, result, 'Order marked as shipped');
  }),

  delivered: asyncHandler(async (req: Request, res: Response) => {
    const result = await OrderService.markDelivered(req.params.id, { id: req.user!.id, role: req.user!.role });
    return sendSuccess(res, result, 'Order marked as delivered');
  }),

  cancel: asyncHandler(async (req: Request, res: Response) => {
    const order = await OrderService.cancel(req.params.id, { id: req.user!.id, role: req.user!.role });
    return sendSuccess(res, order, 'Order cancelled successfully');
  })
};
