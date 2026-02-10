import { Router } from 'express';
import Joi from 'joi';
import { OrderController } from '../controllers/order.controller';
import { requireAuth } from '../middleware/auth';
import { allowRoles } from '../middleware/rbac';
import { validate } from '../middleware/validation';

const router = Router();

const createSchema = Joi.object({
  items: Joi.array()
    .items(
      Joi.object({
        productId: Joi.string().required(),
        quantity: Joi.number().integer().min(1).required()
      })
    )
    .min(1)
    .required(),
  shippingAddress: Joi.object({
    street: Joi.string().required(),
    city: Joi.string().required(),
    postalCode: Joi.string().optional(),
    country: Joi.string().required(),
    phone: Joi.string().required()
  }).required()
});

const shipSchema = Joi.object({
  trackingNumber: Joi.string().optional()
});

router.post('/', requireAuth, allowRoles('customer'), validate(createSchema), OrderController.create);
router.get('/', requireAuth, allowRoles('customer', 'vendor', 'admin'), OrderController.list);
router.get('/:id', requireAuth, allowRoles('customer', 'vendor', 'admin'), OrderController.getById);
router.patch('/:id/ship', requireAuth, allowRoles('vendor', 'admin'), validate(shipSchema), OrderController.ship);
router.patch('/:id/delivered', requireAuth, allowRoles('customer', 'admin'), OrderController.delivered);
router.patch('/:id/cancel', requireAuth, allowRoles('customer', 'admin'), OrderController.cancel);

export default router;
