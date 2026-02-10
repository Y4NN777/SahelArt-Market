import { Router } from 'express';
import Joi from 'joi';
import { PaymentController } from '../controllers/payment.controller';
import { validate } from '../middleware/validation';

const router = Router();

const webhookSchema = Joi.object({
  transactionId: Joi.string().required(),
  orderId: Joi.string().required(),
  amount: Joi.number().positive().required(),
  status: Joi.string().required(),
  signature: Joi.string().optional()
});

router.post('/payment', validate(webhookSchema), PaymentController.webhook);

export default router;
