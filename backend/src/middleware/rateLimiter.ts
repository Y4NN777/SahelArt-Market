import { Request, Response, NextFunction } from 'express';
import rateLimit from 'express-rate-limit';

const passthrough = (_req: Request, _res: Response, next: NextFunction) => next();

export const authRateLimiter = process.env.NODE_ENV === 'test'
  ? passthrough
  : rateLimit({
      windowMs: 15 * 60 * 1000,
      limit: 50,
      standardHeaders: 'draft-7',
      legacyHeaders: false
    });
