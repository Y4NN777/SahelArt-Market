import { Router } from 'express';
import Joi from 'joi';
import { AuthController } from '../controllers/auth.controller';
import { validate } from '../middleware/validation';
import { requireAuth } from '../middleware/auth';
import { authRateLimiter } from '../middleware/rateLimiter';

const router = Router();

const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  role: Joi.string().valid('customer', 'vendor').required(),
  profile: Joi.object({
    firstName: Joi.string().min(2).max(50).required(),
    lastName: Joi.string().min(2).max(50).required(),
    phone: Joi.string().optional(),
    address: Joi.string().optional()
  }).required()
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required()
});

const refreshSchema = Joi.object({
  refreshToken: Joi.string().optional()
});

router.post('/register', authRateLimiter, validate(registerSchema), AuthController.register);
router.post('/login', authRateLimiter, validate(loginSchema), AuthController.login);
router.get('/me', requireAuth, AuthController.me);
router.post('/refresh', authRateLimiter, validate(refreshSchema), AuthController.refresh);
router.post('/logout', AuthController.logout);

export default router;
