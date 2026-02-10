import { Request, Response } from 'express';
import { PaymentService } from '../services/payment.service';
import { asyncHandler } from '../utils/asyncHandler';
import { sendSuccess } from '../utils/ApiResponse';

export const PaymentController = {
  create: asyncHandler(async (req: Request, res: Response) => {
    const result = await PaymentService.create({
      orderId: req.body.orderId,
      method: req.body.method,
      amount: req.body.amount,
      customerId: req.user!.id
    });
    return sendSuccess(res, result, 'Payment successful', 201);
  }),

  webhook: asyncHandler(async (req: Request, res: Response) => {
    await PaymentService.webhook(
      {
        orderId: req.body.orderId,
        amount: req.body.amount,
        status: req.body.status,
        transactionId: req.body.transactionId
      },
      req.body.signature
    );
    return sendSuccess(res, null, 'Payment confirmed');
  })
};
