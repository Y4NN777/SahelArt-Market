import { Request, Response, NextFunction } from 'express';
import { ApiError } from '../utils/ApiError';
import { sendError } from '../utils/ApiResponse';

export const errorHandler = (err: unknown, _req: Request, res: Response, _next: NextFunction) => {
  if (err instanceof ApiError) {
    return sendError(res, err.statusCode, err.code, err.message, err.details);
  }

  if (err instanceof Error) {
    return sendError(res, 500, 'INTERNAL_ERROR', err.message);
  }

  return sendError(res, 500, 'INTERNAL_ERROR', 'An unexpected error occurred');
};
