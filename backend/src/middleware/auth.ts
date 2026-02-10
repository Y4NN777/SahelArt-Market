import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../config/jwt';
import { User } from '../models/User';
import { ApiError } from '../utils/ApiError';

export const requireAuth = async (req: Request, _res: Response, next: NextFunction) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      throw new ApiError(401, 'UNAUTHORIZED', 'No token provided');
    }
    const token = header.replace('Bearer ', '');
    const payload = verifyAccessToken(token);
    const user = await User.findById(payload.userId);
    if (!user) {
      throw new ApiError(401, 'UNAUTHORIZED', 'User not found');
    }
    if (user.status === 'suspended') {
      throw new ApiError(403, 'ACCOUNT_SUSPENDED', 'Account is suspended');
    }
    req.user = {
      id: user.id,
      email: user.email,
      role: user.role,
      status: user.status
    };
    next();
  } catch (error) {
    if (error instanceof ApiError) {
      return next(error);
    }
    return next(new ApiError(401, 'UNAUTHORIZED', 'Invalid token'));
  }
};
