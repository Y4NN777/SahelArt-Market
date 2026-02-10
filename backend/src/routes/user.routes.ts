import { Router } from 'express';
import Joi from 'joi';
import { UserController } from '../controllers/user.controller';
import { requireAuth } from '../middleware/auth';
import { validate } from '../middleware/validation';

const router = Router();

const updateSchema = Joi.object({
  profile: Joi.object({
    firstName: Joi.string().min(2).max(50).optional(),
    lastName: Joi.string().min(2).max(50).optional(),
    phone: Joi.string().optional(),
    address: Joi.string().optional()
  }).required()
});

router.patch('/me', requireAuth, validate(updateSchema), UserController.updateMe);

export default router;
