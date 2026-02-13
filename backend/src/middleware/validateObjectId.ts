import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { sendError } from '../utils/ApiResponse';

export const validateObjectId = (paramName: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const id = req.params[paramName];
    if (!id || !mongoose.Types.ObjectId.isValid(id)) {
      return sendError(res, 400, 'VALIDATION_ERROR', `Invalid ${paramName} format`);
    }
    next();
  };
};
