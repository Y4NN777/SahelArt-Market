import { Router } from 'express';
import Joi from 'joi';
import { AdminController } from '../controllers/admin.controller';
import { requireAuth } from '../middleware/auth';
import { allowRoles } from '../middleware/rbac';
import { validate } from '../middleware/validation';

const router = Router();

const suspendSchema = Joi.object({
  reason: Joi.string().optional()
});

router.get('/stats', requireAuth, allowRoles('admin'), AdminController.stats);
router.get('/users', requireAuth, allowRoles('admin'), AdminController.listUsers);
router.patch('/users/:id/suspend', requireAuth, allowRoles('admin'), validate(suspendSchema), AdminController.suspendUser);

export default router;
