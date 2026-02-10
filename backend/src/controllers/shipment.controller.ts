import { Request, Response } from 'express';
import { ShipmentService } from '../services/shipment.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';

export const ShipmentController = {
  getByOrderId: asyncHandler(async (req: Request, res: Response) => {
    const shipment = await ShipmentService.getByOrderId(req.params.orderId, { id: req.user!.id, role: req.user!.role });
    return sendSuccess(res, shipment);
  })
};
