import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../config/jwt';
import { User } from '../models/User';

export const optionalAuth = async (req: Request, _res: Response, next: NextFunction) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      return next();
    }
    const token = header.replace('Bearer ', '');
    const payload = verifyAccessToken(token);
    const user = await User.findById(payload.userId);
    if (user) {
      req.user = {
        id: user.id,
        email: user.email,
        role: user.role,
        status: user.status
      };
    }
    return next();
  } catch (error) {
    return next();
  }
};
