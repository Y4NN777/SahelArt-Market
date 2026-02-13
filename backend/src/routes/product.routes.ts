import { Router } from 'express';
import Joi from 'joi';
import { ProductController } from '../controllers/product.controller';
import { requireAuth } from '../middleware/auth';
import { allowRoles } from '../middleware/rbac';
import { validate } from '../middleware/validation';
import { createUploadMiddleware } from '../config/upload';
import { optionalAuth } from '../middleware/optionalAuth';
import { validateObjectId } from '../middleware/validateObjectId';

const router = Router();
const upload = createUploadMiddleware();

const createSchema = Joi.object({
  categoryId: Joi.string().required(),
  name: Joi.string().min(3).max(200).required(),
  description: Joi.string().min(10).max(2000).required(),
  price: Joi.number().positive().required(),
  stock: Joi.number().integer().min(0).required(),
  images: Joi.array().items(Joi.string()).max(5).optional()
});

const updateSchema = Joi.object({
  categoryId: Joi.string().optional(),
  name: Joi.string().min(3).max(200).optional(),
  description: Joi.string().min(10).max(2000).optional(),
  price: Joi.number().positive().optional(),
  stock: Joi.number().integer().min(0).optional(),
  status: Joi.string().valid('active', 'inactive').optional()
});

router.get('/', optionalAuth, ProductController.list);
router.get('/:id', optionalAuth, validateObjectId('id'), ProductController.getById);
router.post('/', requireAuth, allowRoles('vendor', 'admin'), validate(createSchema), ProductController.create);
router.patch('/:id', requireAuth, allowRoles('vendor', 'admin'), validateObjectId('id'), validate(updateSchema), ProductController.update);
router.delete('/:id', requireAuth, allowRoles('vendor', 'admin'), validateObjectId('id'), ProductController.remove);
router.post(
  '/:id/images',
  requireAuth,
  allowRoles('vendor', 'admin'),
  validateObjectId('id'),
  upload.array('images', 5),
  ProductController.uploadImages
);

export default router;
