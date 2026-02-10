import { Router } from 'express';
import Joi from 'joi';
import { PaymentController } from '../controllers/payment.controller';
import { requireAuth } from '../middleware/auth';
import { allowRoles } from '../middleware/rbac';
import { validate } from '../middleware/validation';

const router = Router();

const createSchema = Joi.object({
  orderId: Joi.string().required(),
  method: Joi.string().valid('orange_money', 'wave', 'moov', 'cash').required(),
  amount: Joi.number().positive().required()
});

router.post('/', requireAuth, allowRoles('customer'), validate(createSchema), PaymentController.create);

export default router;
